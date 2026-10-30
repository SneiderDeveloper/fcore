import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({ 
    super.key, 
    required this.slot,
    this.isSelected = false,
    this.boxShadow,
  });

  final Widget slot;
  final bool isSelected;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    final card = Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: isSelected
          ? const BorderSide(color: Color(0xFFC4ECFF), width: 4)
          : BorderSide.none,
      ),
      elevation: boxShadow == null ? 8 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      margin: boxShadow == null ? null : EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: slot,
      )
    );
    if (boxShadow == null) return card;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: boxShadow,
        ),
        child: card,
      ),
    );
  }
}