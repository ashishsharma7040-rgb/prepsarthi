# PrepSarthi — Production Roadmap

> **Status after v6 fixes:** Closed Beta Ready.  
> This document tracks what must be done before Full Play Store Production release.

---

## 🔴 Required Before Full Production Release

### 1. Host Privacy and Terms Pages

The app's paywall references these URLs:
- `https://prepsarthi.app/privacy`
- `https://prepsarthi.app/terms`

The in-app screens (`PrivacyPolicyScreen`, `TermsOfServiceScreen`) are already complete
and serve as fallback. But Google Play **requires a publicly accessible URL** in the store listing.

**Action:**
- Deploy both pages (can be static HTML) to `prepsarthi.app`
- Verify both open without login in an incognito browser
- Include subscription auto-renewal, 7-day trial, and cancellation instructions on the terms page
- Include a data deletion method (email) on the privacy page

---

### 2. Run Flutter Release Build

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze          # must pass with 0 errors
flutter test             # all tests must pass
flutter build appbundle --release
```

The release build will **fail** with a clear error if `android/key.properties` is missing.  
Create it using the instructions in `android/app/build.gradle` before running.

---

### 3. Create and Store Release Keystore Securely

```bash
keytool -genkey -v \
  -keystore prepsarthi_release.jks \
  -alias prepsarthi \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000
```

Then create `android/key.properties`:
```
storeFile=../prepsarthi_release.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=prepsarthi
keyPassword=YOUR_KEY_PASSWORD
```

**Critical:** Add both `key.properties` and `*.jks` to `.gitignore`. Never commit secrets.  
Store the keystore in a password manager or secure vault (losing it means never updating the app).

---

### 4. Obfuscated Account ID for Purchase Security

For stronger production security, pass an obfuscated account ID when initiating purchases.
This lets Google Play and the Cloud Function tie a purchase token to a specific Firebase UID,
preventing token reuse across accounts.

In `premium_paywall_screen.dart`, when building `GooglePlayPurchaseParam`:

```dart
// TODO(production): Add obfuscated account ID
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

String _obfuscatedId() {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final bytes = utf8.encode(uid);
  return sha256.convert(bytes).toString().substring(0, 64);
}

// Then in buyNonConsumable / buySubscription:
final param = GooglePlayPurchaseParam(
  productDetails: details,
  obfuscatedAccountId: _obfuscatedId(),
);
```

In the Cloud Function, cross-reference `purchase.obfuscatedExternalAccountId` where available.

---

## 🟡 High Priority — Before Scaling (Post-Beta)

### 5. Migrate Test/Mistake Data from SharedPreferences to Isar

SharedPreferences is fine for small settings but not for user study data that
powers the Readiness Score. This data can be lost on app clear/reinstall.

**Create these Isar schemas:**

#### `MockTestSchema`
```dart
@collection
class MockTestSchema {
  Id id = Isar.autoIncrement;
  late String examName;
  late int totalMarks;
  late int obtainedMarks;
  late String subject;       // 'physics' | 'chemistry' | 'math' | 'biology'
  String? notes;
  late DateTime date;
  late DateTime createdAt;
}
```

#### `MistakeEntrySchema`
```dart
@collection
class MistakeEntrySchema {
  Id id = Isar.autoIncrement;
  late String subject;
  late String topic;
  late String description;
  late bool isResolved;
  DateTime? resolvedAt;
  late DateTime createdAt;
}
```

#### `PYQProgressSchema`
```dart
@collection
class PYQProgressSchema {
  Id id = Isar.autoIncrement;
  late String year;          // '2020' | '2021' | ...
  late String subject;
  late String paperId;
  late int correctCount;
  late int totalCount;
  late DateTime attemptedAt;
}
```

#### `ReadinessSnapshotSchema`
```dart
@collection
class ReadinessSnapshotSchema {
  Id id = Isar.autoIncrement;
  late int score;
  late String grade;
  late String breakdownJson;  // JSON of Map<String, double>
  late DateTime computedAt;
}
```

**Migration steps:**
1. Add schemas to `lib/data/local/isar/schemas/schemas.dart` barrel
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Update `IsarService.openDatabase()` to include new schemas in the open call
4. Update `test_score_screen.dart` to write `MockTestSchema` instead of SharedPrefs
5. Update `mistake_notebook_screen.dart` to write `MistakeEntrySchema` instead of SharedPrefs
6. Update `readiness_score.dart` to read from Isar instead of SharedPrefs
7. Write a one-time migration function that reads old SharedPrefs data and inserts into Isar

---

### 6. Daily Expiry Sweep — Verify Cloud Function Deployment

The Cloud Function `dailyExpiryCheck` runs at 18:30 UTC (midnight IST) and marks
expired subscriptions. Confirm it is deployed and visible in Firebase Console → Functions.

```bash
firebase deploy --only functions
firebase functions:log --only dailyExpiryCheck
```

---

## 🟢 Polish — Before Marketing Launch

### 7. Play Store Store Listing

- [ ] App icon (512×512 PNG, no alpha)
- [ ] Feature graphic (1024×500 PNG)
- [ ] At least 4 phone screenshots per language
- [ ] Short description (80 chars): "AI study planner for JEE & NEET aspirants"
- [ ] Full description mentions 7-day trial, AI features, no ads
- [ ] Content rating questionnaire completed
- [ ] Data safety form: declare Google Sign-In, Firestore, Vertex AI usage

### 8. Crashlytics / Analytics

Add Firebase Crashlytics for production crash reporting:
```yaml
# pubspec.yaml
firebase_crashlytics: ^4.x.x
```

```dart
// main.dart — after Firebase.initializeApp()
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

### 9. Notification Deep-Link Handling

Study reminders should deep-link into the daily log or today's plan.
Verify `notification_helper.dart` payload routing works after cold start.

---

## ✅ Completed in v5/v6

| Fix | Status |
|-----|--------|
| Product ID model (prepsarthi_premium + base plans) | ✅ v5 |
| Cloud Function uses subscriptionsv2.get | ✅ v5 |
| basePlanId / offerId extracted correctly | ✅ v5 |
| Client never writes to subscriptions/{uid} | ✅ v5 |
| Firestore rules block client subscription writes | ✅ v5 |
| Single purchaseStream listener at app root | ✅ v5 |
| completePurchase after token record | ✅ v5 |
| Blind markTrialStartedLocally() removed | ✅ **v6** |
| Trial state comes only from Firestore | ✅ **v6** |
| completePurchase after backend verification poll | ✅ **v6** |
| subscriptionPlan stores basePlanId only (not composite) | ✅ **v6** |
| Firestore users/{uid} rules split (read/create,update/delete) | ✅ **v6** |
| trialUsed blocked in client user doc writes | ✅ **v6** |
| Release signing fails hard without key.properties | ✅ **v6** |
| TermsOfServiceScreen (inline, no URL dependency) | ✅ **v6** |
| Privacy/terms URL fallback to in-app screens | ✅ **v6** |
| Production roadmap documented | ✅ **v6** |
