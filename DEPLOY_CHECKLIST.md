# PrepSarthi — Play Store Deploy Checklist
> This is the single authoritative checklist. It matches the actual code in v3.

## Phase 1 — Build (do this first, fix all errors before anything else)

```bash
flutter create prepsarthi --org com.prepsarthi --platforms android
cd prepsarthi
# Copy all files from this project
flutterfire configure          # generates firebase_options.dart
cp google-services.json android/app/
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze                # MUST be 0 errors, 0 warnings
flutter build appbundle --release
```

## Phase 2 — Firebase Setup

Services to enable in Firebase Console:
- [ ] Authentication → Sign-in method → Google (enabled)
- [ ] Firestore → Create database → Production mode
- [ ] Functions → Upgrade to Blaze plan
- [ ] Crashlytics → Enable
- [ ] Analytics → Enable

Deploy backend:
```bash
cd firebase/functions && npm install && cd ../..
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only functions
```

Verify Cloud Functions deployed:
- [ ] `verifyPurchaseOnRequest` — triggers on `purchaseVerificationRequests` write
- [ ] `dailyExpiryCheck` — scheduled daily at 18:30 UTC

## Phase 3 — Service Account for Google Play API

1. Google Cloud Console → IAM & Admin → Service Accounts
2. Find the Firebase service account: `firebase-adminsdk-xxxx@YOUR_PROJECT.iam.gserviceaccount.com`
3. Grant role: **Android Publisher API** (or use existing App Engine default service account)
4. Enable **Google Play Android Developer API** in Cloud Console → APIs & Services
5. In Play Console → Setup → API access → Link your Google Cloud project
6. Grant the service account access to the Play account

## Phase 4 — Play Console Setup

App details:
- App name: **PrepSarthi: JEE NEET Study Planner**
- Package name: `com.prepsarthi.app`
- Category: Education → Reference
- Content rating: Complete questionnaire (no violence/mature content)

Subscription product (create ONE product with multiple base plans):
```
Product ID: prepsarthi_premium
  Base plan: monthly   → ₹99/month,  billing period: 1 month
  Base plan: quarterly → ₹239/3 months, billing period: 3 months
  Base plan: annual    → ₹799/year,  billing period: 1 year

Offer (on each base plan):
  Offer ID: trial_7_days_new_user
  Free trial: 7 days
  Eligibility: New subscribers only (Google Play enforces this)
```

Store listing:
- [ ] Short description (80 chars): "AI-powered study planner for JEE Main, NEET UG & Class 12"
- [ ] Full description: mention Pomodoro, AI SWOT, spaced revision, readiness score, mistake notebook
- [ ] 8 screenshots (phone) — show dashboard, planner, AI report, readiness score
- [ ] Feature graphic 1024×500px
- [ ] Icon 512×512px

> ⚠️ **REQUIRED BEFORE PLAY STORE UPLOAD** — Live URLs for legal pages:
> - Privacy Policy: `https://prepsarthi.app/privacy` **must be live and accessible**
> - Terms of Use: `https://prepsarthi.app/terms` **must be live and accessible**
>
> These URLs are hardcoded in `premium_paywall_screen.dart` and shown to users.
> If your domain isn't ready, use a temporary public host:
> - Firebase Hosting: `firebase init hosting && firebase deploy`
> - GitHub Pages: Create a public repo with privacy.html and terms.html
> - Notion public page: Share publicly and use that URL
>
> Play Store also requires a privacy policy URL in the store listing.
> Both pages must clearly describe: data collected, how it's used, user rights.

## Phase 5 — Data Safety Form (Google Play)

Declare the following in Play Console → Policy → App content → Data safety:

| Data type | Collected | Shared | Purpose |
|---|---|---|---|
| Name | Yes | No | App functionality |
| Email | Yes | No | Account management |
| User IDs | Yes | No | App functionality |
| Purchase history | Yes | No | Subscription |
| App activity (study logs) | Yes | No | App functionality, analytics |
| Crash logs | Yes | No | App stability |

Third-party libraries sharing data:
- Firebase (Google) — analytics, crash reports, auth
- Google Play Billing — subscription payments
- Vertex AI / Gemini — AI-powered study insights

## Phase 6 — Pre-Launch Testing

```bash
# Internal testing track
# Add at least 5 testers in Play Console → Testing → Internal testing
flutter build appbundle --release
# Upload to Play Console → Internal testing → Create new release
```

Test checklist (on real Android device):
- [ ] Fresh install → onboarding flow → plan generation
- [ ] Google Sign-In works
- [ ] Study plan shows real chapters (not hardcoded)
- [ ] Log session → streak updates
- [ ] Mark chapter done → progress updates
- [ ] Pomodoro auto-logs session
- [ ] Revision schedule shows upcoming revisions
- [ ] Paywall opens → shows correct product IDs from Play
- [ ] Subscribe with test card → premium activates (check Firestore)
- [ ] Restore purchases → premium re-activates
- [ ] Cancel subscription → status updates on next app open
- [ ] AI SWOT report loads (with real Gemini key)
- [ ] PDF export works
- [ ] Notifications fire at scheduled time
- [ ] Dark mode works
- [ ] App survives being killed and re-opened (Isar data persists)
- [ ] Pre-launch report in Play Console: 0 crashes, 0 ANRs

## Phase 7 — Submission

- [ ] Version: 1.2.0+3 (versionCode=3 for first Play submission, increment if re-uploading)
- [ ] Release notes (English):
  ```
  PrepSarthi v1.2 — Your AI Study Partner for JEE, NEET & Class 12
  • AI-powered SWOT analysis and pattern reports
  • Exam Readiness Score (0-100) with actionable tips
  • Spaced revision scheduler (7/21/45 day intervals)
  • Chapter mastery tracker (8 levels)
  • Pomodoro timer with auto-logging
  • Daily deficit tracker
  • Mock test score tracker
  • PDF progress reports
  ```
- [ ] Submit for review
- [ ] Review time: 3-7 days for new apps

## Product IDs Reference (DO NOT CHANGE after going live)

> ⚠️ Google Play new subscription model: ONE product ID with separate base plans and offer IDs.
> Never create composite IDs like `prepsarthi_premium:monthly`.

| Play Console entity | ID | Price / Duration |
|---|---|---|
| Subscription product | `prepsarthi_premium` | (parent product) |
| Base plan — monthly | `monthly` | ₹99/month |
| Base plan — quarterly | `quarterly` | ₹239/3 months |
| Base plan — annual | `annual` | ₹799/year |
| Trial offer ID | `trial_7_days_new_user` | 7 days free (new users) |

**Code constants in `purchase_repository.dart`:**
```dart
kSubscriptionProductId = 'prepsarthi_premium'
kBasePlanMonthly       = 'monthly'
kBasePlanQuarterly     = 'quarterly'
kBasePlanAnnual        = 'annual'
kTrialOfferId          = 'trial_7_days_new_user'
```

## Firestore Collections Reference

| Collection | Who writes | Who reads |
|---|---|---|
| `subscriptions/{uid}` | Cloud Function only | Client (read) |
| `purchaseVerificationRequests/{id}` | Client (create only) | Cloud Function |
| `users/{uid}` | Client | Client |

