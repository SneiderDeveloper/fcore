import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_update_config.dart';
import '../models/app_update_status.dart';
import '../sources/app_store_version_source.dart';
import '../sources/fallback_version_source.dart';
import '../sources/google_play_version_source.dart';
import '../sources/play_in_app_version_source.dart';
import '../sources/store_version_source.dart';
import '../utils/version_comparator.dart';

/// Decides whether the installed app needs an update. Never throws: any
/// failure resolves to [AppUpdateType.none] so it can't block the app.
class AppUpdateService {
  AppUpdateService({required this.config, StoreVersionSource? source})
      : _source = source ?? _defaultSource(config);

  final AppUpdateConfig config;
  final StoreVersionSource? _source;

  static StoreVersionSource? _defaultSource(AppUpdateConfig config) {
    if (Platform.isAndroid) {
      return FallbackVersionSource([
        PlayInAppVersionSource(packageId: config.androidPackageId),
        GooglePlayVersionSource(
          packageId: config.androidPackageId,
          timeout: config.requestTimeout,
        ),
      ]);
    }
    if (Platform.isIOS) {
      return AppStoreVersionSource(
        bundleId: config.iosBundleId,
        country: config.storeCountry,
        timeout: config.requestTimeout,
      );
    }
    return null;
  }

  Future<AppUpdateStatus> check() async {
    final package = await PackageInfo.fromPlatform();
    final source = _source;
    if (source == null) return AppUpdateStatus.none(package.version);

    try {
      final store = await source.fetchLatestVersion();
      if (store == null || !_isNewer(package, store)) {
        return AppUpdateStatus.none(package.version);
      }

      return AppUpdateStatus(
        type: _resolveType(package.version),
        currentVersion: package.version,
        storeVersion: store.version,
        storeBuildNumber: store.buildNumber,
        storeUrl: store.storeUrl,
      );
    } catch (error) {
      debugPrint('Unable to check store version: $error');
      return AppUpdateStatus.none(package.version);
    }
  }

  bool _isNewer(PackageInfo installed, StoreVersionInfo store) {
    final build = store.buildNumber;
    if (build != null) {
      return (int.tryParse(installed.buildNumber) ?? 0) < build;
    }
    return VersionComparator.isLowerThan(installed.version, store.version!);
  }

  AppUpdateType _resolveType(String current) {
    final minimum = config.minimumRequiredVersion;
    final belowMinimum =
        minimum != null && VersionComparator.isLowerThan(current, minimum);

    return config.forceUpdate || belowMinimum
        ? AppUpdateType.mandatory
        : AppUpdateType.optional;
  }
}
