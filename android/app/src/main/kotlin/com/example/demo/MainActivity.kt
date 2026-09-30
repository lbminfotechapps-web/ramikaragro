package com.lbm.solufine

import android.net.TrafficStats
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "developer_options_checker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "solufine/network_traffic")
            .setMethodCallHandler { call, result ->
                if (call.method == "readBytes") {
                    val rx = TrafficStats.getTotalRxBytes()
                    val tx = TrafficStats.getTotalTxBytes()
                    result.success(if (rx < 0 || tx < 0) null else rx + tx)
                } else {
                    result.notImplemented()
                }
            }


        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "isDeveloperOptionsEnabled" -> {

                    val enabled =
                        Settings.Global.getInt(
                            contentResolver,
                            Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                            0
                        ) != 0

                    result.success(enabled)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}