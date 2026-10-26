import '../models/app_update_status.dart';

/// Contract for any store that can tell the latest published version.
abstract class StoreVersionSource {
  /// Returns null when the version cannot be determined.
  Future<StoreVersionInfo?> fetchLatestVersion();
}
