import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

enum TokenRefreshResult {
  success,
  /// The backend (or a locally expired/missing refresh token) definitively
  /// rejected the session. Tokens have been deleted.
  rejected,
  /// The refresh could not reach the backend (no internet, timeout, 5xx...).
  /// Tokens are preserved so the session survives until connectivity returns.
  unavailable,
}

/// Returns true when [error] means the backend could not be reached or did not
/// give a definitive answer (offline, timeout, 5xx). In these cases the local
/// session must be preserved.
bool isNetworkOrServerUnavailableError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.cancel:
        return true;
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        return status >= 500 || status == 408 || status == 429;
      case DioExceptionType.unknown:
        return error.response == null;
      case DioExceptionType.badCertificate:
        return false;
    }
  }

  // BaseApiService converts DioExceptions into plain Exceptions.
  final message = error.toString().toLowerCase();
  final httpStatus = RegExp(r'http (\d{3})').firstMatch(message);
  if (httpStatus != null) {
    final status = int.parse(httpStatus.group(1)!);
    return status >= 500 || status == 408 || status == 429;
  }
  return message.contains('no internet connection') ||
      message.contains('timeout') ||
      message.contains('socketexception') ||
      message.contains('failed host lookup') ||
      message.contains('connection refused') ||
      message.contains('connection reset') ||
      message.contains('connection closed') ||
      message.contains('network is unreachable') ||
      message.contains('connection error') ||
      message.contains('request cancelled');
}

class ApiClient {
  static const _tokenRefreshBuffer = Duration(seconds: 30);

  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;
  VoidCallback? onUnauthorized;
  bool _isHandlingUnauthorized = false;
  Future<TokenRefreshResult>? _refreshingToken;
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
      final result = await refreshTokenWithResult();
      if (result == TokenRefreshResult.rejected) {
        _notifyUnauthorized();
        handler.reject(
          DioException(
            requestOptions: options,
            message: 'Unable to refresh the access token',
          ),
        );
        return;
      }
      if (result == TokenRefreshResult.unavailable) {
        // Keep the session: the backend could not be reached.
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            message: 'No internet connection',
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

      final refreshResult = canRetry
          ? await refreshTokenWithResult()
          : TokenRefreshResult.rejected;

      if (refreshResult == TokenRefreshResult.unavailable) {
        // The refresh endpoint is unreachable; don't destroy the session.
        return handler.reject(
          DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.connectionError,
            message: 'No internet connection',
          ),
        );
      }

      if (refreshResult == TokenRefreshResult.success) {
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
    await _storage.delete(key: _cachedUserKey);
    await clearCache();
  }

  // ========================
  // Cached user (offline session restore)
  // ========================

  static const _cachedUserKey = 'cachedUser';

  Future<void> saveCachedUser(Map<String, dynamic> user) async {
    try {
      await _storage.write(key: _cachedUserKey, value: jsonEncode(user));
    } catch (e) {
      _logger.w('Unable to cache user data', error: e);
    }
  }

  Future<Map<String, dynamic>?> readCachedUser() async {
    try {
      final raw = await _storage.read(key: _cachedUserKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (e) {
      _logger.w('Unable to read cached user data', error: e);
      return null;
    }
  }

  Future<bool> refreshToken() async =>
      await refreshTokenWithResult() == TokenRefreshResult.success;

  Future<TokenRefreshResult> refreshTokenWithResult() async {
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

  Future<TokenRefreshResult> _refreshToken() async {
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
        return TokenRefreshResult.rejected;
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

      return TokenRefreshResult.success;
    } catch (e) {
      if (isNetworkOrServerUnavailableError(e)) {
        _logger.w('Token refresh unavailable (offline/server). Keeping session.',
            error: e);
        return TokenRefreshResult.unavailable;
      }
      _logger.e('Token refresh failed', error: e);
      await deleteTokens();
      return TokenRefreshResult.rejected;
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
