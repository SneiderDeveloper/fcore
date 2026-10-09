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
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileWidth =
              (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
              crossAxisCount;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (
                var start = 0;
                start < children.length;
                start += crossAxisCount
              ) ...[
                if (start > 0) SizedBox(height: spacing),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (
                        var offset = 0;
                        offset < crossAxisCount;
                        offset++
                      ) ...[
                        if (offset > 0) SizedBox(width: spacing),
                        Expanded(
                          child: start + offset < children.length
                              ? ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: tileWidth / childAspectRatio,
                                  ),
                                  child: children[start + offset],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
