import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FirebaseRuntimeDiagnostics {
  static const String firebaseNotInitializedMessage =
      'Firebase is not initialized for this build.';
  static const String oauthClientMissingMessage =
      'Google Sign-In OAuth client is missing. Enable Google provider, add '
      'SHA-1/SHA-256, download fresh google-services.json, update Codemagic '
      'secret, rebuild.';
  static const String signingCertificateMissingMessage =
      "Google Sign-In failed because this APK signing certificate is not "
      "registered in Firebase. Add this build's SHA-1/SHA-256 in Firebase "
      'and rebuild.';

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
    );
  }

  String toClipboardText({
    String? lastAuthErrorCode,
    String? lastAuthErrorMessage,
    String? lastAuthErrorDetails,
  }) {
    return [
      'packageName: ${packageName ?? 'unknown'}',
      'firebaseInitialized: $firebaseInitialized',
      'projectId: ${projectId ?? 'missing'}',
      'appIdPresent: $appIdPresent',
      'apiKeyPresent: $apiKeyPresent',
      'defaultWebClientIdPresent: ${defaultWebClientIdPresent ?? 'unknown'}',
      'googleAppIdResourcePresent: ${googleAppIdResourcePresent ?? 'unknown'}',
      'googleApiKeyResourcePresent: ${googleApiKeyResourcePresent ?? 'unknown'}',
      'lastAuthErrorCode: ${lastAuthErrorCode ?? 'none'}',
      'lastAuthErrorMessage: ${lastAuthErrorMessage ?? 'none'}',
      'lastAuthErrorDetails: ${lastAuthErrorDetails ?? 'none'}',
      'diagnosticsError: ${diagnosticsError ?? 'none'}',
    ].join('\n');
  }
}
