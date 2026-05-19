# PrepSarthi — Play Store & Subscription Checklist
# ✅ Updated for v5 — All critical billing, import, and doc issues resolved

## What changed in v5 (fixes applied to this version)

| Fix | File |
|---|---|
| `offerToken` → `offerIdToken` (correct `SubscriptionOfferDetailsWrapper` property) | `premium_paywall_screen.dart` |
| `package:collection` added + imported for `firstOrNull` | `pubspec.yaml`, `premium_paywall_screen.dart`, `study_screens.dart` |
| Removed pre-purchase `markTrialStartedLocally()` — now only fires after `PurchaseStatus.purchased` | `premium_paywall_screen.dart`, `app.dart` |
| All docs updated — wrong `prepsarthi_premium:monthly` references replaced with correct model | `README.md`, `QUICKSTART.md`, `DEPLOY_CHECKLIST.md`, `FIREBASE_SETUP.dart` |
| Firestore rules in `FIREBASE_SETUP.dart` corrected — `subscriptions/{uid}` now read-only for client | `firebase/FIREBASE_SETUP.dart` |
| Privacy / Terms URL guidance and hosting options documented | `PLAY_STORE_CHECKLIST.md`, `DEPLOY_CHECKLIST.md` |

---

## 1. Play Console — Subscription Setup

### Create subscription product
- Product ID: `prepsarthi_premium`  ← EXACT, case-sensitive

### Create base plans under `prepsarthi_premium`
| Base Plan ID | Billing Period | Price     |
|--------------|---------------|-----------|
| `monthly`    | 1 month        | ₹99       |
| `quarterly`  | 3 months       | ₹239      |
| `annual`     | 12 months      | ₹799      |

### Create trial offer under each base plan
- Offer ID: `trial_7_days_new_user`
- Eligibility: New subscribers only
- Trial duration: 7 days free
- Attach to: `monthly`, `quarterly`, `annual`

> ⚠️ DO NOT create product IDs like `prepsarthi_premium:monthly`.
> The app queries `prepsarthi_premium` and inspects base plan / offer details.

---

## 2. Firebase Setup

### Firestore collections
- `subscriptions/{uid}` — Cloud Function writes; client read-only
- `purchaseVerificationRequests/{id}` — client creates; Cloud Function reads

### Deploy Cloud Function
```bash
cd firebase/functions
npm install
firebase deploy --only functions
```

### Set service account secret
```bash
firebase functions:secrets:set PLAY_SERVICE_ACCOUNT_JSON
# Paste the Google Play service account JSON when prompted
```

---

## 3. Flutter Build

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build appbundle --release
```

---

## 4. Privacy Policy & Terms

Before Play Store upload, host these URLs **— they MUST be live, not 404**:
- https://prepsarthi.app/privacy
- https://prepsarthi.app/terms

Both are linked from the paywall and in-app privacy screen.
Play Console requires a publicly accessible privacy policy URL.

**If your domain isn't ready yet, use a temporary host:**
```
Option A — Firebase Hosting (recommended):
  firebase init hosting
  # Create public/privacy.html and public/terms.html with your content
  firebase deploy --only hosting
  # Use: https://your-project.web.app/privacy

Option B — GitHub Pages:
  # Create public repo prepsarthi-legal
  # Add privacy.html and terms.html at repo root
  # Enable Pages in Settings
  # Use: https://yourusername.github.io/prepsarthi-legal/privacy.html

Option C — Notion public page:
  # Create pages, toggle Share → Publish to web
  # Use the public Notion URL
```

**Minimum content required in Privacy Policy:**
- What data is collected (user ID, study logs, purchase status, device info)
- How it is used (personalisation, subscription verification)
- Third-party services used (Firebase, Google Play Billing, Gemini AI)
- Data deletion / account deletion instructions
- Contact email

Update URLs in code if domain changes:
- `lib/presentation/screens/settings/premium_paywall_screen.dart` (lines with `prepsarthi.app/privacy`)
- `lib/presentation/screens/privacy/privacy_policy_screen.dart`

---

## 5. Testing Checklist

### 7-Day Trial Flow
- [ ] New user → paywall shows "Start 7-Day Free Trial"
- [ ] Select monthly plan → purchases with trial offer token
- [ ] Cloud Function detects `offerId == 'trial_7_days_new_user'`
- [ ] `subscriptions/{uid}` has `trialUsed: true`, `status: 'active'`
- [ ] App shows premium features active
- [ ] After 7 days → converts to paid or expires
- [ ] `trialUsed: true` persists → future paywall shows "Subscribe Now"

### Cancellation Flow
- [ ] Cancel in Google Play → state becomes `SUBSCRIPTION_STATE_CANCELED`
- [ ] Daily sweep marks `status: canceled_active` until expiry
- [ ] On expiry → `status: expired`, `isPremium: false`
- [ ] App removes premium features

### Restore Purchase
- [ ] Uninstall + reinstall → tap Restore Purchases
- [ ] `app.dart` handles `PurchaseStatus.restored`
- [ ] Token sent to Firestore → Cloud Function verifies
- [ ] Premium restored without calling markTrialStartedLocally again

### Reinstall (active subscription)
- [ ] Reinstall app while subscription active
- [ ] On launch: `_syncEntitlement()` reads `subscriptions/{uid}`
- [ ] Premium auto-restored from Firestore without any user action

### Expired Subscription
- [ ] Allow subscription to expire
- [ ] Daily Cloud Function sweep marks `status: expired`
- [ ] Next app open: `syncEntitlement()` → `isPremium: false`
- [ ] Paywall shown with "Subscribe Now" (no trial eligible)

### Network Failure During Purchase
- [ ] Kill network after purchase, before Firestore write
- [ ] Token stored in SharedPrefs as pending
- [ ] On next launch: `_retryPendingPurchase()` retries Firestore write
- [ ] Premium activates after retry succeeds

---

## 6. Readiness Score Validation

After fixing imports and removing placeholders:
- [ ] Log 3+ study sessions → Consistency score > 0
- [ ] Add a test score entry → Tests component uses real avg %
- [ ] Mark a mistake as resolved → Mistakes component shows real ratio
- [ ] Mark 5+ chapters learned → Syllabus component > 0
- [ ] Score changes dynamically as data changes

---

## 7. Pre-upload Checklist

**Run these commands in order — all must pass:**
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze     # must show 0 errors, 0 warnings
flutter test        # must show all tests pass
flutter build appbundle --release
```

- [ ] `flutter analyze` — zero errors
- [ ] `flutter build appbundle --release` — succeeds
- [ ] Privacy policy URL live and accessible: https://prepsarthi.app/privacy
- [ ] Terms of Use URL live and accessible: https://prepsarthi.app/terms
- [ ] Play Console: subscription `prepsarthi_premium` + base plans `monthly/quarterly/annual` + trial offer `trial_7_days_new_user` all created
- [ ] Firebase: Cloud Function deployed and tested
- [ ] Firestore rules deployed: `firebase deploy --only firestore:rules`
- [ ] Proguard rules confirm no IAP classes stripped
- [ ] App ID: `com.prepsarthi.app`
- [ ] targetSdk 35 / compileSdk 35
- [ ] No placeholder TODOs in billing or readiness code
- [ ] `collection: ^1.18.0` present in pubspec.yaml (for `firstOrNull`)
