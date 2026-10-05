import 'package:flutter/material.dart';

import '../utils/helpers.dart';

class FlightAirportSummary extends StatelessWidget {
  const FlightAirportSummary({
    super.key,
    this.code,
    this.name,
    this.alignment = CrossAxisAlignment.start,
  });

  final String? code;
  final String? name;
  final CrossAxisAlignment alignment;

  TextAlign get _textAlign =>
    alignment == CrossAxisAlignment.end ? TextAlign.end : TextAlign.start;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          code.orPlaceholder(),
          style: const TextStyle(
            color: Color(0xFF162F48),
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          name.orPlaceholder(),
          textAlign: _textAlign,
          style: const TextStyle(
            color: Color(0xFF718499),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
