import '../models/settings_model.dart';
import 'base_api_service.dart';

class SettingsService extends BaseApiService {
  Future<List<AppSetting>> getAppSettings(String appName) async {
    final response = await index('/isite/v1/app-contexts/$appName/settings');
    if (response != null && response['data'] != null) {
      return (response['data'] as List)
          .map((item) => AppSetting.fromJson(item))
          .toList();
    }
    return [];
  }
}
