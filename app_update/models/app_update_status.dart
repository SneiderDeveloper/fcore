enum AppUpdateType { none, optional, mandatory }

class StoreVersionInfo {
  const StoreVersionInfo({required this.version, required this.storeUrl});

  final String version;
  final String storeUrl;
}

class AppUpdateStatus {
  const AppUpdateStatus({
    required this.type,
    required this.currentVersion,
    this.storeVersion,
    this.storeUrl,
  });

  const AppUpdateStatus.none(String currentVersion)
      : this(type: AppUpdateType.none, currentVersion: currentVersion);

  final AppUpdateType type;
  final String currentVersion;
  final String? storeVersion;
  final String? storeUrl;

  bool get hasUpdate => type != AppUpdateType.none;
  bool get isMandatory => type == AppUpdateType.mandatory;
}
