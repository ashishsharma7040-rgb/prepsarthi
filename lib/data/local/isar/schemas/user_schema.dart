// lib/data/local/isar/schemas/user_schema.dart
//
// ✅ ADDED: trialUsed, trialStartedAt, trialEndedAt
// Trial eligibility is tracked separately from isPremium.
// A user who finished a trial (trialUsed=true) should NOT see trial offer again.

import 'package:isar/isar.dart';
part 'user_schema.g.dart';

@Collection()
class UserSchema {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;

  late String displayName;
  String? email;
  String? photoUrl;

  // Onboarding
  String targetExam = 'jee';
  String examYear = '2026';
  double dailyStudyHours = 6.0;
  bool onboardingComplete = false;
  DateTime? planStartDate;
  DateTime? examDate;

  // CA Final — persisted attempt ('may' | 'november'). Only two real attempts
  // per year per ICAI calendar. Null for non-CA exams.
  String? caAttempt;

  // Subscription
  bool isPremium = false;
  DateTime? premiumExpiry;
  String? subscriptionPlan;   // e.g. 'monthly', 'quarterly', 'annual' (base plan ID)

  // ✅ Trial tracking (separate from isPremium — critical for correct trial logic)
  bool trialUsed = false;          // true once trial was ever started
  DateTime? trialStartedAt;
  DateTime? trialEndedAt;

  // Progress
  DateTime? createdAt;
  DateTime? lastActiveAt;
  int currentStreak = 0;
  int longestStreak = 0;
  DateTime? lastStudyDate;

  // Computed
  bool get isTrialEligible => !trialUsed && !isPremium;
  bool get hasActivePremium =>
      isPremium &&
      (premiumExpiry == null || premiumExpiry!.isAfter(DateTime.now()));
}
