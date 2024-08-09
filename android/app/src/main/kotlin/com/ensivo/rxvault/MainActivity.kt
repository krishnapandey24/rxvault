package com.ensivo.rxvault

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.app.DownloadManager

class MainActivity : FlutterActivity() {
    private val channel = "com.ensivo/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "openDownloadFolder" -> {
                    openDownloadFolder()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openDownloadFolder() {
        startActivity(Intent(DownloadManager.ACTION_VIEW_DOWNLOADS))
    }

}
