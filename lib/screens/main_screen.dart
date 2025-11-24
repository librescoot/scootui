import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';

import '../cubits/debug_overlay_cubit.dart';
import '../cubits/mdb_cubits.dart';
import '../cubits/menu_cubit.dart';
import '../cubits/screen_cubit.dart';
import '../env_config.dart';
import '../services/toast_service.dart';
import '../state/bluetooth.dart';
import '../widgets/bluetooth_pin_code_overlay.dart';
import '../widgets/general/control_gestures_detector.dart';
import '../widgets/hibernation/manual_hibernation_overlay.dart';
import '../widgets/menu/menu_overlay.dart';
import '../widgets/shortcut_menu/shortcut_menu_overlay.dart';
import '../widgets/shutdown/shutdown_overlay.dart';
import '../widgets/version_overlay.dart';
import 'address_selection_screen.dart';
import 'carplay_screen.dart';
import 'cluster_screen.dart';
import 'debug_screen.dart';
import 'maintenance_screen.dart';
import 'map_screen.dart';
import 'ota_background_screen.dart';
import 'ota_screen.dart';
import '../state/vehicle.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ScooterState? _lastVehicleState;
  bool _poweroffScheduled = false;
  bool _bluetoothWasError = false;

  @override
  Widget build(BuildContext context) {
    // Get the current screen state
    final state = context.watch<ScreenCubit>().state;
    final menu = context.watch<MenuCubit>();
    final debugMode = context.watch<DebugOverlayCubit>().state;
    final vehicleState = context.watch<VehicleSync>().state.state;
    final otaData = context.watch<OtaSync>().state;

    // Check if we should initiate poweroff
    if (vehicleState == ScooterState.shuttingDown &&
        _lastVehicleState != ScooterState.shuttingDown &&
        !_poweroffScheduled) {
      // State just changed to shutting down
      final dbcUpdating = otaData.dbcStatus != "idle";

      debugPrint('Poweroff check: state=shuttingDown, dbcUpdating=$dbcUpdating, platform=${Platform.operatingSystem}');

      if (!dbcUpdating) {
        // Check if running as root (UID 0)
        Process.run('id', ['-u']).then((result) {
          final uid = result.stdout.toString().trim();
          debugPrint('Poweroff check: UID=$uid');

          if (uid == '0') {
            debugPrint('Poweroff: Scheduling poweroff in 2 seconds...');
            _poweroffScheduled = true;
            Future.delayed(const Duration(seconds: 2), () {
              if (Platform.isLinux) {
                debugPrint('Poweroff: Executing poweroff command');
                Process.run('poweroff', []);
              } else {
                debugPrint('Poweroff: Would execute poweroff (skipped on ${Platform.operatingSystem})');
              }
            });
          } else {
            debugPrint('Poweroff: Not running as root, skipping poweroff');
          }
        });
      }
    }

    // Update last known state
    _lastVehicleState = vehicleState;

    // Show maintenance screen if vehicle is not in normal operating states
    const allowedStates = {
      ScooterState.parked,
      ScooterState.readyToDrive,
      ScooterState.shuttingDown,
      ScooterState.waitingHibernation,
      ScooterState.waitingHibernationAdvanced,
      ScooterState.waitingHibernationSeatbox,
      ScooterState.waitingHibernationConfirm,
    };

    if (!allowedStates.contains(vehicleState)) {
      return SizedBox(
        width: EnvConfig.resolution.width,
        height: EnvConfig.resolution.height,
        child: const MaintenanceScreen(),
      );
    }

    Widget menuTrigger(Widget child) => ControlGestureDetector(
          stream: context.read<VehicleSync>().stream,
          onLeftDoubleTap: () => menu.showMenu(),
          child: child,
        );

    // If debug mode is set to full, show the debug screen regardless of current screen state
    if (debugMode == DebugMode.full) {
      return SizedBox(
        width: EnvConfig.resolution.width,
        height: EnvConfig.resolution.height,
        child: Stack(
          children: [
            const DebugScreen(),

            // Overlay essential components that should always be visible
            ShutdownOverlay(),
            const ManualHibernationOverlay(),
            BluetoothPinCodeOverlay(),
          ],
        ),
      );
    }

    return BlocListener<BluetoothSync, BluetoothData>(
      listenWhen: (previous, current) {
        // Only listen when error state changes
        final wasError = _isBluetoothError(previous);
        final isError = _isBluetoothError(current);
        return wasError != isError;
      },
      listener: (context, bluetooth) {
        final isError = _isBluetoothError(bluetooth);

        debugPrint('BLE Health: isError=$isError, health=${bluetooth.serviceHealth}, error=${bluetooth.serviceError}');

        // Show toast when transitioning to error state
        if (isError) {
          final errorMessage = bluetooth.serviceError.isNotEmpty
              ? bluetooth.serviceError
              : 'Bluetooth service communication error';
          debugPrint('BLE: Showing error toast: $errorMessage');
          ToastService.showError('Bluetooth: $errorMessage');
        }
      },
      child: SizedBox(
        width: EnvConfig.resolution.width,
        height: EnvConfig.resolution.height,
        child: OKToast(
          child: Stack(
            children: [
            switch (state) {
              // Map, cluster, and CarPlay screens allow menu access
              ScreenMap() => menuTrigger(const MapScreen()),
              ScreenCluster() => menuTrigger(const ClusterScreen()),
              ScreenCarPlay() => menuTrigger(const CarPlayScreen()),
              ScreenAddressSelection() => const AddressSelectionScreen(),
              ScreenOtaBackground() => const OtaBackgroundScreen(),
              ScreenOta() => const OtaScreen(),
              ScreenDebug() => const DebugScreen(),
              ScreenShuttingDown() => menuTrigger(const ClusterScreen()), // Fallback (shouldn't happen)
            },

            // Menu overlay
            MenuOverlay(),

            // Shortcut menu overlay
            const ShortcutMenuOverlay(),

            // Shutdown overlay (with translucency over active screen)
            ShutdownOverlay(),

            // Manual hibernation overlay
            const ManualHibernationOverlay(),

            // Bluetooth pin code overlay
            BluetoothPinCodeOverlay(),

            // Version information overlay (triggered by both brakes in parked state)
            VersionOverlay(),
          ],
        ),
      ),
    ),
    );
  }

  bool _isBluetoothError(BluetoothData bluetooth) {
    // Check if service explicitly reports error state
    if (bluetooth.serviceHealth == 'error') {
      return true;
    }

    // Check if heartbeat is stale (service crashed/hung)
    if (bluetooth.lastUpdate.isNotEmpty) {
      try {
        final lastUpdateTimestamp = int.parse(bluetooth.lastUpdate);
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Unix timestamp in seconds
        const staleThresholdSeconds = 30; // Consider stale if no update in 30 seconds

        if (now - lastUpdateTimestamp > staleThresholdSeconds) {
          return true;
        }
      } catch (e) {
        // If we can't parse the timestamp, treat as error
        return true;
      }
    }

    return false;
  }
}
