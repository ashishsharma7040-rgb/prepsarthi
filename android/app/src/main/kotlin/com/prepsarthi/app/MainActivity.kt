package com.prepsarthi.app

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "prepsarthi/firebase_diagnostics"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getFirebaseDiagnostics") {
                var sha1: String? = null
                var sha256: String? = null
                var shaError: String? = null

                try {
                    val certBytes = getSigningCertBytes()
                    sha1 = certBytes?.let { hashCert(it, "SHA-1") }
                    sha256 = certBytes?.let { hashCert(it, "SHA-256") }
                } catch (e: Exception) {
                    sha1 = null
                    sha256 = null
                    shaError = e.message
                }

                result.success(
                    mapOf(
                        "packageName" to applicationContext.packageName,
                        "defaultWebClientIdPresent" to resourcePresent("default_web_client_id"),
                        "googleAppIdPresent" to resourcePresent("google_app_id"),
                        "googleApiKeyPresent" to resourcePresent("google_api_key"),
                        "apkSha1" to (sha1 ?: "unavailable"),
                        "apkSha256" to (sha256 ?: "unavailable"),
                        "shaExtractionError" to (shaError ?: "none"),
                    )
                )
            } else {
                result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun getSigningCertBytes(): ByteArray? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val info = packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNING_CERTIFICATES
            )
            val signingInfo = info.signingInfo ?: return null
            val signatures = if (signingInfo.hasMultipleSigners()) {
                signingInfo.apkContentsSigners
            } else {
                signingInfo.signingCertificateHistory
            }
            signatures?.firstOrNull()?.toByteArray()
        } else {
            val info = packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNATURES
            )
            info.signatures?.firstOrNull()?.toByteArray()
        }
    }

    private fun hashCert(certBytes: ByteArray, algorithm: String): String {
        val digest = MessageDigest.getInstance(algorithm).digest(certBytes)
        return digest.joinToString(":") { byte -> "%02X".format(byte) }
    }

    private fun resourcePresent(name: String): Boolean {
        val resourceId = resources.getIdentifier(name, "string", applicationContext.packageName)
        if (resourceId == 0) return false
        return runCatching { getString(resourceId) }
            .getOrNull()
            ?.isNotBlank() == true
    }
}
