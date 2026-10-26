/// Project-specific settings for the update check. Reusable across apps:
/// only this object changes from one project to another.
class AppUpdateConfig {
  const AppUpdateConfig({
    required this.androidPackageId,
    required this.iosBundleId,
    this.forceUpdate = false,
    this.minimumRequiredVersion,
    this.storeCountry = 'us',
    this.requestTimeout = const Duration(seconds: 8),
  });

  final String androidPackageId;
  final String iosBundleId;

  /// When true, any newer store version blocks the app until updated.
  final bool forceUpdate;

  /// Installed versions below this one are blocked even if [forceUpdate]
  /// is false (e.g. "1.2.0").
  final String? minimumRequiredVersion;

  /// App Store storefront used by the iTunes lookup.
  final String storeCountry;

  final Duration requestTimeout;
}
