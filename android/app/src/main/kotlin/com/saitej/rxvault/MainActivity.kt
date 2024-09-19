package com.saitej.rxvault

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.app.DownloadManager

class MainActivity : FlutterActivity() {
    private val channel = "com.saitej/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "openDownloadFolder" -> {
                    openDownloadFolder()
                    result.success(null)
                }
                else -> {
                }
            }
        }
    }

    private fun openDownloadFolder() {
        try {
            startActivity(Intent(DownloadManager.ACTION_VIEW_DOWNLOADS))
        } catch (e: Exception) {
            print("exce;")
        }
    }

}
