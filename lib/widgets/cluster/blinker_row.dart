import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/mdb_cubits.dart';
import '../../state/vehicle.dart';
import '../indicators/indicator_lights.dart';

/// Blinker row for cluster and CarPlay screens.
class BlinkerRow extends StatelessWidget {
  const BlinkerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleSync, VehicleData>(
      buildWhen: (prev, curr) => prev.blinkerState != curr.blinkerState,
      builder: (context, vehicleState) {
        final overlayActive = context.read<SettingsSync>().state.blinkerOverlayEnabled;
        return Row(
          children: [
            _buildLeft(vehicleState, overlayActive),
            const Expanded(child: SizedBox()),
            _buildRight(vehicleState, overlayActive),
          ],
        );
      },
    );
  }

  Widget _buildLeft(VehicleData vehicleState, bool overlayActive) {
    final showIcon = vehicleState.blinkerState == BlinkerState.left ||
        vehicleState.blinkerState == BlinkerState.both;
    final useOverlay = overlayActive && vehicleState.blinkerState == BlinkerState.left;
    if (!showIcon || useOverlay) return const SizedBox(width: 56);
    return SizedBox(
      key: ValueKey('left-${vehicleState.blinkerState}'),
      width: 56,
      height: 56,
      child: Center(
        child: Transform.scale(
          scale: 0.8,
          child: IndicatorLights.leftBlinker(vehicleState),
        ),
      ),
    );
  }

  Widget _buildRight(VehicleData vehicleState, bool overlayActive) {
    final showIcon = vehicleState.blinkerState == BlinkerState.right ||
        vehicleState.blinkerState == BlinkerState.both;
    final useOverlay = overlayActive && vehicleState.blinkerState == BlinkerState.right;
    if (!showIcon || useOverlay) return const SizedBox(width: 56);
    return SizedBox(
      key: ValueKey('right-${vehicleState.blinkerState}'),
      width: 56,
      height: 56,
      child: Center(
        child: Transform.scale(
          scale: 0.8,
          child: IndicatorLights.rightBlinker(vehicleState),
        ),
      ),
    );
  }
}
