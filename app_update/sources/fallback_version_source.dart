import 'package:flutter/foundation.dart';

import '../models/app_update_status.dart';
import 'store_version_source.dart';

/// Tries each source in order. A source that returns (even null, meaning
/// "no update") is authoritative; only a thrown error hands over to the next
/// one. This keeps e.g. Play's per-track answer from being overridden by a
/// public listing when the app was installed from Play.
class FallbackVersionSource implements StoreVersionSource {
  FallbackVersionSource(this.sources);

  final List<StoreVersionSource> sources;

  @override
  Future<StoreVersionInfo?> fetchLatestVersion() async {
    for (final source in sources) {
      try {
        return await source.fetchLatestVersion();
      } catch (error) {
        debugPrint('${source.runtimeType} failed: $error');
        if (identical(source, sources.last)) rethrow;
      }
    }
    throw StateError('No update sources configured.');
  }
}
