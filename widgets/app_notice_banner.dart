import 'package:flutter/material.dart';

enum AppNoticeBannerVariant { info, warning }

/// Inline banner used to give the user a short, non-blocking notice: an
/// explanation, a caveat or a heads-up about the content next to it.
class AppNoticeBanner extends StatelessWidget {
  const AppNoticeBanner({
    super.key,
    this.title,
    required this.message,
    this.variant = AppNoticeBannerVariant.info,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 14,
  });

  final String? title;
  final String message;
  final AppNoticeBannerVariant variant;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  bool get _isWarning => variant == AppNoticeBannerVariant.warning;

  Color get _backgroundColor =>
    backgroundColor ??
    (_isWarning ? const Color(0xFFFFF6E5) : const Color(0xFFE5F6FF));

  Color get _borderColor =>
    borderColor ??
    (_isWarning ? const Color(0xFFFFE0B2) : const Color(0xFFC4ECFF));

  Color get _iconColor =>
    iconColor ??
    (_isWarning ? const Color(0xFFFFAB40) : const Color(0xFF2292C7));

  IconData get _icon =>
    icon ??
    (_isWarning ? Icons.warning_amber_rounded : Icons.info_outline_rounded);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: _borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _icon,
            size: 22,
            color: _iconColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                      color: Color(0xFF162F48),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF40556C),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
