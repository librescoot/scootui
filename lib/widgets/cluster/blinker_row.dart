import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/mdb_cubits.dart';
import '../../state/vehicle.dart';
import '../indicators/indicator_lights.dart';

/// Blinker row for cluster and CarPlay screens.
/// Manages animation restart keys when blinker state changes.
class BlinkerRow extends StatefulWidget {
  const BlinkerRow({super.key});

  @override
  State<BlinkerRow> createState() => _BlinkerRowState();
}

class _BlinkerRowState extends State<BlinkerRow> {
  Key _leftKey = UniqueKey();
  Key _rightKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VehicleSync, VehicleData>(
      listenWhen: (prev, curr) => prev.blinkerState != curr.blinkerState,
      listener: (context, state) {
        setState(() {
          _leftKey = UniqueKey();
          _rightKey = UniqueKey();
        });
      },
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
    // Hide single-side icon when overlay is handling it
    final useOverlay = overlayActive && vehicleState.blinkerState == BlinkerState.left;
    if (!showIcon || useOverlay) return const SizedBox(width: 56);
    return SizedBox(
      key: _leftKey,
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
      key: _rightKey,
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
