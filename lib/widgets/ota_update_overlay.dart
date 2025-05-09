import 'package:flutter/material.dart';

import '../cubits/mdb_cubits.dart';
import '../state/vehicle.dart';
import '../utils/ota_utils.dart';

class OtaUpdateOverlay extends StatelessWidget {
  const OtaUpdateOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the vehicle state and OTA status
    final vehicleState = VehicleSync.watch(context).state;
    final otaStatusString = OtaSync.watch(context).otaStatus;
    final otaStatus = mapOtaStatus(otaStatusString);

    // Check if we should show the overlay
    if (!isOtaActive(otaStatusString) || !isVehicleStateAllowingOta(vehicleState)) {
      return Container(); // Don't show anything
    }

    // Get the appropriate display mode
    final displayMode = getOtaDisplayMode(vehicleState, otaStatus);

    // If display mode is none, don't show anything
    if (displayMode == OtaDisplayMode.none) {
      return Container();
    }

    final statusText = getOtaStatusText(otaStatus);
    final isReadyToDrive = vehicleState == ScooterState.readyToDrive;
    final isParked = vehicleState == ScooterState.parked;

    // For ready-to-drive mode with minimal overlay
    if (displayMode == OtaDisplayMode.minimal && isReadyToDrive) {
      return Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else {
      // Full-screen overlay
      return Container(
        color: isParked ? Colors.black.withOpacity(0.7) : Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
