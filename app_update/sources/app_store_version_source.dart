import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/app_update_status.dart';
import 'store_version_source.dart';

/// Reads the published version from the public iTunes Lookup API.
class AppStoreVersionSource implements StoreVersionSource {
  AppStoreVersionSource({
    required this.bundleId,
    required this.country,
    required Duration timeout,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: timeout,
              receiveTimeout: timeout,
              responseType: ResponseType.plain,
            ));

  final String bundleId;
  final String country;
  final Dio _dio;

  @override
  Future<StoreVersionInfo?> fetchLatestVersion() async {
    final response = await _dio.get<String>(
      'https://itunes.apple.com/lookup',
      queryParameters: {
        'bundleId': bundleId,
        'country': country,
        't': DateTime.now().millisecondsSinceEpoch,
      },
    );

    final body = jsonDecode(response.data ?? '{}') as Map<String, dynamic>;
    final results = body['results'];
    if (results is! List || results.isEmpty) {
      throw StateError('App Store listing not found for $bundleId in $country.');
    }

    final app = results.first as Map<String, dynamic>;
    final version = app['version'] as String?;
    final url = app['trackViewUrl'] as String?;
    if (version == null || url == null) {
      throw const FormatException('App Store version or URL missing.');
    }

    return StoreVersionInfo(version: version, storeUrl: url);
  }
}
