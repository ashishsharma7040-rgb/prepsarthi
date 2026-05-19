# PrepSarthi — Play Store Release Checklist

## 1. Android Build Config
- [x] compileSdk = 35
- [x] targetSdk = 35
- [x] minSdk = 24
- [ ] versionCode bumped (increment before each upload)
- [ ] versionName set (e.g. 1.2.0)
- [ ] Release signing keystore configured in `android/key.properties`
- [ ] ProGuard rules verified (`android/app/proguard-rules.pro`)
- [ ] No debug keys or test API keys in release build

## 2. App Identity
- [ ] Package name finalized: `com.prepsarthi.app`
- [ ] App name: `PrepSarthi – JEE, NEET & Board Planner`
- [ ] App icon 512×512 PNG uploaded to Play Console
- [ ] Adaptive icon configured (`android/app/src/main/res/mipmap-*/`)
- [ ] Splash screen polished (no white flash)

## 3. Build Verification
Run in order:
```
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build appbundle --release
```
- [ ] All analyzer warnings resolved
- [ ] App bundle generated successfully at `build/app/outputs/bundle/release/`
- [ ] App bundle signed and verified

## 4. Google Play Billing — Subscription Setup

### In Play Console → Monetize → Subscriptions:
- [ ] Create subscription product: `prepsarthi_premium`
- [ ] Create base plan: `monthly` (₹99/month, auto-renewing)
- [ ] Create base plan: `quarterly` (₹239/3 months, auto-renewing)
- [ ] Create base plan: `annual` (₹799/year, auto-renewing)

### Create 7-day free trial offer:
- [ ] Offer type: **Free trial**
- [ ] Offer ID: `trial_7_days_new_user`
- [ ] Trial duration: 7 days
- [ ] Offer eligibility: **New customers** (never subscribed before)
- [ ] Apply offer to all 3 base plans OR monthly only

> **Important**: Do NOT name the offer "Free Trial" — name it per the plan (e.g. "PrepSarthi Monthly — 7-Day Trial")

### Billing Policy Compliance:
- [ ] Trial duration shown clearly in app: "7 days free"
- [ ] Post-trial price shown: "then ₹99/month"
- [ ] Auto-renewal disclosed in subscription screen
- [ ] Cancellation instructions shown (Google Play Subscriptions)
- [ ] "Continue with free plan" button visible and not hidden

## 5. Backend / Firebase Setup

### Firestore Security Rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /users/{uid}/subscription/{doc} {
      allow read: if request.auth.uid == uid;
      allow write: if false; // Only Cloud Functions write here
    }
    match /purchaseVerificationRequests/{reqId} {
      allow create: if request.auth != null
        && request.resource.data.uid == request.auth.uid;
      allow read, update, delete: if false;
    }
  }
}
```
- [ ] Firestore rules deployed
- [ ] No client-side premium activation without server verification

### Cloud Function (verify-purchase):
- [ ] Uses Google Play Developer API `subscriptionsv2.get` endpoint
- [ ] Validates: packageName, productId, basePlanId, purchaseState, expiryTime
- [ ] Writes verified entitlement to `users/{uid}/subscription/current`
- [ ] Stores hashed purchase token (never raw token)
- [ ] Sets `trialUsed = true` on first trial activation
- [ ] Cloud Function deployed to Firebase Functions

## 6. Test Billing Before Release

### Configure test accounts in Play Console → License Testing:
- [ ] Add tester Gmail accounts
- [ ] Set license response to "LICENSED"

### Test scenarios:
- [ ] New user sees 7-day free trial offer
- [ ] Trial starts and premium unlocks
- [ ] After trial ends, subscription continues (or expires if not paid)
- [ ] User who already used trial sees regular paid plans only
- [ ] Restore purchase works on reinstall
- [ ] Cancellation removes premium at next renewal
- [ ] Expired subscription locks premium features
- [ ] Pending payment shows correct "verifying" state
- [ ] App reinstall on same Google account restores premium

## 7. Play Console Listing

### Store Listing:
- [ ] App name: `PrepSarthi – JEE, NEET Study Planner` (max 50 chars)
- [ ] Short description (max 80 chars)
- [ ] Full description written (mention JEE, NEET, Class 12, AI, study planner)
- [ ] Screenshots: at least 4 (phone), recommended 8
  - Dashboard with readiness score
  - Today's Mission screen
  - Weekly plan
  - Weakness Radar
  - AI SWOT Report
  - Subscription screen
- [ ] Feature graphic 1024×500 PNG
- [ ] Content rating questionnaire completed

### Privacy & Legal:
- [ ] Privacy Policy public URL entered: `https://prepsarthi.app/privacy`
- [ ] Terms of Service URL: `https://prepsarthi.app/terms`
- [ ] Data Safety form filled:
  - Google account info collected (auth only)
  - Study data stored locally and synced to Firestore
  - Subscription status synced via Google Play Billing
  - No data sold to third parties
  - No advertising identifiers used

## 8. Premium Feature Gating Verification
- [ ] Free users CAN: basic dashboard, log sessions, view plan, Pomodoro, basic revision
- [ ] Free users CANNOT: AI SWOT, AI pattern report, PDF export, weakness radar, mistake notebook
- [ ] Premium gate shows paywall correctly (not crashes)
- [ ] Paywall closes with "Continue with free plan" option

## 9. App Quality
- [ ] No crash on cold start
- [ ] No crash on network unavailable
- [ ] Loading states shown for all async operations
- [ ] Empty states shown for no data
- [ ] Dark mode tested
- [ ] Font scaling tested (large text accessibility)
- [ ] Back navigation works correctly on all screens

## 10. Final Pre-Release
- [ ] Remove all `debugPrint` or convert to conditional on `kDebugMode`
- [ ] Remove any test/hardcoded credentials
- [ ] Firebase Crashlytics enabled (if included)
- [ ] Internal testing track uploaded and tested
- [ ] Closed testing with 5–10 real students
- [ ] Fix all crash reports from testing
- [ ] Production release submitted

---

## Play Console Subscription Setup — Step by Step

1. Go to **Play Console → PrepSarthi → Monetise → Subscriptions**
2. Click **Create subscription**
3. Product ID: `prepsarthi_premium`
4. Name: `PrepSarthi Premium`
5. Add base plan → ID: `monthly`, billing period: Monthly, price: ₹99
6. Add offer to `monthly` → Type: Free trial, Duration: 7 days, Eligibility: New customers
7. Repeat for `quarterly` (₹239, 3 months) and `annual` (₹799, 1 year)
8. Activate all base plans and offers
9. In your app: use product IDs exactly as defined above

## How to Test Subscription in Development

```
# In Play Console → Setup → License Testing
# Add your Gmail as a tester
# In Android Studio, use a physical device with that Gmail signed in
# The trial offer will show as available for testers even if already subscribed
```
