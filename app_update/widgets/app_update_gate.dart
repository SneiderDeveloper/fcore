import 'package:flutter/material.dart';

import '../services/app_update_coordinator.dart';
import 'app_update_dialog.dart';

/// Place in MaterialApp.builder to keep the update above every router page.
class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({
    super.key,
    required this.coordinator,
    required this.backButtonDispatcher,
    required this.child,
  });

  final AppUpdateCoordinator coordinator;
  final BackButtonDispatcher backButtonDispatcher;
  final Widget child;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  late ChildBackButtonDispatcher _backButtonDispatcher;

  @override
  void initState() {
    super.initState();
    _attachBackButtonDispatcher();
  }

  void _attachBackButtonDispatcher() {
    _backButtonDispatcher =
        widget.backButtonDispatcher.createChildBackButtonDispatcher()
          ..addCallback(_onBackButtonPressed);
  }

  Future<bool> _onBackButtonPressed() async =>
      widget.coordinator.status != null;

  @override
  void didUpdateWidget(covariant AppUpdateGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backButtonDispatcher != widget.backButtonDispatcher) {
      _backButtonDispatcher.removeCallback(_onBackButtonPressed);
      oldWidget.backButtonDispatcher.forget(_backButtonDispatcher);
      _attachBackButtonDispatcher();
    }
  }

  @override
  void dispose() {
    _backButtonDispatcher.removeCallback(_onBackButtonPressed);
    widget.backButtonDispatcher.forget(_backButtonDispatcher);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.coordinator,
      builder: (context, _) {
        final coordinator = widget.coordinator;
        final status = coordinator.status;
        final blocked = status != null;
        if (blocked) _backButtonDispatcher.takePriority();

        return Stack(
          fit: StackFit.expand,
          children: [
            ExcludeFocus(
              excluding: blocked,
              child: ExcludeSemantics(
                excluding: blocked,
                child: IgnorePointer(ignoring: blocked, child: widget.child),
              ),
            ),
            if (status != null) ...[
              ModalBarrier(
                dismissible: false,
                color: Colors.black.withValues(alpha: 0.5),
              ),
              AppUpdateDialog(
                status: status,
                onUpdate: coordinator.openStore,
                isOpeningStore: coordinator.isOpeningStore,
                errorMessage: coordinator.storeError,
              ),
            ],
          ],
        );
      },
    );
  }
}
