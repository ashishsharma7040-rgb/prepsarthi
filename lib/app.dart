// lib/app.dart
//
// ✅ PRODUCTION FIX 1 (v6): Removed blind markTrialStartedLocally() call.
//    Trial state now comes ONLY from Firestore via _syncEntitlement().
//    The Cloud Function sets trialUsed authoritatively after verifying
//    offerDetails.offerId == 'trial_7_days_new_user'. No local guessing.
//
// ✅ PRODUCTION FIX 2 (v6): completePurchase now called AFTER Cloud Function
//    verification is confirmed via Firestore polling (up to 20 s timeout).
//    If backend does not respond in time, purchase is still acknowledged
//    to avoid the Google Play 3-day auto-refund, and a retry is queued.
//
// ✅ PRODUCTION FIX 3 (v6): Pending purchase retry stores token|productId|orderId
//    in SharedPreferences and replays on next app resume/launch.
//
// Retained from v5:
//  ✅ Single purchaseStream listener at root (paywall NEVER owns the stream)
//  ✅ completePurchase only after Firestore write succeeds on the happy path
//  ✅ No local premium unlock — Firestore is the only source of truth

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/purchase_repository.dart';
import 'presentation/providers/all_providers.dart';
import 'router/app_router.dart';

const _kPendingPurchaseKey = 'prepsarthi_pending_purchase_token';

// How long to poll Firestore waiting for Cloud Function verification.
// Google requires acknowledgment within 3 days — 20 s is safe and responsive.
const _kVerificationPollTimeout  = Duration(seconds: 20);
const _kVerificationPollInterval = Duration(seconds: 2);

// A verification is "fresh" if verifiedAt is within this window.
const _kVerificationFreshWindow = Duration(seconds: 90);

class PrepSarthiApp extends ConsumerStatefulWidget {
  final bool iapAvailable;
  const PrepSarthiApp({super.key, this.iapAvailable = false});

  @override
  ConsumerState<PrepSarthiApp> createState() => _PrepSarthiAppState();
}

