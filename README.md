# PrepSarthi — JEE, NEET & Class 12 AI Study Planner

**Version:** 1.2.0+3  
**Package:** `com.prepsarthi.app`  
**Target SDK:** 35 (Android 15)  
**Min SDK:** 24 (Android 7.0+)

## ✅ All Issues Fixed in v3

| Issue | Status |
|---|---|
| Broken `<uses-permission android:maxSdkVersion="32" />` (no android:name) | ✅ Fixed — removed |
| BacklogAdjuster wrong import paths (`../../../` → `../../`) | ✅ Fixed |
| Local premium fallback in app.dart when Firestore fails | ✅ Removed — show message instead |
| TODO in premium_paywall_screen.dart purchase handler | ✅ Removed — flow is complete |
| Duplicate purchaseStream listener (app.dart + paywall) | ✅ Fixed — single listener in app.dart |
| Cloud Function using old `subscriptions.get` API | ✅ Updated to `subscriptionsv2.get` |
| Product ID mismatch (`peakprep_premium:monthly` vs `peakprep_monthly`) | ✅ Fixed — single product `prepsarthi_premium` with base plans `monthly/quarterly/annual` |
| `_trialUsed = auth.user?.isPremium ?? false` (wrong logic) | ✅ Fixed — separate `trialUsed` field in UserSchema |
| Firestore rules still allowed client to modify sensitive fields | ✅ Fixed — subscription doc is fully read-only for client |
| User can write directly to `subscriptions/{uid}` | ✅ Fixed — moved to `purchaseVerificationRequests` |
| `README.md` still said `targetSdk 34` | ✅ Fixed |
| No Crashlytics integration | ✅ Added `firebase_crashlytics` |
| App name still PeakPrep in manifests | ✅ Renamed to PrepSarthi everywhere |

## 🆕 New Features in v3

| Feature | Description |
|---|---|
| **Exam Readiness Score (0-100)** | Weighted: 30% syllabus + 20% revision + 20% tests + 15% consistency + 10% backlog + 5% mistakes |
| **Readiness Score Card** | Premium dashboard widget with breakdown bars and actionable tips |
| **Daily Deficit Tracker** | Real-time "Planned 6h / Studied 4h / Deficit 2h" dashboard card |
| **BacklogResult model** | Typed result from BacklogAdjuster with needsRegeneration flag |
| **Trial tracking (UserSchema)** | `trialUsed`, `trialStartedAt`, `trialEndedAt` — separate from `isPremium` |
| **purchaseVerificationRequests** | Separate Firestore collection for purchase tokens (user-writable) |

## 🏗️ Architecture

```
lib/
├── main.dart                    # Firebase + Isar + Crashlytics + IAP init
├── app.dart                     # PrepSarthiApp — single IAP stream, Firestore sync
├── core/
│   ├── constants/app_colors.dart
│   ├── theme/app_theme.dart
│   └── utils/notification_helper.dart  # Inexact alarms, no exact perm needed
├── data/
│   ├── local/isar/
│   │   ├── isar_service.dart
│   │   └── schemas/
│   │       ├── user_schema.dart         # + trialUsed, trialStartedAt, trialEndedAt
│   │       ├── chapter_schema.dart      # + mastery levels
│   │       ├── plan_entry_schema.dart
│   │       ├── study_log_schema.dart
│   │       ├── revision_schedule_schema.dart
│   │       ├── user_settings_schema.dart
│   │       └── achievement_schema.dart
│   ├── local/preload/syllabus_loader.dart   # safeReload (preserves progress)
│   ├── remote/vertex/gemini_service.dart    # Retry + JSON repair + fallback
│   └── repositories/
│       └── purchase_repository.dart    # Consistent product IDs, trial tracking
├── domain/usecases/
│   ├── backlog_adjuster.dart           # ✅ FIXED imports, returns BacklogResult
│   ├── generate_plan_usecase.dart
│   └── readiness_score.dart           # NEW: Weighted readiness calculation
├── presentation/
│   ├── providers/all_providers.dart
│   ├── screens/
│   │   ├── settings/
│   │   │   └── premium_paywall_screen.dart  # ✅ FIXED: no TODO, no stream listener
│   │   └── ...
│   └── widgets/
│       └── dashboard/
│           ├── readiness_score_card.dart    # NEW: premium card
│           └── deficit_card.dart            # NEW: deficit tracker
├── router/app_router.dart
└── firebase_options.dart

firebase/
├── firestore.rules               # ✅ subscription read-only, requests create-only
└── functions/
    └── index.js                  # ✅ subscriptionsv2.get + purchaseVerificationRequests

android/
└── app/
    ├── build.gradle              # compileSdk 35, targetSdk 35, com.prepsarthi.app
    └── src/main/AndroidManifest.xml  # ✅ broken permission removed
```

