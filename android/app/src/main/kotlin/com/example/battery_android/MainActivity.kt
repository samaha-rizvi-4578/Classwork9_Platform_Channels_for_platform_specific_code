package com.example.battery_android

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES

class MainActivity: FlutterActivity() {
  private val CHANNEL = "fast.smd.dev/battery"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "getBatteryLevel" -> {
          val batteryLevel = getBatteryLevel()
          if (batteryLevel != -1) {
            result.success(batteryLevel)
          } else {
            result.error("UNAVAILABLE", "Battery level not available.", null)
          }
        }
        "getChargingStatus" -> {
          val chargingStatus = getChargingStatus()
          result.success(chargingStatus)
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun getBatteryLevel(): Int {
    val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
  }

  private fun getChargingStatus(): String {
    val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
    return when (status) {
      BatteryManager.BATTERY_STATUS_CHARGING -> "Charging"
      BatteryManager.BATTERY_STATUS_FULL -> "Full"
      else -> "Not Charging"
    }
  }
}