import 'package:flutter/material.dart';

import '../../widgets/app_button.dart';
import '../models/app_update_status.dart';

class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({
    super.key,
    required this.status,
    required this.onUpdate,
    this.title = 'Update available',
    this.optionalMessage =
        'A new version of the app is available. Update now to get the latest improvements.',
    this.mandatoryMessage =
        'You must update the app to the latest version to keep using it.',
    this.updateLabel = 'Update',
    this.isOpeningStore = false,
    this.errorMessage,
  });

  final AppUpdateStatus status;
  final VoidCallback onUpdate;
  final String title;
  final String optionalMessage;
  final String mandatoryMessage;
  final String updateLabel;
  final bool isOpeningStore;
  final String? errorMessage;

  static const Color _titleColor = Color(0xFF1A2B47);
  static const Color _messageColor = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    final mandatory = status.isMandatory;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _titleColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  mandatory ? mandatoryMessage : optionalMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _messageColor, fontSize: 16),
                ),
                if (status.storeVersion != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'v${status.currentVersion} → v${status.storeVersion}',
                    style: const TextStyle(color: _messageColor, fontSize: 13),
                  ),
                ],
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                AppButton(
                  label: updateLabel,
                  isLoading: isOpeningStore,
                  onPressed: isOpeningStore ? null : onUpdate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
