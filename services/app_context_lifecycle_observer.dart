import 'dart:async';

import 'package:flutter/widgets.dart';

import '../providers/app_context_provider.dart';

class AppContextLifecycleObserver extends WidgetsBindingObserver {
  final AppContextProvider provider;
  final String appName;

  AppContextLifecycleObserver({required this.provider, required this.appName});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() async {
    try {
      await provider.init(appName);
    } catch (error) {
      debugPrint('Unable to refresh app context on lifecycle change: $error');
    }
  }
}
