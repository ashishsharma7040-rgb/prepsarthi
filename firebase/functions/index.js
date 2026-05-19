/**
 * firebase/functions/index.js
 * PrepSarthi — Purchase Verification Cloud Function
 *
 * ✅ FIXED: basePlanId extracted from firstItem.offerDetails.basePlanId
 *           (was incorrectly using firstItem.productId as basePlanId)
 * ✅ FIXED: offerId extracted from firstItem.offerDetails.offerId
 * ✅ FIXED: Trial detection uses offerId === 'trial_7_days_new_user'
 *           (was using loose .includes('trial') — dangerous)
 * ✅ FIXED: Strict validation of productId and basePlanId
 * ✅ FIXED: trialUsed set ONLY by Cloud Function (client never writes it)
 * ✅ FIXED: autoRenewing derived from subscriptionState + cancelSurveyResult
 * ✅ FIXED: offerId written to subscriptions/{uid} for future reference
 * ✅ v6: verifiedAt field is written on every successful verification.
 *        The Flutter app polls subscriptions/{uid} for a fresh verifiedAt
 *        (within 90 seconds) before calling completePurchase(). This ensures
 *        the purchase is acknowledged AFTER backend verification — not before.
 *        See: lib/app.dart → _waitForBackendVerification()
 *
 * SETUP:
 *   cd firebase/functions && npm install
 *   firebase deploy --only functions
 *   firebase functions:secrets:set PLAY_SERVICE_ACCOUNT_JSON
 */

const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { onSchedule }        = require('firebase-functions/v2/scheduler');
const { initializeApp }     = require('firebase-admin/app');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { google }            = require('googleapis');

initializeApp();
const db = getFirestore();

// ── Config ────────────────────────────────────────────────────────────────────
const PACKAGE_NAME           = 'com.prepsarthi.app';
const SUBSCRIPTION_PRODUCT_ID = 'prepsarthi_premium';
const VALID_BASE_PLANS        = new Set(['monthly', 'quarterly', 'annual']);
const TRIAL_OFFER_ID          = 'trial_7_days_new_user';

// Grace period days per base plan (used if expiryTime missing)
const BASE_PLAN_DAYS = { monthly: 30, quarterly: 92, annual: 365 };

