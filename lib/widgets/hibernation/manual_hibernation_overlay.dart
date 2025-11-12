import 'dart:async';
import 'package:flutter/material.dart';

import '../../cubits/mdb_cubits.dart';
import '../../state/enums.dart';
import '../../state/vehicle.dart';

/// Overlay for manual hibernation flow - displays appropriate UI based on vehicle state
class ManualHibernationOverlay extends StatefulWidget {
  const ManualHibernationOverlay({super.key});

  @override
  State<ManualHibernationOverlay> createState() => _ManualHibernationOverlayState();
}

class _ManualHibernationOverlayState extends State<ManualHibernationOverlay> {
  Timer? _countdownTimer;
  int _remainingSeconds = 20;
  bool _wasBrakeHeld = false;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _updateBrakeTimer(bool bothBrakesHeld, ScooterState state) {
    final isHibernationState = state == ScooterState.waitingHibernation ||
        state == ScooterState.waitingHibernationAdvanced;

    if (bothBrakesHeld && isHibernationState) {
      if (!_wasBrakeHeld) {
        _wasBrakeHeld = true;
        _remainingSeconds = 20;
        _countdownTimer?.cancel();
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _remainingSeconds--;
              if (_remainingSeconds <= 0) {
                _countdownTimer?.cancel();
              }
            });
          } else {
            timer.cancel();
          }
        });
      }
    } else {
      // Brakes released, reset
      if (_wasBrakeHeld) {
        _wasBrakeHeld = false;
        _remainingSeconds = 20;
        _countdownTimer?.cancel();
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleData = VehicleSync.watch(context);
    final vehicleState = vehicleData.state;
    final bothBrakesHeld = vehicleData.brakeLeft == Toggle.on &&
                           vehicleData.brakeRight == Toggle.on;

    _updateBrakeTimer(bothBrakesHeld, vehicleState);

    // Only show overlay for hibernation states
    if (!_isHibernationState(vehicleState)) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Center(
          child: _buildContent(vehicleState),
        ),
      ),
    );
  }

  bool _isHibernationState(ScooterState state) {
    return state == ScooterState.waitingHibernation ||
        state == ScooterState.waitingHibernationAdvanced ||
        state == ScooterState.waitingHibernationSeatbox ||
        state == ScooterState.waitingHibernationConfirm;
  }

  Widget _buildContent(ScooterState state) {
    switch (state) {
      case ScooterState.waitingHibernation:
      case ScooterState.waitingHibernationAdvanced:
        return _buildHibernationScreen(_remainingSeconds);
      case ScooterState.waitingHibernationSeatbox:
        return _buildSeatboxNotification();
      case ScooterState.waitingHibernationConfirm:
        return _buildConfirmationScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHibernationScreen(int remainingSeconds) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.power_settings_new,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 24),
          const Text(
            'Manual Hibernation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap keycard to confirm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            remainingSeconds == 0
                ? 'Keep holding brakes to force'
                : remainingSeconds < 20
                    ? 'Hold both brakes for ${remainingSeconds}s to force'
                    : 'Or hold both brakes for 20s to force',
            style: TextStyle(
              color: remainingSeconds < 20 ? Colors.orange : Colors.white70,
              fontSize: 14,
              fontWeight: remainingSeconds < 20 ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel - Left brake or kickstand
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.close, color: Colors.red, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'CANCEL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kickstand',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Confirm - Hold brakes
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'CONFIRM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap Keycard',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatboxNotification() {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Seatbox Open',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Close seatbox to hibernate',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationScreen() {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.power_settings_new,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Hibernating...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
