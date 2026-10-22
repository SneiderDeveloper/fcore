import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showCloseButton = true,
    this.canClose = true,
    this.onClose,
    this.padding = const EdgeInsets.fromLTRB(24, 16, 24, 24),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final bool showCloseButton;
  final bool canClose;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry padding;

  static const Color _titleColor = Color(0xFF162F48);
  static const Color _subtitleColor = Color(0xFF6B7682);

  bool get _hasTitle => title != null && title!.isNotEmpty;
  bool get _hasSubtitle => subtitle != null && subtitle!.isNotEmpty;
  bool get _hasHeader => _hasTitle || _hasSubtitle || showCloseButton;

  Widget _buildCloseButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close, color: Colors.grey),
      tooltip: 'Close',
      onPressed: canClose
        ? (onClose ?? () => Navigator.of(context).pop())
        : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasTitle)
          Row(
            children: [
              Expanded(
                child: Text(
                  title!,
                  style: const TextStyle(
                    color: _titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showCloseButton) ...[
                const SizedBox(width: 8),
                _buildCloseButton(context),
              ],
            ],
          )
        else if (showCloseButton)
          Align(
            alignment: Alignment.centerRight,
            child: _buildCloseButton(context),
          ),
        if (_hasSubtitle) ...[
          // The close button's 48px tap target already adds space below the
          // title, so a smaller gap keeps the visual spacing balanced.
          SizedBox(height: _hasTitle ? 4 : 0),
          Text(
            subtitle!,
            style: const TextStyle(color: _subtitleColor, fontSize: 14),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canClose,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hasHeader) _buildHeader(context),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
