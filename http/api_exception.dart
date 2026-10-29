/// An error response from the API.
//
class ApiException implements Exception {
  const ApiException({this.statusCode, this.message, this.data});

  /// Builds the exception from an error response, taking the message the
  /// backend sent in its body, when there is one.
  factory ApiException.fromResponse(int? statusCode, Object? data) =>
    ApiException(
      statusCode: statusCode,
      message: _messageFrom(data),
      data: data,
    );

  final int? statusCode;

  /// The message the backend sent with the error, ready to be shown. Null
  /// when the response didn't carry one.
  final String? message;

  /// The raw body of the error response.
  final Object? data;

  /// The backend message of [error] when it is an [ApiException], or null for
  /// any other error.
  static String? messageOf(Object error) =>
    error is ApiException ? error.message : null;

  static String? _messageFrom(Object? data) {
    if (data is! Map) return null;

    final messages = data['messages'];
    final first = messages is List && messages.isNotEmpty ? messages.first : null;
    final nested = data['data'];

    return _nonBlank(first is Map ? first['message'] : null) ??
      _nonBlank(data['message']) ??
      _nonBlank(nested is Map ? nested['message'] : null);
  }

  static String? _nonBlank(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;

  @override
  String toString() {
    final body = data;
    final detail =
      message ?? (body == null || body is Map ? 'Server error' : body.toString());
    return 'Exception: HTTP $statusCode - $detail';
  }
}
