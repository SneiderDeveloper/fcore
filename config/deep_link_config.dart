import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Deep links that external web flows (payments, account recovery, ...)
/// use to hand control back to the native app.
class DeepLinkConfig {
  static String get androidReturnUrl =>
      dotenv.env['ANDROID_REDIRECT_URL'] ?? 'abpassenger://payment';

  static String get iosReturnUrl =>
      dotenv.env['IOS_REDIRECT_URL'] ??
      'com.agi.ab.passengers.app://apple-callback';

  static List<String> get returnUrls => [androidReturnUrl, iosReturnUrl];
}
