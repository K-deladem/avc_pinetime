package com.example.flutter_bloc_app_template

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Fix for GPU rendering issues on some devices (Xiaomi/Adreno)
        try {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
                WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
            )
        } catch (e: Exception) {
            println("Error setting hardware acceleration flag: ${e.message}")
        }

        createNotificationChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "infinitime_background_channel"
            val channelName = "InfiniTime Background Service"
            val channelDescription = "Notifications for InfiniTime background service"
            val importance = NotificationManager.IMPORTANCE_LOW

            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
}