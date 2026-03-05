import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/mdb_cubits.dart';
import '../../l10n/l10n.dart';
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
  int _remainingSeconds = 15;
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
        _remainingSeconds = 15;
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
        _remainingSeconds = 15;
        _countdownTimer?.cancel();
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleSync, VehicleData>(
      listenWhen: (previous, current) =>
          previous.brakeLeft != current.brakeLeft ||
          previous.brakeRight != current.brakeRight ||
          previous.state != current.state,
      listener: (context, vehicleData) {
        final bothBrakesHeld = vehicleData.brakeLeft == Toggle.on &&
            vehicleData.brakeRight == Toggle.on;
        _updateBrakeTimer(bothBrakesHeld, vehicleData.state);
      },
      child: BlocBuilder<VehicleSync, VehicleData>(
        buildWhen: (previous, current) => previous.state != current.state,
        builder: (context, vehicleData) {
          final vehicleState = vehicleData.state;

          if (!_isHibernationState(vehicleState)) {
            return const SizedBox.shrink();
          }

          final l10n = context.l10n;

          return Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.9),
              child: Center(
                child: _buildContent(l10n, vehicleState),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isHibernationState(ScooterState state) {
    return state == ScooterState.waitingHibernation ||
        state == ScooterState.waitingHibernationAdvanced ||
        state == ScooterState.waitingHibernationSeatbox ||
        state == ScooterState.waitingHibernationConfirm;
  }

  Widget _buildContent(AppLocalizations l10n, ScooterState state) {
    switch (state) {
      case ScooterState.waitingHibernation:
      case ScooterState.waitingHibernationAdvanced:
        return _buildHibernationScreen(l10n, _remainingSeconds);
      case ScooterState.waitingHibernationSeatbox:
        return _buildSeatboxNotification(l10n);
      case ScooterState.waitingHibernationConfirm:
        return _buildConfirmationScreen(l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHibernationScreen(AppLocalizations l10n, int remainingSeconds) {
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
          Text(
            l10n.hibernationTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.hibernationTapKeycardToConfirm,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            remainingSeconds == 0
                ? l10n.hibernationKeepHoldingBrakes
                : remainingSeconds < 15
                    ? l10n.hibernationHoldBrakesForSeconds(remainingSeconds)
                    : l10n.hibernationOrHoldBrakes,
            style: TextStyle(
              color: remainingSeconds < 15 ? Colors.orange : Colors.white70,
              fontSize: 14,
              fontWeight: remainingSeconds < 15 ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.close, color: Colors.red, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        l10n.hibernationCancel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.hibernationKickstand,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check, color: Colors.green, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        l10n.hibernationConfirm,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.hibernationTapKeycard,
                        style: const TextStyle(
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

  Widget _buildSeatboxNotification(AppLocalizations l10n) {
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
          Text(
            l10n.hibernationSeatboxOpen,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.hibernationCloseSeatbox,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationScreen(AppLocalizations l10n) {
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
          Text(
            l10n.hibernationHibernating,
            style: const TextStyle(
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
