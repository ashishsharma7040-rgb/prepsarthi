package com.prepsarthi.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "prepsarthi/firebase_diagnostics"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getFirebaseDiagnostics") {
                result.success(
                    mapOf(
                        "packageName" to applicationContext.packageName,
                        "defaultWebClientIdPresent" to resourcePresent("default_web_client_id"),
                        "googleAppIdPresent" to resourcePresent("google_app_id"),
                        "googleApiKeyPresent" to resourcePresent("google_api_key")
                    )
                )
            } else {
                result.notImplemented()
            }
        }
    }

    private fun resourcePresent(name: String): Boolean {
        val resourceId = resources.getIdentifier(name, "string", applicationContext.packageName)
        if (resourceId == 0) return false
        return runCatching { getString(resourceId) }
            .getOrNull()
            ?.isNotBlank() == true
    }
}
