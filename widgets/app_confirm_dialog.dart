import 'package:flutter/material.dart';
import '../utils/helpers.dart';
import 'app_button.dart';

/// Modal genérica de confirmación: mensaje + botones confirmar/cancelar.
///
/// No conoce ninguna regla de negocio: quien la usa decide qué hacer al
/// confirmar mediante [onConfirm]. Se cierra con `true` al confirmar y con
/// `false` al cancelar.
class AppConfirmDialog extends StatefulWidget {
  const AppConfirmDialog({
    super.key,
    required this.message,
    this.title,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.errorMessage = 'Something went wrong, please try again',
  });

  final String message;
  final String? title;
  final String confirmLabel;
  final String cancelLabel;

  /// Acción a ejecutar antes de cerrar. Mientras corre, los botones quedan
  /// deshabilitados; si lanza un error la modal sigue abierta.
  final Future<void> Function()? onConfirm;
  final String errorMessage;

  static Future<bool?> show(
    BuildContext context, {
    required String message,
    String? title,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    Future<void> Function()? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => AppConfirmDialog(
        message: message,
        title: title,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<AppConfirmDialog> createState() => _AppConfirmDialogState();
}

class _AppConfirmDialogState extends State<AppConfirmDialog> {
  static const Color titleColor = Color(0xFF1A2B47);
  static const Color messageColor = Color(0xFF475569);

  bool _isLoading = false;

  Future<void> _onConfirm() async {
    setState(() => _isLoading = true);
    try {
      await widget.onConfirm?.call();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('AppConfirmDialog onConfirm Error: $e');
      showNativeSnackBar(widget.errorMessage, Colors.redAccent);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;

    return PopScope(
      canPop: !_isLoading,
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
              if (title != null && title.isNotEmpty) ...[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: titleColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: messageColor, fontSize: 16),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: widget.cancelLabel,
                      variant: AppButtonVariant.outlined,
                      onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: widget.confirmLabel,
                      isLoading: _isLoading,
                      onPressed: _onConfirm,
                    ),
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
