# PrepSarthi — Improvement Summary

## What Was Changed

### NEW: Exam Readiness Score (0–100)
- File: `lib/presentation/providers/analytics_providers.dart`
- Weighted formula: syllabus completion (30%) + revision (20%) + test accuracy (20%) + consistency (20%) - weak chapter penalty (5%) - backlog penalty (5%)
- Shows score, status label, and personalised advice
- Displayed prominently on Dashboard and Today's Mission screen

### NEW: Weakness Radar
- File: `lib/presentation/screens/analytics/weakness_radar_screen.dart`
- Detects: weak chapters, high-priority backlog, low PYQ progress, low test accuracy, never-revised chapters
- Subject-level vulnerability bars (% needing attention per subject)
- Flag/unflag chapters as weak directly from the screen
- Route: `/analytics/weakness`

### NEW: Today Command Center
- File: `lib/presentation/screens/dashboard/today_command_center.dart`
- Shows: today's study target vs actual hours, readiness score, exam mode phase, today's chapters with tick-off, weakness alert, backlog recovery plan, quick action buttons
- Route: `/today`

### NEW: Mistake Notebook
- File: `lib/presentation/screens/mistakes/mistake_notebook_screen.dart`
- 6 mistake types: Conceptual, Calculation, Silly, Time Pressure, Forgot Formula, Guesswork
- Link mistake to chapter, add what went wrong and correct approach
- Mark mistakes as resolved
- Analytics tab showing breakdown by type with personalised advice
- Route: `/mistakes`

### NEW: Chapter Mastery Levels (0–7)
- File: `lib/presentation/screens/plan/chapter_mastery_screen.dart`
- 8-level mastery: Not Started → Theory Started → Theory Done → Questions Done → PYQs Done → Revision 1 Done → Revision 2 Done → Test Ready
- PYQ progress tracker (0→25%→50%→75%→100%→Mistakes Revised)
- Flag chapters as weak
- Subject and search filtering
- Route: `/plan/mastery`

### NEW: Backlog Recovery Engine
- File: `lib/presentation/providers/analytics_providers.dart` (`BacklogRecoveryPlan`)
- Identifies not-started high-weightage chapters
- Calculates days to recover at 40% of daily study hours
- Urgency levels: low / medium / high / critical
- Shown on dashboard and Today's Mission

### NEW: Exam Mode (Last 90/60/30/15/7 Days)
- File: `lib/presentation/providers/analytics_providers.dart` (`ExamMode`)
- Phase-specific recommendations based on days left to exam
- Automatically activates at 90, 60, 30, 15, 7 days
- Shown on Dashboard and Today's Mission screen

### IMPROVED: Dashboard Screen
- File: `lib/presentation/screens/dashboard/dashboard_screen.dart`
- Added: Today Mission banner with progress bar
- Added: Readiness Score card
- Added: Backlog alert banner (when urgency is high/critical)
- Added: Exam mode phase banner (when ≤ 90 days to exam)
- Added: Premium Feature Grid (Weakness Radar, Mistake Notebook, Chapter Mastery, Mock Tests)
- Countdown chip now shows urgency color (red <30 days, orange <90 days)

### NEW: Premium Paywall Screen (Play Store Compliant)
- File: `lib/presentation/screens/settings/premium_paywall_screen.dart`
- Real Google Play Billing integration (no fake/local unlock)
- 3 plans: Monthly (₹99), Quarterly (₹239), Annual (₹799)
- 7-day free trial via Play Console offer (eligibility checked server-side)
- Full compliance text: trial duration, post-trial price, auto-renewal, cancellation
- "Continue with free plan" and "Restore Purchase" always visible
- Close button always present (Google policy)
- If billing unavailable: shows clear error, no silent fail

### FIXED: Notification Helper
- File: `lib/core/utils/notification_helper.dart`
- Added missing `import 'package:timezone/data/latest.dart' as tz_data;`
- `tz_data.initializeTimeZones()` now compiles correctly

### FIXED: Android Permissions
- File: `android/app/src/main/AndroidManifest.xml`
- Removed `USE_EXACT_ALARM` (reserved for alarm-clock apps, causes Play policy rejection)
- Removed `SCHEDULE_EXACT_ALARM` (not needed for study reminder notifications)

### IMPROVED: Chapter Schema
- File: `lib/data/local/isar/schemas/chapter_schema.dart`
- Added: `masteryLevel` (0–7), `pyqProgress` (0–5), `conceptualMistakes`, `calculationMistakes`, `sillyMistakes`, `testAttempts`, `testCorrect`, `isWeakChapter`, `isPriorityRevision`
- Added computed getters: `masteryLabel`, `pyqProgressLabel`, `progressFraction`, `testAccuracy`
- Backward compatible (all new fields have defaults)

### NEW: Router Routes
- `/today` → Today Command Center
- `/analytics/weakness` → Weakness Radar
- `/mistakes` → Mistake Notebook
- `/plan/mastery` → Chapter Mastery
- `/premium` → Premium Paywall

### NEW: Play Store Release Checklist
- File: `docs/PLAYSTORE_RELEASE_CHECKLIST.md`
- Full step-by-step: build config, billing setup, Firestore rules, test scenarios, store listing

---

## Remaining Tasks Before Release

1. **Run build_runner** after schema changes:
   ```
   flutter clean && flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```
2. **Create Play Console subscription products** per the checklist
3. **Deploy Cloud Function** for purchase token verification (use subscriptionsv2 API)
4. **Deploy Firestore security rules** (no client writes to subscription status)
5. **Upload app bundle** to internal testing track
6. **Test all billing scenarios** with Google test accounts
7. **Write privacy policy page** at https://prepsarthi.app/privacy (mention Firebase, Isar, AI, billing)
8. **Fill Play Console Data Safety form**
9. **Take screenshots** of all new premium screens for store listing

## Play Console — Subscription Setup
Product ID: `prepsarthi_premium`
Base plans: `monthly` (₹99), `quarterly` (₹239), `annual` (₹799)
Trial offer ID: `trial_7_days_new_user` (7 days, new customers only)
