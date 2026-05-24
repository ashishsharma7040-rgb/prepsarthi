import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/startup/startup_controller.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/purchase_repository.dart';
import 'presentation/providers/all_providers.dart';
import 'presentation/screens/startup/premium_intro_screen.dart';
import 'presentation/screens/startup/startup_error_screen.dart';
import 'router/app_router.dart';

const _kPendingPurchaseKey = 'prepsarthi_pending_purchase_token';
const _kVerificationPollTimeout = Duration(seconds: 20);
const _kVerificationPollInterval = Duration(seconds: 2);
const _kVerificationFreshWindow = Duration(seconds: 90);

class PrepSarthiApp extends ConsumerWidget {
  const PrepSarthiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(startupControllerProvider);

    final startupState = startupAsync.maybeWhen(
      data: (state) => state,
      orElse: () => const StartupState(),
    );

    if (startupAsync.hasError || startupState.isFailed) {
      final debugDetail = startupAsync.whenOrNull(
            error: (error, _) => error.toString(),
          ) ??
          startupState.debugDetail ??
          startupState.errorMessage;

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        home: StartupErrorScreen(
          debugDetail: debugDetail,
          onRetry: () => ref.read(startupControllerProvider.notifier).retry(),
        ),
      );
    }

    if (!startupState.isCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        home: PremiumIntroScreen(
          statusText: startupState.statusText,
        ),
      );
    }

    return const _MainApp();
  }
}

class _MainApp extends ConsumerStatefulWidget {
  const _MainApp();

  @override
  ConsumerState<_MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<_MainApp>
    with WidgetsBindingObserver {
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final iapAvailable = ref.read(iapAvailableProvider);
    if (iapAvailable) {
      _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (error) => debugPrint('[IAP] stream error: $error'),
      );
    }

    _syncEntitlement();
    _retryPendingPurchase();
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
    } catch (error) {
      debugPrint('[App] entitlement sync error: $error');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);
          break;
        case PurchaseStatus.error:
          debugPrint('[IAP] purchase error: ${purchase.error?.message}');
          if (purchase.pendingCompletePurchase) {
            InAppPurchase.instance.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.canceled:
          debugPrint('[IAP] purchase canceled by user');
          if (purchase.pendingCompletePurchase) {
            InAppPurchase.instance.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.pending:
          debugPrint('[IAP] purchase pending');
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    final token = purchase.verificationData.serverVerificationData;
    final productId = purchase.productID;
    final orderId = purchase.purchaseID ?? '';

    final recorded = await PurchaseRepository.recordPurchaseToken(
      productId: productId,
      purchaseToken: token,
      orderId: orderId,
    );

    if (recorded) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      var backendVerified = false;

      if (uid != null) {
        backendVerified = await _waitForBackendVerification(uid);
      }

      if (backendVerified) {
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
          debugPrint('[IAP] purchase completed after backend verification');
        }
        await _syncEntitlement();
        await _clearPendingPurchase();
      } else {
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
          debugPrint('[IAP] purchase acknowledged after verification timeout');
        }
        await _storePendingPurchase(token, productId, orderId);
        _showVerificationPendingSnackbar();
      }
    } else {
      await _storePendingPurchase(token, productId, orderId);
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
        debugPrint('[IAP] purchase acknowledged after token write failure');
      }
      _showVerificationPendingSnackbar();
    }
  }

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

        final data = doc.data()!;
        final status = data['status'] as String? ?? '';
        final verifiedAt = (data['verifiedAt'] as Timestamp?)?.toDate();

        final isActive = status == 'active' ||
            status == 'in_grace_period' ||
            status == 'canceled_active';
        final isFresh = verifiedAt != null &&
            DateTime.now().difference(verifiedAt) <= _kVerificationFreshWindow;

        if (isActive && isFresh) {
          debugPrint('[IAP] backend verified: status=$status');
          return true;
        }
      } catch (error) {
        debugPrint('[IAP] verification poll error: $error');
      }
    }

    return false;
  }

  Future<void> _storePendingPurchase(
    String token,
    String productId,
    String orderId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kPendingPurchaseKey,
        '$token|$productId|$orderId',
      );
      debugPrint('[IAP] pending purchase stored');
    } catch (error) {
      debugPrint('[IAP] could not store pending purchase: $error');
    }
  }

  Future<void> _retryPendingPurchase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_kPendingPurchaseKey);
      if (stored == null || stored.isEmpty) return;

      final parts = stored.split('|');
      if (parts.length < 3) {
        await prefs.remove(_kPendingPurchaseKey);
        return;
      }

      final token = parts[0];
      final productId = parts[1];
      final orderId = parts[2];

      debugPrint('[IAP] retrying pending token for product=$productId');

      final recorded = await PurchaseRepository.recordPurchaseToken(
        productId: productId,
        purchaseToken: token,
        orderId: orderId,
      );

      if (recorded) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await _waitForBackendVerification(uid);
        }
        await prefs.remove(_kPendingPurchaseKey);
        await _syncEntitlement();
        debugPrint('[IAP] pending purchase retry succeeded');
      }
    } catch (error) {
      debugPrint('[IAP] pending purchase retry error: $error');
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

    final context =
        ref.read(routerProvider).routerDelegate.navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Purchase received. Premium will activate in a few minutes. '
          'If it does not appear, tap Restore Purchases in Settings.',
        ),
        duration: Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    final themeMode = switch (settings.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    // Suppress Flutter's default red "× RenderFlex overflowed" banner in
    // release builds; show a clean empty box instead.
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // In debug mode keep the default red screen so developers see errors.
      if (kDebugMode) return ErrorWidget(details.exception);
      return const SizedBox.shrink();
    };

    return MaterialApp.router(
      title: 'PrepSarthi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
