import 'package:flutter/foundation.dart';

import '../models/settings_model.dart';
import 'base_api_service.dart';

class SettingsService extends BaseApiService {
  Future<List<AppSetting>> getAppSettings(String appName) async {
    debugPrint('[SettingsService] Getting app settings...');
    debugPrint('[SettingsService] App name: $appName');

    try {
      final response = await index(
        '/isite/v1/app-contexts/$appName/settings',
        config: {'refresh': true},
      );

      debugPrint('[SettingsService] Response: $response');

      if (response != null && response['data'] != null) {
        final settings = (response['data'] as List)
            .map((item) => AppSetting.fromJson(item))
            .toList();

        debugPrint(
          '[SettingsService] Settings loaded successfully: ${settings.length}',
        );

        return settings;
      }

      debugPrint('[SettingsService] No settings found in response.');

      return [];
    } catch (error, stackTrace) {
      debugPrint('[SettingsService] Error getting app settings: $error');
      debugPrint('[SettingsService] Stack trace: $stackTrace');
      rethrow;
    }
  }
}