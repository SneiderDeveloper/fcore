import '../models/app_context_model.dart';
import 'base_api_service.dart';

class AppContextService extends BaseApiService {
  Future<AppContext> getAppContext(String appName) async {
    if (appName != 'passenger-app' && appName != 'agent-app') {
      throw ArgumentError.value(
        appName,
        'appName',
        'Must be passenger-app or agent-app.',
      );
    }

    final response = await index(
      '/isite/v1/app-contexts/$appName',
      config: {
        'refresh': true,
        'params': {
          'filter': {'field': 'alias'},
          'include': 'authProviders',
        },
      },
    );

    if (response is! Map<String, dynamic> ||
        response['data'] is! Map<String, dynamic>) {
      throw const FormatException('Invalid app context response.');
    }

    return AppContext.fromJson(response['data'] as Map<String, dynamic>);
  }
}
