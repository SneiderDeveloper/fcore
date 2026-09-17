import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingHelper {
  static Future<String?> waitForApnsToken() async {
    try {
      if (!Platform.isIOS) {
        return getTokenSafely();
      }

      final messaging = FirebaseMessaging.instance;
      for (var attempt = 0; attempt < 10; attempt++) {
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          debugPrint('[FirebaseMessagingHelper] APNs token disponible');
          return apnsToken;
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      debugPrint('[FirebaseMessagingHelper] APNs token no disponible tras la espera');
      return null;
    } catch (e) {
      debugPrint('[FirebaseMessagingHelper] Error esperando APNs token: $e');
      return null;
    }
  }

  static Future<String?> getTokenSafely() async {
    try {
      final messaging = FirebaseMessaging.instance;

      if (Platform.isIOS) {
        final settings = await messaging.getNotificationSettings();

        if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
          final permission = await messaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          );

          if (permission.authorizationStatus == AuthorizationStatus.denied) {
            debugPrint('[FirebaseMessagingHelper] Permiso de notificaciones denegado');
            return null;
          }
        }

        final updatedSettings = await messaging.getNotificationSettings();
        if (updatedSettings.authorizationStatus == AuthorizationStatus.denied) {
          debugPrint('[FirebaseMessagingHelper] Notificaciones bloqueadas para iOS');
          return null;
        }

        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      final fcmToken = await messaging.getToken();
      debugPrint('[FirebaseMessagingHelper] FCM token: $fcmToken');
      return fcmToken;
    } catch (e) {
      debugPrint('[FirebaseMessagingHelper] Error al obtener el token: $e');
      return null;
    }
  }
}
