import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class ApiClient {
  static const _tokenRefreshBuffer = Duration(seconds: 30);

  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;
  VoidCallback? onUnauthorized;
  bool _isHandlingUnauthorized = false;
  Future<bool>? _refreshingToken;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  late final CacheOptions cacheOptions;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    final apiRoute = dotenv.env['API_ROUTE'] ?? '';
    cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.forceCache,
      priority: CachePriority.normal,
      maxStale: const Duration(hours: 1),
    );

    dio = Dio(
      BaseOptions(
        baseUrl: '$apiRoute/api',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    dio.interceptors.add(
      InterceptorsWrapper(onRequest: onRequest, onError: onError),
    );
  }

  // ========================
  // Interceptors
  // ========================

  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var token = await _storage.read(key: 'accessToken');
    if (token != null &&
        token.isNotEmpty &&
        options.extra['skipTokenRefresh'] != true &&
        await _isTokenExpiringSoon()) {
      final refreshed = await refreshToken();
      if (!refreshed) {
        _notifyUnauthorized();
        handler.reject(
          DioException(
            requestOptions: options,
            message: 'Unable to refresh the access token',
          ),
        );
        return;
      }
      token = await _storage.read(key: 'accessToken');
    }

    if (token != null &&
        token.isNotEmpty &&
        !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = token;
    }

    return handler.next(options);
  }

  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;
      final canRetry =
          requestOptions.extra['skipTokenRefresh'] != true &&
          requestOptions.extra['retriedAfterRefresh'] != true;

      if (canRetry && await refreshToken()) {
        try {
          final newToken = await _storage.read(key: 'accessToken');
          requestOptions.extra['retriedAfterRefresh'] = true;
          if (newToken != null && newToken.isNotEmpty) {
            requestOptions.headers['Authorization'] = newToken;
          } else {
            requestOptions.headers.remove('Authorization');
          }
          final response = await dio.fetch(requestOptions);
          return handler.resolve(response);
        } on DioException catch (retryError) {
          if (retryError.response?.statusCode == 401) {
            _notifyUnauthorized();
            return handler.reject(retryError);
          }
          return handler.next(retryError);
        }
      }

      _notifyUnauthorized();
      return handler.reject(err);
    }

    return handler.next(err);
  }

  void _notifyUnauthorized() {
    if (_isHandlingUnauthorized) return;
    setHandlingUnauthorized(true);
    onUnauthorized?.call();
  }

  // ========================
  // Token Handling
  // ========================

  Future<void> saveToken(
    String accessToken,
    DateTime expiresAt, {
    String? refreshToken,
    DateTime? refreshExpiresAt,
  }) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(
      key: 'expiresIn',
      value: expiresAt.toUtc().toIso8601String(),
    );
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: 'refreshToken', value: refreshToken);
    }
    if (refreshExpiresAt != null) {
      await _storage.write(
        key: 'refreshExpiresIn',
        value: refreshExpiresAt.toUtc().toIso8601String(),
      );
    }
  }

  Future<void> deleteTokens() async {
    // Resetear flag al eliminar tokens
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'expiresIn');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'refreshExpiresIn');
    await clearCache();
  }

  Future<bool> refreshToken() async {
    final activeRefresh = _refreshingToken;
    if (activeRefresh != null) return activeRefresh;

    final refresh = _refreshToken();
    _refreshingToken = refresh;
    return refresh.whenComplete(() {
      if (identical(_refreshingToken, refresh)) {
        _refreshingToken = null;
      }
    });
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      final refreshExpiresAt = await _storage.read(key: 'refreshExpiresIn');
      final parsedRefreshExpiration = DateTime.tryParse(
        refreshExpiresAt ?? '',
      )?.toUtc();
      if (refreshToken == null ||
          refreshToken.isEmpty ||
          parsedRefreshExpiration == null ||
          !parsedRefreshExpiration.isAfter(DateTime.now().toUtc())) {
        await deleteTokens();
        return false;
      }

      final currentAccessToken =
          await _storage.read(key: 'accessToken') ?? '';
      final bearerRefreshToken = refreshToken.startsWith('Bearer ')
          ? refreshToken
          : 'Bearer $refreshToken';

      final response = await dio.post(
        '/profile/v1/auth/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(
          extra: {'skipTokenRefresh': true},
          headers: {
            'x-bearer-token': currentAccessToken,
            'Authorization': bearerRefreshToken,
          },
        ),
      );

      final responseData = response.data;
      final data = responseData is Map && responseData['data'] is Map
          ? responseData['data']
          : responseData;

      if (data is! Map) {
        throw Exception('Invalid refresh token response');
      }
      final accessToken = data['userToken'] as String?;
      final expiresIso = data['expiresIn'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;
      final refreshExpiresIso = data['refreshExpiresIn'] as String?;

      if (accessToken == null || expiresIso == null) {
        throw Exception('Invalid refresh token response');
      }

      final expirationDate = DateTime.parse(expiresIso).toUtc();
      final refreshExpirationDate = refreshExpiresIso == null
          ? null
          : DateTime.parse(refreshExpiresIso).toUtc();
      await saveToken(
        accessToken,
        expirationDate,
        refreshToken: newRefreshToken ?? refreshToken,
        refreshExpiresAt: refreshExpirationDate ?? parsedRefreshExpiration,
      );

      return true;
    } catch (e) {
      _logger.e('Token refresh failed', error: e);
      await deleteTokens();
      return false;
    }
  }

  Future<bool> isTokenExpired() async {
    final expiresAtStr = await _storage.read(key: 'expiresIn');
    if (expiresAtStr == null) return true;

    final expiresAt = DateTime.tryParse(expiresAtStr)?.toUtc();
    if (expiresAt == null) return true;

    return DateTime.now().toUtc().isAfter(expiresAt);
  }

  Future<bool> _isTokenExpiringSoon() async {
    final expiresAtStr = await _storage.read(key: 'expiresIn');
    final expiresAt = DateTime.tryParse(expiresAtStr ?? '')?.toUtc();
    if (expiresAt == null) return true;

    final refreshDeadline = DateTime.now().toUtc().add(_tokenRefreshBuffer);
    return !expiresAt.isAfter(refreshDeadline);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<void> clearCache() async {
    await cacheOptions.store?.clean();
  }

  void setHandlingUnauthorized(bool value) {
    _isHandlingUnauthorized = value;
  }
}
