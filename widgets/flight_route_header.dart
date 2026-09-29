import 'package:flutter/material.dart';

import '../utils/helpers.dart';
import 'flight_airport_summary.dart';

class FlightRouteHeader extends StatelessWidget {
  const FlightRouteHeader({
    super.key,
    this.originCode,
    this.originName,
    this.destinationCode,
    this.destinationName,
    this.flightNumber,
    this.padding = const EdgeInsets.all(16),
  });

  final String? originCode;
  final String? originName;
  final String? destinationCode;
  final String? destinationName;
  final String? flightNumber;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: FlightAirportSummary(
              code: originCode,
              name: originName,
            ),
          ),
          _FlightNumberBadge(flightNumber: flightNumber),
          Expanded(
            child: FlightAirportSummary(
              code: destinationCode,
              name: destinationName,
              alignment: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlightNumberBadge extends StatelessWidget {
  const _FlightNumberBadge({this.flightNumber});

  final String? flightNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.flight, color: Color(0xFF162F48), size: 32),
        const SizedBox(height: 12),
        Text(
          flightNumber.orPlaceholder(),
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
