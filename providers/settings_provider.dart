import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  static final Map<String, dynamic> _settingsMap = {};
  final SettingsService _settingsService = SettingsService();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init(String appName) async {
    try {
      final settings = await _settingsService.getAppSettings(appName);
      _settingsMap.clear();
      for (var setting in settings) {
        _settingsMap[setting.name] = setting.value;
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings for $appName: $e');
      rethrow; // Re-throw to handle it in main.dart if necessary
    }
  }

  static dynamic getSetting(String name) {
    return _settingsMap[name];
  }

  void clear() {
    _settingsMap.clear();
    _isInitialized = false;
    notifyListeners();
  }
}

/// Global helper function to get settings
dynamic getSetting(String name) {
  return SettingsProvider.getSetting(name);
}
