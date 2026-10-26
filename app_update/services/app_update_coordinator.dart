import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_update_status.dart';
import '../widgets/app_update_dialog.dart';
import 'app_update_service.dart';

/// Runs the check on start and on every resume, and presents the dialog.
/// Attach with [start] and release with [dispose].
class AppUpdateCoordinator with WidgetsBindingObserver {
  AppUpdateCoordinator({
    required this.service,
    required this.navigatorKey,
  });

  final AppUpdateService service;
  final GlobalKey<NavigatorState> navigatorKey;

  bool _isChecking = false;
  bool _isDialogOpen = false;
  String? _dismissedRelease;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkAndPresent());
  }

  void dispose() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_checkAndPresent());
  }

  Future<void> _checkAndPresent() async {
    if (_isChecking || _isDialogOpen) return;
    _isChecking = true;
    try {
      final status = await service.check();
      if (!status.hasUpdate) return;
      if (!status.isMandatory && status.releaseKey == _dismissedRelease) {
        return;
      }
      await _present(status);
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _present(AppUpdateStatus status) async {
    final overlayContext = navigatorKey.currentState?.overlay?.context;
    if (overlayContext == null || !overlayContext.mounted) return;

    _isDialogOpen = true;
    await showDialog<void>(
      context: overlayContext,
      barrierDismissible: !status.isMandatory,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => AppUpdateDialog(
        status: status,
        onUpdate: () => _openStore(status.storeUrl),
      ),
    );
    _isDialogOpen = false;

    if (!status.isMandatory) _dismissedRelease = status.releaseKey;
  }

  Future<void> _openStore(String? url) async {
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
