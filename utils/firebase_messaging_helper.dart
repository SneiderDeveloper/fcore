import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingHelper {
  static Future<String?> getTokenSafely() async {
    if (Platform.isIOS) {
      final apnsToken = await _waitForApnsToken();
      if (apnsToken == null) {
        return null;
      }
    }

    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      final message = e.toString();
      if (Platform.isIOS && message.contains('apns-token-not-set')) {
        final apnsToken = await _waitForApnsToken();
        if (apnsToken == null) {
          return null;
        }
        return await FirebaseMessaging.instance.getToken();
      }
      rethrow;
    }
  }

  static Future<String?> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      try {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          return apnsToken;
        }
      } catch (_) {
        // Ignore APNS polling errors while the platform token is still being initialized.
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return null;
  }
}
