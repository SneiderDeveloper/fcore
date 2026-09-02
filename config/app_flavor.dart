import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppFlavor {
  dev,
  staging,
  prod,
}

class AppEnvironment {
  static AppFlavor _flavor = AppFlavor.prod;

  static AppFlavor get flavor => _flavor;

  static void initialize(AppFlavor value) {
    _flavor = value;
  }

  static String get name => _flavor.name;

  static String get displayName {
    return switch (_flavor) {
      AppFlavor.dev => 'Airport Butler Dev',
      AppFlavor.staging => 'Airport Butler Staging',
      AppFlavor.prod => 'Airport Butler',
    };
  }

  /// Each environment owns its bundle ID in .env.
  /// Example:
  /// APP_BUNDLE_ID_DEV=com.agi.ab.concierges.app.dev
  /// APP_BUNDLE_ID_STAGING=com.agi.ab.concierges.app.staging
  /// APP_BUNDLE_ID_PROD=com.agi.ab.concierges.app
  static String get bundleIdentifier {
    final value = switch (_flavor) {
      AppFlavor.dev => dotenv.env['APP_BUNDLE_ID_DEV'],
      AppFlavor.staging => dotenv.env['APP_BUNDLE_ID_STAGING'],
      AppFlavor.prod => dotenv.env['APP_BUNDLE_ID_PROD'],
    };

    if (value != null && value.isNotEmpty) {
      return value;
    }

    return const String.fromEnvironment(
      'APP_BUNDLE_ID',
      defaultValue: 'com.example.app',
    );
  }
}
