package com.example.sgsra_mobile

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.sgsra_mobile/telefono"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "llamar") {
                val numero = call.argument<String>("numero")
                if (numero != null) {
                    val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:${numero.trim()}"))
                    startActivity(intent)
                    result.success(true)
                } else {
                    result.error("NUMERO_NULO", "El número no puede ser nulo", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
