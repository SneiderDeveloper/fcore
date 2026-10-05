/// Detects whether a URL loaded in a web view points to one of the
/// app's redirect (deep link) URLs.
class RedirectMatcher {
  RedirectMatcher(List<String> redirectUrls)
    : _redirectUrls = redirectUrls.map(_normalize).toList(),
      _redirectUris = redirectUrls.map(Uri.tryParse).whereType<Uri>().toList();

  final List<String> _redirectUrls;
  final List<Uri> _redirectUris;

  static final RegExp _intentSchemePattern = RegExp(
    r'scheme=([^;]+)',
    caseSensitive: false,
  );

  bool get isEmpty => _redirectUrls.isEmpty;

  bool matches(String url) {
    return _matchesAsText(url) || _matchesAsUri(url);
  }

  /// Whether [url] uses the scheme of any redirect URL, even if the rest
  /// of the URL does not match.
  bool hasRedirectScheme(String url) {
    final scheme = Uri.tryParse(url)?.scheme.toLowerCase();
    if (scheme == null || scheme.isEmpty) return false;

    return _redirectUris.any((uri) => uri.scheme.toLowerCase() == scheme);
  }

  bool _matchesAsText(String url) {
    final normalized = _normalize(url);
    final decoded = _normalize(_tryDecode(url));

    return _redirectUrls.any(
      (redirect) =>
          normalized.startsWith(redirect) || decoded.contains(redirect),
    );
  }

  bool _matchesAsUri(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final host = uri.host.toLowerCase();
    final scheme = _effectiveScheme(uri, url);

    return _redirectUris.any(
      (redirect) =>
          redirect.scheme.toLowerCase() == scheme &&
          redirect.host.toLowerCase() == host,
    );
  }

  /// Android web views can surface deep links as `intent://` URLs, where
  /// the real scheme travels inside the `scheme=` fragment parameter.
  String _effectiveScheme(Uri uri, String rawUrl) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'intent') return scheme;

    final intentScheme = _intentSchemePattern.firstMatch(rawUrl)?.group(1);
    return intentScheme?.toLowerCase() ?? scheme;
  }

  static String _normalize(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.endsWith('/')
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
  }

  static String _tryDecode(String value) {
    try {
      return Uri.decodeFull(value);
    } on ArgumentError {
      return value;
    }
  }
}
