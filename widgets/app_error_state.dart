import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_button.dart';

const Color _kErrorColor = Color(0xFFEF5350);
const Color _kTitleColor = Color(0xFF162F48);
const Color _kDescriptionColor = Color(0xFF718499);

const double _kRetryButtonMinWidth = 160;
const double _kRetryButtonMinHeight = 48;

/// Fills the space of a view whose data could not be loaded. For a section
/// inside a list or form, use `AppErrorBanner`.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.description,
    this.onRetry,
  });

  final String message;

  /// Secondary line under [message].
  final String? description;

  /// Hides the "Retry" button when null.
  final VoidCallback? onRetry;

  String get _description =>
    description ??
    (onRetry != null
      ? 'Something went wrong on our side. Please try again.'
      : 'Something went wrong on our side. Please try again later.');

  @override
  Widget build(BuildContext context) {
    final Widget content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ErrorBadge(),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _kTitleColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _kDescriptionColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 28),
            _buildRetryButton(context),
          ],
        ],
      ),
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        // Honors the system "reduce motion" setting.
        child: MediaQuery.disableAnimationsOf(context)
          ? content
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - value)),
                  child: child,
                ),
              ),
              child: content,
            ),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    // AppButton has a fixed height, so it grows with the text scale to keep
    // the label from being clipped.
    final double labelHeight = MediaQuery.textScalerOf(context).scale(16) * 1.5;
    final double height = math.max(labelHeight + 24, _kRetryButtonMinHeight);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: _kRetryButtonMinWidth),
      child: AppButton(
        label: 'Retry',
        leadingIcon: Icons.refresh_rounded,
        width: null,
        height: height,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        onPressed: onRetry,
      ),
    );
  }
}

// Error icon on two soft concentric halos.
class _ErrorBadge extends StatelessWidget {
  const _ErrorBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _kErrorColor.withValues(alpha: 0.06),
      ),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _kErrorColor.withValues(alpha: 0.12),
        ),
        child: const Icon(
          Icons.error_outline_rounded,
          size: 36,
          color: _kErrorColor,
        ),
      ),
    );
  }
}
