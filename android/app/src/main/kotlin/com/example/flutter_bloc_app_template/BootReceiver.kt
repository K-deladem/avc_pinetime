package com.example.flutter_bloc_app_template

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import id.flutter.flutter_background_service.BackgroundService

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Démarrage de l'appareil détecté")

            try {
                // Démarrer le service en arrière-plan
                val serviceIntent = Intent(context, BackgroundService::class.java)
                context.startForegroundService(serviceIntent)

                Log.d("BootReceiver", "Service InfiniTime démarré avec succès")
            } catch (e: Exception) {
                Log.e("BootReceiver", "Erreur lors du démarrage du service: ${e.message}")
            }
        }
    }
}
