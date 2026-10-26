import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_update_status.dart';
import 'app_update_service.dart';
import 'app_update_store_launcher.dart';

/// Keeps update state independently of navigation and refreshes it on resume.
class AppUpdateCoordinator extends ChangeNotifier with WidgetsBindingObserver {
  AppUpdateCoordinator({
    required this.service,
    this.storeLauncher = const AppUpdateStoreLauncher(),
  });

  final AppUpdateService service;
  final AppUpdateStoreLauncher storeLauncher;

  bool _started = false;
  bool _disposed = false;
  bool _isChecking = false;
  bool _checkAgain = false;
  bool _isOpeningStore = false;
  AppUpdateStatus? _status;
  String? _storeError;

  AppUpdateStatus? get status => _status;
  bool get isOpeningStore => _isOpeningStore;
  String? get storeError => _storeError;

  void start() {
    if (_started || _disposed) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    unawaited(_check());
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_check());
  }

  Future<void> _check() async {
    if (_disposed) return;
    if (_isChecking) {
      _checkAgain = true;
      return;
    }
    _isChecking = true;
    try {
      final status = await service.check();
      if (_disposed) return;
      _status = status.hasUpdate ? status : null;
      notifyListeners();
    } catch (error, stackTrace) {
      // A failed refresh must not dismiss an update already detected.
      debugPrint('Unable to check store version: $error\n$stackTrace');
    } finally {
      _isChecking = false;
      if (_checkAgain && !_disposed) {
        _checkAgain = false;
        unawaited(_check());
      }
    }
  }

  Future<void> openStore() async {
    if (_disposed || _isOpeningStore) return;
    _isOpeningStore = true;
    _storeError = null;
    notifyListeners();
    try {
      final url = _status?.storeUrl;
      if (url == null) {
        throw StateError('Unable to open the update store URL.');
      }
      await storeLauncher.open(url);
    } catch (error, stackTrace) {
      debugPrint('Unable to open update store: $error\n$stackTrace');
      _storeError = 'Unable to open the store. Please try again.';
    } finally {
      _isOpeningStore = false;
      if (!_disposed) notifyListeners();
    }
  }
}
