package com.example.el_karma_ph

import android.content.ActivityNotFoundException
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "el_karma_ph/whatsapp")
            .setMethodCallHandler { call, result ->
                if (call.method != "sendPdf") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val bytes = call.argument<ByteArray>("bytes")
                val fileName = call.argument<String>("fileName")
                val phone = call.argument<String>("phone")
                if (bytes == null || fileName == null || phone == null) {
                    result.error("bad_args", "Missing arguments", null)
                    return@setMethodCallHandler
                }
                try {
                    result.success(sendPdf(bytes, fileName, phone))
                } catch (e: Exception) {
                    result.error("failed", e.message, null)
                }
            }
    }

    private fun sendPdf(bytes: ByteArray, fileName: String, phone: String): String {
        val dir = File(cacheDir, "shared").apply { mkdirs() }
        val file = File(dir, fileName)
        file.writeBytes(bytes)
        val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "application/pdf"
            putExtra(Intent.EXTRA_STREAM, uri)
            putExtra("jid", "$phone@s.whatsapp.net")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        for (pkg in listOf("com.whatsapp", "com.whatsapp.w4b")) {
            intent.setPackage(pkg)
            try {
                startActivity(intent)
                return "ok"
            } catch (e: ActivityNotFoundException) {
            }
        }
        return "not_installed"
    }
}