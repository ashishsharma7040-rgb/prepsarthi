# PrepSarthi — Quick Start Guide

> ⚠️ This is a source code package, not a complete Flutter project.
> Follow the steps below to set up and run it.

## ✅ Fixed in v3 (All Critical Blockers Resolved)

| Fix | File |
|---|---|
| Broken AndroidManifest permission tag | `android/app/src/main/AndroidManifest.xml` |
| Wrong BacklogAdjuster imports (`../../../` → `../../`) | `lib/domain/usecases/backlog_adjuster.dart` |
| Local premium fallback removed | `lib/app.dart` |
| Paywall TODO removed — purchase flow complete | `lib/presentation/screens/settings/premium_paywall_screen.dart` |
| Duplicate IAP stream listener removed from paywall | `lib/presentation/screens/settings/premium_paywall_screen.dart` |
| Cloud Function updated to subscriptionsv2 API | `firebase/functions/index.js` |
| Product IDs unified: subscription product `prepsarthi_premium` with base plans `monthly/quarterly/annual` | All files |
| Trial tracking uses `trialUsed` field, not `isPremium` | `lib/data/local/isar/schemas/user_schema.dart` |
| Firestore `subscriptions` doc read-only for client | `firebase/firestore.rules` |
| `purchaseVerificationRequests` collection for token submission | `lib/data/repositories/purchase_repository.dart` |
| Crashlytics added | `lib/main.dart` + `pubspec.yaml` |

## 🚀 Steps to Run

### 1. Create Flutter project
```bash
flutter create prepsarthi --org com.prepsarthi --platforms android
cd prepsarthi
```

### 2. Copy all source files
Replace generated files with the files from this project.

### 3. Firebase setup
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure    # generates firebase_options.dart
```

Copy `google-services.json` → `android/app/`

### 4. Generate Isar schemas + get packages
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```
This generates the `.g.dart` files Isar requires.

### 5. Verify
```bash
flutter analyze          # must show 0 errors
flutter run              # test on device
flutter build appbundle --release  # test release build
```

### 6. Deploy backend
```bash
cd firebase/functions && npm install && cd ../..
firebase deploy --only firestore:rules
firebase deploy --only functions
```

## 🔑 Environment

- `google-services.json` → `android/app/`
- Firebase services: Auth (Google), Firestore, Functions, Crashlytics, Analytics
- Play Console: Create subscription product `prepsarthi_premium` with base plans `monthly`, `quarterly`, `annual` and offer `trial_7_days_new_user`
- Cloud Function needs Android Publisher API service account credentials

## ⚠️ Remaining TODOs (not blockers)

- Replace placeholder mock test performance (0.6) in `readiness_score.dart` with real `MockTestSchema` data once added
- Wire `deficit_card.dart` into your `dashboard_screen.dart`
- Wire `readiness_score_card.dart` into your `dashboard_screen.dart` with `isPremium` guard
- Add `firebase_crashlytics` to `firebase.json` for full symbol upload in CI
