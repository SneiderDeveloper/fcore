import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateStoreLauncher {
  const AppUpdateStoreLauncher();

  Future<void> open(String storeUrl) async {
    final uri = Uri.parse(storeUrl);
    if (Platform.isAndroid && uri.host == 'play.google.com') {
      final packageId = uri.queryParameters['id'];
      if (packageId == null || packageId.isEmpty) {
        throw const FormatException('Google Play package ID is missing.');
      }
      final marketUri = Uri(
        scheme: 'market',
        host: 'details',
        queryParameters: {'id': packageId},
      );
      try {
        if (await launchUrl(marketUri, mode: LaunchMode.externalApplication)) {
          return;
        }
        debugPrint('Google Play app unavailable; opening the web listing.');
      } on PlatformException catch (error) {
        debugPrint('Unable to open Google Play app: $error');
      }
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Unable to open the update store URL.');
    }
  }
}