// ── Trigger: new purchaseVerificationRequest ──────────────────────────────────
exports.verifyPurchaseOnRequest = onDocumentCreated(
  {
    document:       'purchaseVerificationRequests/{requestId}',
    region:         'asia-south1',
    timeoutSeconds: 60,
  },
  async (event) => {
    const data = event.data.data();
    if (!data || data.status !== 'pending_verification') return null;
    if (!data.purchaseToken || !data.uid) {
      console.warn('[verifyPurchase] Missing token or uid — skipping');
      return null;
    }

    const { uid, purchaseToken, orderId } = data;
    const requestRef = event.data.ref;

    console.log(`[verifyPurchase] Processing request uid=${uid}`);

    try {
      const auth             = await _getPlayAuth();
      const androidPublisher = google.androidpublisher({ version: 'v3', auth });

      // ✅ Use subscriptionsv2.get (supports new base plan + offer model)
      const response = await androidPublisher.purchases.subscriptionsv2.get({
        packageName: PACKAGE_NAME,
        token:       purchaseToken,
      });

      const purchase = response.data;
      const now      = Date.now();

      // ── Extract line item fields ───────────────────────────────────────────
      const lineItems = purchase.lineItems || [];
      const firstItem = lineItems[0] || {};

      // ✅ FIXED: productId is the subscription product (prepsarthi_premium)
      const productId  = firstItem.productId || '';

      // ✅ FIXED: basePlanId comes from offerDetails.basePlanId, NOT productId
      const basePlanId = firstItem.offerDetails?.basePlanId || '';

      // ✅ FIXED: offerId comes from offerDetails.offerId
      const offerId    = firstItem.offerDetails?.offerId    || '';

      // ── Strict validation ─────────────────────────────────────────────────
      if (productId !== SUBSCRIPTION_PRODUCT_ID) {
        throw new Error(
          `Invalid productId: expected '${SUBSCRIPTION_PRODUCT_ID}', got '${productId}'`
        );
      }
      if (!VALID_BASE_PLANS.has(basePlanId)) {
        throw new Error(
          `Invalid basePlanId: '${basePlanId}'. Expected one of: ${[...VALID_BASE_PLANS].join(', ')}`
        );
      }
      if (purchase.linkedPurchaseToken === undefined &&
          purchase.startTime === undefined) {
        // Heuristic guard: a valid subscription always has startTime
        throw new Error('Purchase response missing startTime — may be invalid token');
      }

      // ── Expiry ────────────────────────────────────────────────────────────
      const expiryTimeStr = firstItem.expiryTime || purchase.startTime;
      const fallbackMs    = now + (BASE_PLAN_DAYS[basePlanId] || 30) * 24 * 60 * 60 * 1000;
      const expiryMs      = expiryTimeStr
          ? new Date(expiryTimeStr).getTime()
          : fallbackMs;
      const expiryDate    = new Date(expiryMs);

      // ── Subscription state ────────────────────────────────────────────────
      // subscriptionState values from Google Play Billing API v2:
      //   SUBSCRIPTION_STATE_ACTIVE
      //   SUBSCRIPTION_STATE_CANCELED       (user canceled, still in paid period)
      //   SUBSCRIPTION_STATE_IN_GRACE_PERIOD
      //   SUBSCRIPTION_STATE_ON_HOLD
      //   SUBSCRIPTION_STATE_PAUSED
      //   SUBSCRIPTION_STATE_EXPIRED
      const subscriptionState = purchase.subscriptionState || 'SUBSCRIPTION_STATE_UNSPECIFIED';
      const isActive   = subscriptionState === 'SUBSCRIPTION_STATE_ACTIVE';
      const isGrace    = subscriptionState === 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD';
      const isCanceled = subscriptionState === 'SUBSCRIPTION_STATE_CANCELED';
      const isExpired  = expiryMs < now && !isGrace;
      const hasAccess  = (isActive || isGrace || isCanceled) && !isExpired;

      let status;
      if (isActive  && !isExpired) status = 'active';
      else if (isGrace)             status = 'in_grace_period';
      else if (isCanceled && !isExpired) status = 'canceled_active'; // valid until expiry
      else                          status = 'expired';

      // ── Auto-renewing ─────────────────────────────────────────────────────
      // cancelSurveyResult present → user submitted cancellation
      // subscriptionState CANCELED also means not renewing
      const autoRenewing = !isCanceled &&
                           subscriptionState !== 'SUBSCRIPTION_STATE_EXPIRED' &&
                           purchase.cancelSurveyResult == null;

      // ── Trial detection ✅ FIXED ──────────────────────────────────────────
      // Strict equality — do NOT use .includes('trial')
      const isInTrial  = offerId === TRIAL_OFFER_ID;
      // trialUsed = true if this purchase is/was a trial, OR if user used one before
      const prevTrialUsed = await _wasTrialUsed(uid);
      const trialUsed     = isInTrial || prevTrialUsed;

      // ── Write verified entitlement to subscriptions/{uid} ─────────────────
      // ✅ Only Cloud Function / Admin SDK writes here.
      // Client Firestore rules: allow write: false for this collection.
      await db.collection('subscriptions').doc(uid).set({
        status,
        productId:         SUBSCRIPTION_PRODUCT_ID,
        basePlanId,                                    // 'monthly' | 'quarterly' | 'annual'
        offerId,                                       // '' or 'trial_7_days_new_user'
        expiryDate:        Timestamp.fromDate(expiryDate),
        autoRenewing,
        subscriptionState,
        trialUsed,
        verifiedAt:        FieldValue.serverTimestamp(),
        countryCode:       purchase.regionCode || '',
        orderId:           orderId || '',
        latestOrderId:     purchase.latestOrderId || orderId || '',
      }, { merge: true });

      // ── Update request doc ────────────────────────────────────────────────
      await requestRef.update({
        status:     hasAccess ? 'verified_active' : 'verified_inactive',
        verifiedAt: FieldValue.serverTimestamp(),
        verificationResult: {
          status,
          expiryDate:  expiryDate.toISOString(),
          basePlanId,
          offerId,
          isInTrial,
          trialUsed,
        },
        purchaseToken: FieldValue.delete(), // security hygiene — clear after use
      });

      console.log(
        `[verifyPurchase] ✅ uid=${uid} status=${status} ` +
        `basePlan=${basePlanId} offerId=${offerId} ` +
        `trial=${isInTrial} expires=${expiryDate.toISOString()}`
      );
      return null;

    } catch (error) {
      console.error(`[verifyPurchase] ❌ uid=${uid}:`, error.message);
      await requestRef.update({
        status:            'verification_failed',
        verificationError: error.message,
        updatedAt:         FieldValue.serverTimestamp(),
      });
      return null;
    }
  }
);

// ── Daily expiry sweep (midnight IST = 18:30 UTC) ────────────────────────────
exports.dailyExpiryCheck = onSchedule(
  { schedule: '30 18 * * *', region: 'asia-south1', timeZone: 'Asia/Kolkata' },
  async () => {
    console.log('[dailyExpiryCheck] Running expiry sweep…');
    const now     = new Date();
    const expired = await db.collection('subscriptions')
      .where('status', 'in', ['active', 'in_grace_period', 'canceled_active'])
      .where('expiryDate', '<', Timestamp.fromDate(now))
      .get();

    const batch = db.batch();
    let count   = 0;
    expired.docs.forEach(doc => {
      batch.update(doc.ref, {
        status:    'expired',
        updatedAt: FieldValue.serverTimestamp(),
      });
      count++;
    });
    if (count > 0) await batch.commit();
    console.log(`[dailyExpiryCheck] Marked ${count} subscriptions expired`);
  }
);

// ── Helpers ───────────────────────────────────────────────────────────────────

async function _getPlayAuth() {
  const auth = new google.auth.GoogleAuth({
    scopes: ['https://www.googleapis.com/auth/androidpublisher'],
  });
  return auth.getClient();
}

async function _wasTrialUsed(uid) {
  try {
    const doc = await db.collection('subscriptions').doc(uid).get();
    return doc.exists && doc.data().trialUsed === true;
  } catch (_) {
    return false;
  }
}
