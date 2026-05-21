// lib/data/repositories/auth_repository.dart
//
// ✅ PRODUCTION FIX (v6): subscriptionPlan now stores basePlanId ONLY
//    ('monthly' | 'quarterly' | 'annual'). Previously stored the composite
//    string 'prepsarthi_premium:$basePlanId' which created confusion since
//    the rest of the codebase correctly uses basePlanId alone.
//
// ✅ Retained from v5: Removed updateSubscriptionOnCloud() — client NEVER writes
//    to subscriptions/{uid}. _syncSubscription reads using correct field names
//    that match what the Cloud Function writes: status, expiryDate, basePlanId.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import '../local/isar/isar_service.dart';
import '../local/isar/schemas/schemas.dart';

class AuthRepository {
  static final _auth         = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  static final _firestore    = FirebaseFirestore.instance;

  static Future<AuthResult> signInWithGoogle() async {
    try {
      if (Firebase.apps.isEmpty) {
        return AuthResult.error(
          'Firebase is not configured for this build. Add the real '
          'android/app/google-services.json for package com.prepsarthi.app '
          'and rebuild.',
        );
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return AuthResult.cancelled();

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final fbUser         = userCredential.user!;
      final localUser      = await _upsertLocalUser(fbUser);

      // Sync subscription from Firestore on login (catches re-installs)
      await _syncSubscription(fbUser.uid, localUser);

      return AuthResult.success(localUser);
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthRepo] FirebaseAuthException ${e.code}: ${e.message}');
      return AuthResult.error(_mapError(e.code));
    } on PlatformException catch (e) {
      debugPrint('[AuthRepo] PlatformException ${e.code}: ${e.message}');
      return AuthResult.error(_mapPlatformError(e));
    } catch (e) {
      debugPrint('[AuthRepo] Google sign-in error: $e');
      return AuthResult.error('Sign-in failed. Please try again.');
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  static Future<UserSchema?> getLocalUser() async {
    return IsarService.db.userSchemas.where().findFirst();
  }

  static Future<UserSchema> _upsertLocalUser(User fbUser) async {
    final db = IsarService.db;
    var user = await db.userSchemas.filter().uidEqualTo(fbUser.uid).findFirst();

    if (user == null) {
      user = UserSchema()
        ..uid                = fbUser.uid
        ..displayName        = fbUser.displayName ?? 'Aspirant'
        ..email              = fbUser.email
        ..photoUrl           = fbUser.photoURL
        ..onboardingComplete = false
        ..isPremium          = false
        ..trialUsed          = false
        ..currentStreak      = 0
        ..longestStreak      = 0
        ..planStartDate      = DateTime.now()
        ..examDate           = DateTime.now().add(const Duration(days: 365))
        ..createdAt          = DateTime.now()
        ..dailyStudyHours    = 6.0
        ..targetExam         = 'jee_main'
        ..examYear           = '2027';
    } else {
      user.displayName  = fbUser.displayName ?? user.displayName;
      user.email        = fbUser.email       ?? user.email;
      user.photoUrl     = fbUser.photoURL    ?? user.photoUrl;
      user.lastActiveAt = DateTime.now();
    }

    await db.writeTxn(() async => db.userSchemas.put(user!));
    return user;
  }

  /// ✅ Reads Firestore subscription using correct field names matching
  /// what the Cloud Function writes: status, expiryDate, basePlanId, trialUsed
  static Future<void> _syncSubscription(String uid, UserSchema user) async {
    try {
      final doc = await _firestore
          .collection('subscriptions')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 4));

      if (!doc.exists) return;
      final data   = doc.data()!;
      final status = data['status'] as String? ?? 'inactive';
      // ✅ Use same field names as Cloud Function
      final active = status == 'active' || status == 'in_grace_period' || status == 'canceled_active';
      final expiry = (data['expiryDate'] as Timestamp?)?.toDate();
      final basePlanId = data['basePlanId'] as String? ?? '';
      final trialUsed  = data['trialUsed']  as bool?   ?? false;

      final isExpired = expiry != null && expiry.isBefore(DateTime.now());
      final effective = active && !isExpired;

      if (effective != user.isPremium ||
          trialUsed  != user.trialUsed) {
        user.isPremium        = effective;
        user.premiumExpiry    = expiry;
        // ✅ PRODUCTION FIX (v6): Store basePlanId only — NOT 'prepsarthi_premium:monthly'.
        // productId (prepsarthi_premium) and basePlanId (monthly/quarterly/annual)
        // are separate concepts. Mixing them creates confusion everywhere.
        user.subscriptionPlan = basePlanId.isNotEmpty ? basePlanId : null;
        user.trialUsed        = trialUsed;
        final db = IsarService.db;
        await db.writeTxn(() async => db.userSchemas.put(user));
      }
    } catch (e) {
      debugPrint('[AuthRepo] Subscription sync error (non-critical): $e');
    }
  }

  static String _mapError(String code) {
    switch (code) {
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'sign_in_canceled':
        return 'Sign-in was cancelled.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled in Firebase Authentication yet.';
      case 'invalid-credential':
      case 'invalid-cert-hash':
      case 'app-not-authorized':
        return 'Google Sign-In is not fully configured for this Android build. '
            'Check package name, SHA-1/SHA-256, and Firebase Auth Google provider.';
      case 'account-exists-with-different-credential':
        return 'Account exists with a different sign-in method.';
      default:
        return 'Sign-in failed ($code). Please try again.';
    }
  }

  static String _mapPlatformError(PlatformException e) {
    final message = '${e.message ?? ''} ${e.details ?? ''}'.toLowerCase();
    final code = e.code.toLowerCase();

    if (code.contains('sign_in_canceled') || message.contains('12501')) {
      return 'Sign-in was cancelled.';
    }

    if (message.contains('network') || code.contains('network')) {
      return 'Network error. Please check your connection.';
    }

    if (message.contains('apiexception: 10') ||
        message.contains('developer_error') ||
        message.contains('12500') ||
        code.contains('sign_in_failed')) {
      return 'Google Sign-In is not fully configured for this Android build. '
          'Check google-services.json, package name com.prepsarthi.app, '
          'Firebase Auth Google provider, and SHA-1/SHA-256 for the signing key.';
    }

    if (message.contains('firebaseapp') || message.contains('default firebaseapp')) {
      return 'Firebase is not configured for this build. Add the real '
          'android/app/google-services.json and rebuild.';
    }

    return 'Sign-in failed. Please try again.';
  }
}

class AuthResult {
  final UserSchema? user;
  final String?     error;
  final bool        cancelled;

  const AuthResult._({this.user, this.error, this.cancelled = false});

  factory AuthResult.success(UserSchema u) => AuthResult._(user: u);
  factory AuthResult.error(String msg)     => AuthResult._(error: msg);
  factory AuthResult.cancelled()           => AuthResult._(cancelled: true);

  bool get isSuccess => user != null;
}
