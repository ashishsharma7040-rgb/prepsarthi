import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FirebaseRuntimeDiagnostics {
  static const String firebaseNotInitializedMessage =
      'Firebase is not initialized. Add google-services.json to Codemagic '
      'and rebuild.';
  static const String oauthClientMissingMessage =
      'Google Sign-In OAuth client is missing.\n'
      '1. Add SHA-1 + SHA-256 to Firebase Console.\n'
      '2. Re-download google-services.json.\n'
      '3. Update GOOGLE_SERVICES_JSON_B64 in Codemagic.\n'
      '4. Rebuild.';
  static const String signingCertificateMissingMessage =
      "This APK's signing certificate is not registered in Firebase.\n"
      'Copy the Firebase diagnostics from the login screen to get the exact '
      'SHA-1 / SHA-256 to add to Firebase Console.';

  static const MethodChannel _channel =
      MethodChannel('prepsarthi/firebase_diagnostics');

  final bool firebaseInitialized;
  final String? packageName;
  final String? projectId;
  final bool appIdPresent;
  final bool apiKeyPresent;
  final bool? defaultWebClientIdPresent;
  final bool? googleAppIdResourcePresent;
  final bool? googleApiKeyResourcePresent;
  final String? diagnosticsError;
  final String? apkSha1;
  final String? apkSha256;
  final String? shaExtractionError;

  const FirebaseRuntimeDiagnostics({
    required this.firebaseInitialized,
    required this.packageName,
    required this.projectId,
    required this.appIdPresent,
    required this.apiKeyPresent,
    required this.defaultWebClientIdPresent,
    required this.googleAppIdResourcePresent,
    required this.googleApiKeyResourcePresent,
    required this.diagnosticsError,
    this.apkSha1,
    this.apkSha256,
    this.shaExtractionError,
  });

  static Future<FirebaseRuntimeDiagnostics> collect() async {
    final firebaseInitialized = Firebase.apps.isNotEmpty;
    String? packageName;
    String? projectId;
    var appIdPresent = false;
    var apiKeyPresent = false;
    bool? defaultWebClientIdPresent;
    bool? googleAppIdResourcePresent;
    bool? googleApiKeyResourcePresent;
    String? diagnosticsError;
    String? apkSha1;
    String? apkSha256;
    String? shaExtractionError;

    if (firebaseInitialized) {
      final options = Firebase.app().options;
      projectId = options.projectId;
      appIdPresent = options.appId.isNotEmpty;
      apiKeyPresent = options.apiKey.isNotEmpty;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _channel.invokeMapMethod<String, dynamic>(
          'getFirebaseDiagnostics',
        );
        packageName = result?['packageName'] as String?;
        defaultWebClientIdPresent =
            result?['defaultWebClientIdPresent'] as bool?;
        googleAppIdResourcePresent = result?['googleAppIdPresent'] as bool?;
        googleApiKeyResourcePresent = result?['googleApiKeyPresent'] as bool?;
        final rawSha1 = result?['apkSha1'] as String?;
        final rawSha256 = result?['apkSha256'] as String?;
        apkSha1 = (rawSha1 != null && rawSha1 != 'unavailable') ? rawSha1 : null;
        apkSha256 =
            (rawSha256 != null && rawSha256 != 'unavailable') ? rawSha256 : null;
        final rawShaError = result?['shaExtractionError'] as String?;
        shaExtractionError =
            (rawShaError != null && rawShaError != 'none') ? rawShaError : null;
      } catch (error) {
        diagnosticsError = error.toString();
      }
    }

    return FirebaseRuntimeDiagnostics(
      firebaseInitialized: firebaseInitialized,
      packageName: packageName,
      projectId: projectId,
      appIdPresent: appIdPresent,
      apiKeyPresent: apiKeyPresent,
      defaultWebClientIdPresent: defaultWebClientIdPresent,
      googleAppIdResourcePresent: googleAppIdResourcePresent,
      googleApiKeyResourcePresent: googleApiKeyResourcePresent,
      diagnosticsError: diagnosticsError,
      apkSha1: apkSha1,
      apkSha256: apkSha256,
      shaExtractionError: shaExtractionError,
    );
  }

  String toClipboardText({
    String? lastAuthErrorCode,
    String? lastAuthErrorMessage,
    String? lastAuthErrorDetails,
  }) {
    return [
      '=== PrepSarthi Firebase Diagnostics ===',
      'packageName: ${packageName ?? 'unknown'}',
      'firebaseInitialized: $firebaseInitialized',
      'projectId: ${projectId ?? 'missing'}',
      'appIdPresent: $appIdPresent',
      'apiKeyPresent: $apiKeyPresent',
      'defaultWebClientIdPresent: ${defaultWebClientIdPresent ?? 'unknown'}',
      'googleAppIdResourcePresent: ${googleAppIdResourcePresent ?? 'unknown'}',
      'googleApiKeyResourcePresent: ${googleApiKeyResourcePresent ?? 'unknown'}',
      '',
      '=== APK Signing Certificate (ADD THESE TO FIREBASE) ===',
      'apkSha1: ${apkSha1 ?? 'unavailable (see shaExtractionError)'}',
      'apkSha256: ${apkSha256 ?? 'unavailable (see shaExtractionError)'}',
      if (shaExtractionError != null)
        'shaExtractionError: $shaExtractionError',
      '',
      '=== Last Auth Error ===',
      'lastAuthErrorCode: ${lastAuthErrorCode ?? 'none'}',
      'lastAuthErrorMessage: ${lastAuthErrorMessage ?? 'none'}',
      'lastAuthErrorDetails: ${lastAuthErrorDetails ?? 'none'}',
      'diagnosticsError: ${diagnosticsError ?? 'none'}',
      '',
      'Fix for ApiException:10:',
      '1. Copy apkSha1 and apkSha256 above.',
      '2. Add both SHA fingerprints in Firebase Console for Android app com.prepsarthi.app.',
      '3. Download fresh google-services.json.',
      '4. Update GOOGLE_SERVICES_JSON_B64 in Codemagic.',
      '5. Rebuild and reinstall the APK.',
    ].join('\n');
  }
}
