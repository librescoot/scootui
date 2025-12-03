import 'package:flutter/material.dart';
import '../state/vehicle.dart';

class MaintenanceScreen extends StatelessWidget {
  final ScooterState? vehicleState;

  const MaintenanceScreen({super.key, this.vehicleState});

  String _formatStateName(ScooterState state) {
    final name = state.name;
    // Convert camelCase to separate words with hyphens
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => '-${match.group(1)!.toLowerCase()}',
    );
    // Remove leading hyphen if present
    return result.startsWith('-') ? result.substring(1) : result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          if (vehicleState != null)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _formatStateName(vehicleState!),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
