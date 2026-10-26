enum AppUpdateType { none, optional, mandatory }

/// Latest release reported by a store. Either [version] (public listings)
/// or [buildNumber] (Play internal/closed tracks, which hide the name).
class StoreVersionInfo {
  const StoreVersionInfo({
    this.version,
    this.buildNumber,
    required this.storeUrl,
  }) : assert(version != null || buildNumber != null);

  final String? version;
  final int? buildNumber;
  final String storeUrl;
}

class AppUpdateStatus {
  const AppUpdateStatus({
    required this.type,
    required this.currentVersion,
    this.storeVersion,
    this.storeBuildNumber,
    this.storeUrl,
  });

  const AppUpdateStatus.none(String currentVersion)
      : this(type: AppUpdateType.none, currentVersion: currentVersion);

  final AppUpdateType type;
  final String currentVersion;
  final String? storeVersion;
  final int? storeBuildNumber;
  final String? storeUrl;

  /// Identifies the offered release, to remember a dismissed optional prompt.
  String? get releaseKey => storeVersion ?? storeBuildNumber?.toString();

  bool get hasUpdate => type != AppUpdateType.none;
  bool get isMandatory => type == AppUpdateType.mandatory;
}
