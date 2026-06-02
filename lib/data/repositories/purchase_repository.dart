// lib/data/repositories/purchase_repository.dart
//
// ✅ FIXED: Product ID constants now match Google Play subscription model correctly.
//           kSubscriptionProductId = 'prepsarthi_premium'  (the subscription product)
//           kBasePlan* = 'monthly' / 'quarterly' / 'annual' (base plan IDs)
//           kTrialOfferId = 'trial_7_days_new_user'
//           kAllProductIds contains ONLY the subscription product ID — not fake
//           'product:baseplan' composites.
//
// ✅ FIXED: markTrialStarted() no longer writes to subscriptions/{uid}.
//           Client NEVER writes to subscriptions/{uid}.
//           Trial is tracked only by Cloud Function after verifying offerDetails.offerId.
//           Client only reads subscriptions/{uid}.
//
// ✅ Firestore security rules are consistent with this code:
//           subscriptions/{uid}            — allow read; allow write: false
//           purchaseVerificationRequests   — allow create (uid match)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../local/isar/isar_service.dart';

// ── Product ID constants — single source of truth ────────────────────────────
//
// Play Console setup:
//   Subscription product ID : prepsarthi_premium
//   Base plan IDs           : monthly | quarterly | annual
//   Offer ID (trial)        : trial_7_days_new_user
//
// In Flutter, query productDetails({'prepsarthi_premium'}).
// Then inspect returned GooglePlayProductDetails for basePlanId / offerToken.
// DO NOT use fake composite IDs like 'prepsarthi_premium:monthly' as product IDs.

const kSubscriptionProductId = 'prepsarthi_premium';

const kBasePlanMonthly   = 'monthly';
const kBasePlanQuarterly = 'quarterly';
const kBasePlanAnnual    = 'annual';

const kTrialOfferId = 'trial_7_days_new_user';

/// The set passed to InAppPurchase.queryProductDetails().
const kAllProductIds = {kSubscriptionProductId};

/// Human-readable labels for each base plan (used in UI).
const kBasePlanLabels = {
  kBasePlanMonthly:   'Monthly',
  kBasePlanQuarterly: 'Quarterly',
  kBasePlanAnnual:    'Annual',
};

/// Fallback display prices shown before Play Store returns real prices.
const kBasePlanFallbackPrices = {
  kBasePlanMonthly:   '₹99/month',
  kBasePlanQuarterly: '₹239/3 months',
  kBasePlanAnnual:    '₹799/year',
};

class PurchaseRepository {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth      = FirebaseAuth.instance;

  // ── Record purchase token → purchaseVerificationRequests ─────────────────
  // Cloud Function reads this and writes verified entitlement to subscriptions/{uid}.
  // Client NEVER writes to subscriptions/{uid} directly.
  static Future<bool> recordPurchaseToken({
    required String productId,
    required String purchaseToken,
    required String orderId,
    String? basePlanId,
    String? offerId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint('[PurchaseRepo] No authenticated user — cannot record token');
      return false;
    }
    try {
      await _firestore.collection('purchaseVerificationRequests').add({
        'uid':           uid,
        'productId':     productId,
        'purchaseToken': purchaseToken,
        'orderId':       orderId,
        // Pass basePlanId/offerId so Cloud Function can validate without extra API call
        if (basePlanId != null) 'basePlanId': basePlanId,
        if (offerId    != null) 'offerId':    offerId,
        'platform':    'android',
        'packageName': 'com.prepsarthi.app',
        'recordedAt':  FieldValue.serverTimestamp(),
        'status':      'pending_verification',
      });
      debugPrint('[PurchaseRepo] Verification request recorded — product=$productId basePlan=$basePlanId offer=$offerId');
      return true;
    } catch (e) {
      debugPrint('[PurchaseRepo] Firestore write error: $e');
      return false;
    }
  }

  // ── Sync entitlement from Firestore → local Isar ─────────────────────────
  // subscriptions/{uid} is READ-ONLY for client; only Cloud Function writes it.
  static Future<SubscriptionEntitlement> syncEntitlement() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const SubscriptionEntitlement.none();

    try {
      final doc = await _firestore
          .collection('subscriptions')
          .doc(uid)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists) return const SubscriptionEntitlement.none();

