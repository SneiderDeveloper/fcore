import 'package:flutter/material.dart';

class BuildSummaryRow extends StatelessWidget {
  const BuildSummaryRow({
    super.key,
    required this.label,
    required this.value, 
    this.color = const Color(0xFF162F48),
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF718499),
            fontSize: 14,
            fontWeight: FontWeight.w500
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600
            ),
          ),
        )
      ],
    );
  }
}