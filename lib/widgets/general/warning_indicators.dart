import 'package:flutter/material.dart';

import '../../cubits/mdb_cubits.dart';
import 'indicator_lights.dart';

class WarningIndicators extends StatelessWidget {
  const WarningIndicators({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final state = VehicleSync.watch(context);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left turn signal
          IndicatorLights.leftBlinker(state),

          // Parking indicator
          IndicatorLights.parkingBrake(state),

          // Right turn signal
          IndicatorLights.rightBlinker(state),
        ],
      ),
    );
  }
}

