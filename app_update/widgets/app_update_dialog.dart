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
    this.laterLabel = 'Later',
  });

  final AppUpdateStatus status;
  final VoidCallback onUpdate;
  final String title;
  final String optionalMessage;
  final String mandatoryMessage;
  final String updateLabel;
  final String laterLabel;

  static const Color _titleColor = Color(0xFF1A2B47);
  static const Color _messageColor = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    final mandatory = status.isMandatory;

    return PopScope(
      canPop: !mandatory,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
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
              const SizedBox(height: 28),
              Row(
                children: [
                  if (!mandatory) ...[
                    Expanded(
                      child: AppButton(
                        label: laterLabel,
                        variant: AppButtonVariant.outlined,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: AppButton(label: updateLabel, onPressed: onUpdate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
