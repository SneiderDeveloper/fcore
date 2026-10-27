import 'package:dio/dio.dart';

import '../models/app_update_status.dart';
import 'store_version_source.dart';

/// Reads the published version straight from the Google Play listing page.
class GooglePlayVersionSource implements StoreVersionSource {
  GooglePlayVersionSource({
    required this.packageId,
    required Duration timeout,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: timeout,
              receiveTimeout: timeout,
              responseType: ResponseType.plain,
              headers: const {'User-Agent': 'Mozilla/5.0'},
            ));

  final String packageId;
  final Dio _dio;

  static final RegExp _versionPattern = RegExp(r'\[\[\["(\d+(?:\.\d+)+)"\]\]');

  @override
  Future<StoreVersionInfo?> fetchLatestVersion() async {
    final response = await _dio.get<String>(
      'https://play.google.com/store/apps/details',
      queryParameters: {'id': packageId, 'hl': 'en', 'gl': 'US'},
    );

    final version = _versionPattern.firstMatch(response.data ?? '')?.group(1);
    if (version == null) {
      throw const FormatException('Google Play version not found in listing.');
    }

    return StoreVersionInfo(
      version: version,
      storeUrl: 'https://play.google.com/store/apps/details?id=$packageId',
    );
  }
}
