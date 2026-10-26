/// Update policy. Store identifiers are read from the installed application.
class AppUpdateConfig {
  const AppUpdateConfig({
    this.forceUpdate = false,
    this.minimumRequiredVersion,
    this.storeCountry = 'us',
    this.requestTimeout = const Duration(seconds: 8),
  });

  /// When true, any newer store version blocks the app until updated.
  final bool forceUpdate;

  /// Installed versions below this one are blocked even if [forceUpdate]
  /// is false (e.g. "1.2.0").
  final String? minimumRequiredVersion;

  /// App Store storefront used by the iTunes lookup.
  final String storeCountry;

  final Duration requestTimeout;
}