class _PrepSarthiAppState extends ConsumerState<PrepSarthiApp>
    with WidgetsBindingObserver {
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.iapAvailable) {
      // ✅ Single listener at app root — paywall NEVER listens to purchaseStream.
      _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (e) => debugPrint('[IAP] Stream error: $e'),
      );
    }
    _syncEntitlement();
    _retryPendingPurchase(); // Replay any token that failed on the previous launch.
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncEntitlement();
      _retryPendingPurchase();
    }
  }

  // ── Entitlement sync — Firestore is the single source of truth ────────────

  Future<void> _syncEntitlement() async {
    try {
      final entitlement = await PurchaseRepository.syncEntitlement();
      if (!mounted) return;
      if (entitlement.isPremium) {
        await ref.read(subscriptionProvider.notifier).activatePremiumFromServer(
          planType: entitlement.basePlanId.isNotEmpty
              ? entitlement.basePlanId
              : entitlement.productId,
          expiry: entitlement.expiryDate,
        );
      } else {
        await ref.read(subscriptionProvider.notifier).deactivatePremium();
      }
    } catch (e) {
      debugPrint('[App] Entitlement sync error: $e');
      // On network error: keep last-known local state.
      // Never grant premium locally when Firestore is unreachable.
    }
  }

  // ── Purchase stream handler ───────────────────────────────────────────────

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);
          break;
        case PurchaseStatus.error:
          debugPrint('[IAP] Purchase error: ${purchase.error?.message}');
          // Must complete error purchases to clear the Play Store queue.
          if (purchase.pendingCompletePurchase) {
            InAppPurchase.instance.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.canceled:
          debugPrint('[IAP] Purchase canceled by user');
          if (purchase.pendingCompletePurchase) {
            InAppPurchase.instance.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.pending:
          debugPrint('[IAP] Purchase pending (UPI / family approval)');
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    final token     = purchase.verificationData.serverVerificationData;
    final productId = purchase.productID;
    final orderId   = purchase.purchaseID ?? '';

    // Step 1 ── Record token → Firestore → triggers Cloud Function verification.
    final recorded = await PurchaseRepository.recordPurchaseToken(
      productId:     productId,
      purchaseToken: token,
      orderId:       orderId,
      // basePlanId / offerId derived authoritatively by Cloud Function from
      // the Google Play subscriptionsv2 API response (offerDetails fields).
    );

    if (recorded) {
      // Step 2 ── ✅ PRODUCTION FIX: Poll Firestore until Cloud Function
      //           confirms the entitlement. Only THEN complete the purchase.
      final uid = FirebaseAuth.instance.currentUser?.uid;
      bool backendVerified = false;

      if (uid != null) {
        backendVerified = await _waitForBackendVerification(uid);
      }

      if (backendVerified) {
        // Happy path: backend confirmed → acknowledge → sync UI.
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
          debugPrint('[IAP] ✅ Purchase completed after backend verification');
        }
        // ✅ PRODUCTION FIX: No markTrialStartedLocally() here.
        //    _syncEntitlement reads trialUsed, basePlanId, and expiry from
        //    Firestore. The Cloud Function is the only authority on trialUsed.
        await _syncEntitlement();
        await _clearPendingPurchase();
      } else {
        // Timeout fallback: Cloud Function took longer than expected.
        // Still complete to avoid the Google Play 3-day auto-refund.
        // Retry on next launch / resume will sync entitlement.
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
          debugPrint('[IAP] ⚠️ Purchase acknowledged (verification timeout) — retry on next resume');
        }
        await _storePendingPurchase(token, productId, orderId);
        _showVerificationPendingSnackbar();
      }
    } else {
      // Token record itself failed (offline / auth issue).
      // Store for retry; still complete to avoid 3-day refund.
      await _storePendingPurchase(token, productId, orderId);
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
        debugPrint('[IAP] ⚠️ Purchase acknowledged but token write failed — queued for retry');
      }
      _showVerificationPendingSnackbar();
    }
  }

  // ── Cloud Function verification poller ───────────────────────────────────
  //
  // Polls subscriptions/{uid} on the server (bypasses Firestore local cache)
  // and returns true as soon as a fresh, active entitlement is confirmed.
  // Never throws — returns false on timeout or network failure.

  Future<bool> _waitForBackendVerification(String uid) async {
    final deadline = DateTime.now().add(_kVerificationPollTimeout);

    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(_kVerificationPollInterval);

      try {
        final doc = await FirebaseFirestore.instance
            .collection('subscriptions')
            .doc(uid)
            .get(const GetOptions(source: Source.server));

        if (!doc.exists) continue;

        final data       = doc.data()!;
        final status     = data['status'] as String? ?? '';
        final verifiedAt = (data['verifiedAt'] as Timestamp?)?.toDate();

        final isActive = status == 'active' ||
            status == 'in_grace_period' ||
            status == 'canceled_active';

        // "Fresh" = Cloud Function wrote verifiedAt within the last 90 seconds.
        final isFresh = verifiedAt != null &&
            DateTime.now().difference(verifiedAt) <= _kVerificationFreshWindow;

        if (isActive && isFresh) {
          debugPrint('[IAP] ✅ Backend verified: status=$status');
          return true;
        }
      } catch (e) {
        debugPrint('[IAP] Verification poll error (retrying): $e');
      }
    }

    debugPrint('[IAP] ⚠️ Verification poll timed out after ${_kVerificationPollTimeout.inSeconds}s');
    return false;
  }

  // ── Pending purchase retry queue ─────────────────────────────────────────

  Future<void> _storePendingPurchase(
      String token, String productId, String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kPendingPurchaseKey, '$token|$productId|$orderId');
      debugPrint('[IAP] Pending purchase stored for retry on next launch');
    } catch (e) {
      debugPrint('[IAP] Could not store pending purchase: $e');
    }
  }

  Future<void> _retryPendingPurchase() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final stored = prefs.getString(_kPendingPurchaseKey);
      if (stored == null || stored.isEmpty) return;

      final parts = stored.split('|');
      if (parts.length < 3) {
        await prefs.remove(_kPendingPurchaseKey);
        return;
      }

      final token     = parts[0];
      final productId = parts[1];
      final orderId   = parts[2];

      debugPrint('[IAP] Retrying pending token for product=$productId');

      final recorded = await PurchaseRepository.recordPurchaseToken(
        productId:     productId,
        purchaseToken: token,
        orderId:       orderId,
      );

      if (recorded) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await _waitForBackendVerification(uid);
        }
        await prefs.remove(_kPendingPurchaseKey);
        await _syncEntitlement();
        debugPrint('[IAP] Pending purchase retry succeeded');
      }
    } catch (e) {
      debugPrint('[IAP] Pending purchase retry error: $e');
    }
  }

  Future<void> _clearPendingPurchase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPendingPurchaseKey);
    } catch (_) {}
  }

  void _showVerificationPendingSnackbar() {
    if (!mounted) return;
    final ctx = ref
        .read(routerProvider)
        .routerDelegate
        .navigatorKey
        .currentContext;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text(
          'Purchase received! Premium will activate in a few minutes. '
          'If it does not appear, tap Restore Purchases in Settings.',
        ),
        duration: Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final router   = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    final themeMode = switch (settings.themeMode) {
      'light' => ThemeMode.light,
      'dark'  => ThemeMode.dark,
      _       => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'PrepSarthi',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
