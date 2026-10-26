import 'package:in_app_update/in_app_update.dart';

import '../models/app_update_status.dart';
import 'store_version_source.dart';

/// Asks Google Play itself, so it also sees internal/closed testing tracks.
/// Only answers when the app was installed from Play; otherwise it throws.
class PlayInAppVersionSource implements StoreVersionSource {
  PlayInAppVersionSource({required this.packageId});

  final String packageId;

  @override
  Future<StoreVersionInfo?> fetchLatestVersion() async {
    final info = await InAppUpdate.checkForUpdate();
    final code = info.availableVersionCode;

    if (info.updateAvailability != UpdateAvailability.updateAvailable ||
        code == null) {
      return null;
    }

    return StoreVersionInfo(
      buildNumber: code,
      storeUrl: 'https://play.google.com/store/apps/details?id=$packageId',
    );
  }
}
