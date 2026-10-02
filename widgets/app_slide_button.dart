import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Swipe-to-confirm button for actions that need a deliberate gesture.
/// The thumb must be dragged to the end of the track to trigger [onConfirmed];
/// it snaps back when released early or when [onConfirmed] resolves to false.
/// The track, trail, label and thumb are all derived from [color].
class AppSlideButton extends StatefulWidget {
  const AppSlideButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.enabled = true,
    this.color = const Color(0xFF475569),
    this.icon = Icons.arrow_forward_rounded,
    this.height = 56,
    this.borderRadius = 16,
  });

  final String label;
  final Future<bool> Function() onConfirmed;
  final bool enabled;
  final Color color;
  final IconData icon;
  final double height;
  final double borderRadius;

  @override
  State<AppSlideButton> createState() => _AppSlideButtonState();
}

class _AppSlideButtonState extends State<AppSlideButton>
    with SingleTickerProviderStateMixin {
  static const double _padding = 4;
  static const double _confirmThreshold = 0.85;

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  bool _isSubmitting = false;

  bool get _canDrag => widget.enabled && !_isSubmitting;
  double get _thumbSize => widget.height - _padding * 2;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (!_canDrag) return;
    _progress.value += details.primaryDelta! / maxDrag;
  }

  Future<void> _onDragEnd(DragEndDetails _) async {
    if (!_canDrag) return;

    if (_progress.value < _confirmThreshold) {
      _progress.animateBack(0, curve: Curves.easeOutCubic);
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);
    await _progress.animateTo(1, curve: Curves.easeOutCubic);

    final bool confirmed = await widget.onConfirmed();
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    if (!confirmed) _progress.animateBack(0, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius innerRadius = BorderRadius.circular(widget.borderRadius - _padding);

    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxDrag = constraints.maxWidth - _thumbSize - _padding * 2;

          return AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              final double value = _progress.value;

              return Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Filled trail behind the thumb.
                    Positioned(
                      left: _padding,
                      top: _padding,
                      bottom: _padding,
                      width: _thumbSize + maxDrag * value,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.15),
                          borderRadius: innerRadius,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      left: _thumbSize + _padding,
                      child: Center(
                        child: Opacity(
                          opacity: (1 - value * 1.5).clamp(0, 1),
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _padding + maxDrag * value,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) => _onDragUpdate(details, maxDrag),
                        onHorizontalDragEnd: _onDragEnd,
                        child: Container(
                          width: _thumbSize,
                          height: _thumbSize,
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: innerRadius,
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Icon(widget.icon, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