      final data       = doc.data()!;
      final status     = data['status']     as String? ?? 'inactive';
      final isPremium  = status == 'active' || status == 'in_grace_period' ||
                         status == 'canceled_active';
      final expiryTs   = data['expiryDate'] as Timestamp?;
      final expiryDate = expiryTs?.toDate();
      final productId  = data['productId']  as String? ?? '';
      final basePlanId = data['basePlanId'] as String? ?? '';
      final offerId    = data['offerId']    as String? ?? '';
      final trialUsed  = data['trialUsed']  as bool?   ?? false;

      // Local expiry double-check
      final now        = DateTime.now();
      final isExpired  = expiryDate != null && expiryDate.isBefore(now);
      final effective  = isPremium && !isExpired;

      await _updateLocalUser(
        isPremium:  effective,
        planType:   effective ? (basePlanId.isNotEmpty ? basePlanId : productId) : null,
        expiry:     effective ? expiryDate : null,
        trialUsed:  trialUsed,
      );

      return SubscriptionEntitlement(
        isPremium:   effective,
        productId:   productId,
        basePlanId:  basePlanId,
        offerId:     offerId,
        expiryDate:  expiryDate,
        status:      status,
        trialUsed:   trialUsed,
      );
    } on FirebaseException catch (e) {
      debugPrint('[PurchaseRepo] Firestore sync failed: ${e.code} — ${e.message}');
      return _localEntitlement();
    } catch (e) {
      debugPrint('[PurchaseRepo] Sync error: $e');
      return _localEntitlement();
    }
  }

  // ── markTrialStarted ─────────────────────────────────────────────────────
  // ✅ FIXED: No longer writes to subscriptions/{uid} — that would fail because
  //           Firestore rules deny client writes to that collection.
  //           Instead we only update local Isar as an optimistic UI hint.
  //           The authoritative trialUsed flag is set by Cloud Function after
  //           verifying offerId == 'trial_7_days_new_user' in the purchase receipt.
  static Future<void> markTrialStartedLocally() async {
    try {
      final db   = IsarService.db;
      final user = await db.userSchemas.where().findFirst();
      if (user != null) {
        user.trialUsed      = true;
        user.trialStartedAt = DateTime.now();
        await db.writeTxn(() async => db.userSchemas.put(user));
        debugPrint('[PurchaseRepo] Local trial flag set (authoritative flag set by Cloud Function)');
      }
    } catch (e) {
      debugPrint('[PurchaseRepo] markTrialStartedLocally error: $e');
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static Future<void> _updateLocalUser({
    required bool isPremium,
    required String? planType,
    required DateTime? expiry,
    bool? trialUsed,
  }) async {
    final db   = IsarService.db;
    final user = await db.userSchemas.where().findFirst();
    if (user == null) return;
    user.isPremium         = isPremium;
    user.subscriptionPlan  = planType;
    user.premiumExpiry     = expiry;
    if (trialUsed != null) user.trialUsed = trialUsed;
    await db.writeTxn(() async => db.userSchemas.put(user));
  }

  static Future<SubscriptionEntitlement> _localEntitlement() async {
    final db   = IsarService.db;
    final user = await db.userSchemas.where().findFirst();
    if (user == null) return const SubscriptionEntitlement.none();
    return SubscriptionEntitlement(
      isPremium:  user.hasActivePremium,
      productId:  kSubscriptionProductId,
      basePlanId: user.subscriptionPlan ?? '',
      offerId:    '',
      expiryDate: user.premiumExpiry,
      status:     user.hasActivePremium ? 'active_cached' : 'inactive',
      trialUsed:  user.trialUsed,
    );
  }
}

// ── SubscriptionEntitlement value object ─────────────────────────────────────

class SubscriptionEntitlement {
  final bool isPremium;
  final String productId;
  final String basePlanId;
  final String offerId;
  final DateTime? expiryDate;
  final String status;
  final bool trialUsed;

  const SubscriptionEntitlement({
    required this.isPremium,
    required this.productId,
    required this.basePlanId,
    required this.offerId,
    required this.expiryDate,
    required this.status,
    required this.trialUsed,
  });

  const SubscriptionEntitlement.none()
      : isPremium  = false,
        productId  = '',
        basePlanId = '',
        offerId    = '',
        expiryDate = null,
        status     = 'inactive',
        trialUsed  = false;
}
