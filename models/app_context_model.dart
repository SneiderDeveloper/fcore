import 'app_context_auth_provider_model.dart';

class AppContext {
  final int id;
  final String name;
  final String alias;
  final String version;
  final String? description;
  final bool isActive;
  final bool allowLocalLogin;
  final Map<String, dynamic> settings;
  final String? appleHtmlCallback;
  final List<dynamic> allSettings;
  final Map<String, bool> permissions;
  final Object? configs;
  final List<AppContextAuthProvider> authProviders;
  final Map<String, dynamic> rawData;

  AppContext.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      name = json['name'] as String,
      alias = json['alias'] as String,
      version = json['version'] as String,
      description = json['description'] as String?,
      isActive = json['isActive'] as bool,
      allowLocalLogin = json['allowLocalLogin'] as bool,
      settings = Map<String, dynamic>.unmodifiable(
        json['settings'] as Map<String, dynamic>,
      ),
      appleHtmlCallback = json['appleHtmlCallback'] as String?,
      allSettings = List<dynamic>.unmodifiable(json['allSettings'] as List),
      permissions = Map<String, bool>.unmodifiable(
        Map<String, bool>.from(json['permissions'] as Map),
      ),
      configs = json['configs'],
      authProviders = List<AppContextAuthProvider>.unmodifiable(
        (json['authProviders'] as List).map(
          (item) =>
              AppContextAuthProvider.fromJson(item as Map<String, dynamic>),
        ),
      ),
      rawData = Map<String, dynamic>.unmodifiable(json);
}
