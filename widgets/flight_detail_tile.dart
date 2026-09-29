import 'package:flutter/material.dart';

import '../utils/helpers.dart';

class FlightDetailTile extends StatelessWidget {
  const FlightDetailTile({
    super.key,
    required this.label,
    this.value,
  });

  const FlightDetailTile.flight({Key? key, String? flightNumber})
    : this(key: key, label: 'Flight', value: flightNumber);

  const FlightDetailTile.gate({Key? key, String? gate})
    : this(key: key, label: 'Gate:', value: gate);

  const FlightDetailTile.seat({Key? key, String? seat})
    : this(key: key, label: 'Seat', value: seat);

  const FlightDetailTile.scheduledTime({
    Key? key,
    String? time,
    bool isArrival = false,
  }) : this(
    key: key,
    label: isArrival ? 'Scheduled Arrival:' : 'Scheduled Departure:',
    value: time,
  );

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDE3EA)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF718499),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.orPlaceholder(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF40556C),
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