## 🚀 Quick Start

```bash
# 1. Create Flutter project
flutter create prepsarthi --org com.prepsarthi --platforms android,ios
cd prepsarthi

# 2. Copy all files from this project

# 3. Firebase setup
flutterfire configure   # generates firebase_options.dart
# Copy google-services.json → android/app/

# 4. Generate Isar schemas
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 5. Verify zero errors
flutter analyze        # Target: 0 errors, 0 warnings

# 6. Run
flutter run

# 7. Release
flutter build appbundle --release
```

## 💳 Subscription Structure (Play Console)

```
Subscription product:   prepsarthi_premium
Base plans:
  - monthly    (₹99/month)
  - quarterly  (₹239/3 months)
  - annual     (₹799/year)
Offer:
  - trial_7_days_new_user  (7-day free trial for new subscribers)
    Eligibility: new customers only
```

**Subscription model in code (Google Play new model):**
```dart
// Subscription product ID (ONE product in Play Console)
kSubscriptionProductId = 'prepsarthi_premium'

// Base Plan IDs (created under prepsarthi_premium in Play Console)
kBasePlanMonthly    = 'monthly'
kBasePlanQuarterly  = 'quarterly'
kBasePlanAnnual     = 'annual'

// Trial Offer ID (attached to each base plan)
kTrialOfferId       = 'trial_7_days_new_user'

// ⚠️ IMPORTANT: Do NOT create composite IDs like 'prepsarthi_premium:monthly'
// Google Play new subscription API separates product ID, base plan ID, and offer ID.
```

## 🔐 Subscription Security Flow

```
User taps Subscribe
    → buyNonConsumable() (paywall)
    → PurchaseStatus.purchased (app.dart stream)
    → PurchaseRepository.recordPurchaseToken()
        → Writes to purchaseVerificationRequests/{id}
    → InAppPurchase.completePurchase() (acknowledge)
    → Cloud Function: verifyPurchaseOnRequest triggers
        → androidPublisher.purchases.subscriptionsv2.get()
        → Writes verified entitlement to subscriptions/{uid}
    → app.dart: _syncEntitlement() after 3s delay
        → Reads subscriptions/{uid} (read-only for client)
        → activatePremiumFromServer() → local Isar update
```

## 🔥 Deploy Cloud Functions

```bash
cd firebase/functions
npm install
cd ../..
firebase deploy --only functions
firebase deploy --only firestore:rules
```

**Required Firebase services:**
- Authentication (Google Sign-In)
- Firestore (production mode)
- Functions (Blaze plan required)
- Crashlytics
- Analytics

**Service account for Play API:**
1. Google Cloud Console → IAM → Service Accounts
2. Grant "Android Publisher API" role
3. Download JSON key
4. `firebase functions:secrets:set GOOGLE_APPLICATION_CREDENTIALS`

## 📋 Play Store Submission Checklist

- [ ] `flutter analyze` — 0 errors
- [ ] `flutter build appbundle --release` — succeeds
- [ ] Tested on physical Android device (debug + release)
- [ ] Tested on Android 7, 10, 12, 14, 15
- [ ] Subscription purchase flow tested with test cards
- [ ] Restore purchases tested
- [ ] Subscription cancellation + re-check tested
- [ ] Crashlytics events arriving in Firebase console
- [ ] Privacy policy URL live: https://prepsarthi.app/privacy
- [ ] Terms URL live: https://prepsarthi.app/terms
- [ ] Play Console: subscription products created
- [ ] Play Console: Data safety form filled (Firebase, Google Sign-In, AI processing declared)
- [ ] Play Console: Content rating completed (Education)
- [ ] Internal testing track: tested by 5+ testers
- [ ] Pre-launch report: no crashes, no ANRs

## 💰 Free vs PrepSarthi Pro

| Feature | Free | Pro ₹99/mo |
|---|---|---|
| Study Planner | ✅ | ✅ |
| Daily Log | ✅ | ✅ |
| Pomodoro Timer | ✅ | ✅ |
| Spaced Revision | ✅ | ✅ |
| Streak & Achievements | ✅ | ✅ |
| AI SWOT Analysis | ❌ | ✅ |
| AI Pattern Report | ❌ | ✅ |
| AI Plan Regeneration | ❌ | ✅ |
| Exam Readiness Score | ❌ | ✅ |
| Daily Deficit Tracker | ❌ | ✅ |
| Backlog Recovery Engine | Basic | Full |
| Mock Test Analytics | ❌ | ✅ |
| PDF Progress Report | ❌ | ✅ |
| Chapter Mastery (5 levels) | Basic | Full |
| PYQ Tracker | ❌ | ✅ |
| Mistake Notebook | ❌ | ✅ |
| Weakness Radar | ❌ | ✅ |
| Parent Share Report | ❌ | ✅ |
