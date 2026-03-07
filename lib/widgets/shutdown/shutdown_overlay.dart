import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/l10n.dart';
import '../../cubits/shutdown_cubit.dart';
import '../../cubits/mdb_cubits.dart';
import '../../state/vehicle.dart';
import '../../state/ota.dart';
import 'shutdown_animation.dart';

class ShutdownOverlay extends StatefulWidget {
  const ShutdownOverlay({super.key});

  @override
  State<ShutdownOverlay> createState() => _ShutdownOverlayState();
}

class _ShutdownOverlayState extends State<ShutdownOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.read<ShutdownCubit>().signalAnimationComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tryStartAnimation(BuildContext context) {
    final ota = context.read<OtaSync>().state;
    final otaOngoing =
        ota.dbcStatus == 'downloading' || ota.dbcStatus == 'installing';
    if (!otaOngoing && !_controller.isAnimating && _controller.value == 0.0) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ShutdownCubit, ShutdownState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status == ShutdownStatus.shuttingDown) {
              _tryStartAnimation(context);
            } else {
              _controller.stop();
              _controller.reset();
            }
          },
        ),
        BlocListener<OtaSync, OtaData>(
          listener: (context, ota) {
            final shutdownStatus =
                context.read<ShutdownCubit>().state.status;
            if (shutdownStatus == ShutdownStatus.shuttingDown) {
              _tryStartAnimation(context);
            }
          },
        ),
      ],
      child: _buildOverlay(context),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final shutdownState = ShutdownCubit.watch(context);
    final vehicleState = VehicleSync.watch(context);
    final otaData = OtaSync.watch(context);

    final dbcStatus = otaData.dbcStatus;
    final isOtaOngoing =
        dbcStatus == 'downloading' || dbcStatus == 'installing';

    final isFullShutdownOverlay = shutdownState.isFullOverlay;
    final isBackgroundProcessing = shutdownState.isBackgroundIndicator;

    if (shutdownState.status == ShutdownStatus.blackout) {
      // SIGTERM path: fade to black over 600ms
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        builder: (context, value, _) =>
            Container(color: Colors.black.withOpacity(value)),
      );
    }

    if (shutdownState.isBlackout) {
      // exiting state: already solid black from the 1.5s animation
      return Container(color: Colors.black);
    }

    if (shutdownState.status == ShutdownStatus.shuttingDown) {
      if (isOtaOngoing) {
        return _buildOtaOverlay(context, vehicleState, otaData);
      }
      // Animate background from 0.8 → 1.0 opacity over 1500ms
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final opacity = 0.8 + 0.2 * _controller.value;
          return Container(
            color: Colors.black.withOpacity(opacity),
            child: _controller.value < 0.95
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: Opacity(
                        opacity: (1.0 - _controller.value * 2).clamp(0.0, 1.0),
                        child: ShutdownContent(status: shutdownState.status),
                      ),
                    ),
                  )
                : null,
          );
        },
      );
    }

    if (isOtaOngoing && isFullShutdownOverlay) {
      return _buildCombinedOtaShutdownOverlay(
          context, vehicleState, otaData, shutdownState.status);
    } else if (isOtaOngoing) {
      return _buildOtaOverlay(context, vehicleState, otaData);
    } else if (isFullShutdownOverlay) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ShutdownContent(status: shutdownState.status),
      );
    } else if (isBackgroundProcessing) {
      return _buildBackgroundProcessingIndicator(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildOtaOverlay(
      BuildContext context, VehicleData vehicleState, OtaData otaData) {
    final dbcStatus = otaData.dbcStatus;
    final updateVersion = otaData.dbcUpdateVersion;
    final isUnlocked = vehicleState.state == ScooterState.readyToDrive ||
        vehicleState.state == ScooterState.parked;
    final isLocked = vehicleState.state == ScooterState.standBy;

    // Status bar icon for unlocked scooter (handled by OtaStatusIndicator in top status bar)
    if (isUnlocked) {
      return const SizedBox.shrink();
    }

    // Full message for locked scooter
    if (isLocked) {
      final l10n = context.l10n;
      final actionText =
          dbcStatus == 'downloading' ? l10n.otaDownloading : l10n.otaInstalling;
      final versionText = updateVersion.isNotEmpty ? ' $updateVersion' : '';

      return Container(
        color: Colors.black, // Full black background for stand-by state
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Spinner
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3.0,
                  ),
                ),
                const SizedBox(height: 10),
                // Text
                Text(
                  l10n.otaUpdateMessage(actionText, versionText),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCombinedOtaShutdownOverlay(
      BuildContext context,
      VehicleData vehicleState,
      OtaData otaData,
      ShutdownStatus shutdownStatus) {
    final dbcStatus = otaData.dbcStatus;
    final updateVersion = otaData.dbcUpdateVersion;
    final l10n = context.l10n;
    final actionText =
        dbcStatus == 'downloading' ? l10n.otaDownloading : l10n.otaInstalling;
    final versionText = updateVersion.isNotEmpty ? ' $updateVersion' : '';

    // Use full black background when in stand-by, translucent when shutting down
    final isStandBy = vehicleState.state == ScooterState.standBy;
    final backgroundColor =
        isStandBy ? Colors.black : Colors.black.withOpacity(0.8);

    return Container(
      color: backgroundColor,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spinner
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3.0,
                ),
              ),
              const SizedBox(height: 10),
              // Text
              Text(
                l10n.otaUpdateMessage(actionText, versionText),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundProcessingIndicator(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.shutdownProcessing,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
