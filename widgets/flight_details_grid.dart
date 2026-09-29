import 'package:flutter/material.dart';

class FlightDetailsGrid extends StatelessWidget {
  const FlightDetailsGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = 10,
    this.childAspectRatio = 2.2,
    this.padding = const EdgeInsets.all(16),
  });

  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: padding,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
