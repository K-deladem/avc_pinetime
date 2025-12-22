# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Background Service
-keep class id.flutter.flutter_background_service.** { *; }

# Bluetooth permissions
-keep class androidx.core.** { *; }

# Notifications
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.work.** { *; }

# Désactiver les avertissements pour les bibliothèques externes
-dontwarn com.dexterous.**
-dontwarn id.flutter.flutter_background_service.**