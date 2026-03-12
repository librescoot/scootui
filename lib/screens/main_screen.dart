import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import '../cubits/address_cubit.dart';
import '../cubits/carplay_cubit.dart';
import '../cubits/debug_overlay_cubit.dart';
import '../l10n/l10n.dart';
import '../cubits/mdb_cubits.dart';
import '../cubits/menu_cubit.dart';
import '../cubits/screen_cubit.dart';
import '../cubits/shutdown_cubit.dart';
import '../env_config.dart';
import '../repositories/mdb_repository.dart';
import '../repositories/redis_mdb_repository.dart';
import '../services/toast_service.dart';
import '../widgets/toast_listener_wrapper.dart';
import '../state/bluetooth.dart';
import '../widgets/blinker/blinker_overlay.dart';
import '../widgets/bluetooth_pin_code_overlay.dart';
import '../widgets/general/control_gestures_detector.dart';
import '../widgets/hibernation/manual_hibernation_overlay.dart';
import '../widgets/menu/menu_overlay.dart';
import '../widgets/shortcut_menu/shortcut_menu_overlay.dart';
import '../widgets/shutdown/shutdown_overlay.dart';
import '../widgets/ums/ums_overlay.dart';
import '../widgets/version_overlay.dart';
import 'about_screen.dart';
import 'navigation_setup_screen.dart';
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
  bool _poweroffScheduled = false;
  Stream<bool>? _prolongedDisconnectStream;
  bool _startupGraceElapsed = false;
  Timer? _startupTimer;

  @override
  void initState() {
    super.initState();
    _startupTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _startupGraceElapsed = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prolongedDisconnectStream == null) {
      final repo = context.read<MDBRepository>();
      if (repo is RedisMDBRepository) {
        _prolongedDisconnectStream = repo.prolongedDisconnectStream;
      }
    }
  }

  @override
  void dispose() {
    _startupTimer?.cancel();
    super.dispose();
  }

  static const _allowedStates = {
    ScooterState.unknown,
    ScooterState.parked,
    ScooterState.readyToDrive,
    ScooterState.shuttingDown,
    ScooterState.waitingHibernation,
    ScooterState.waitingHibernationAdvanced,
    ScooterState.waitingHibernationSeatbox,
    ScooterState.waitingHibernationConfirm,
  };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ScreenCubit>().state;
    final menu = context.watch<MenuCubit>();
    final debugMode = context.watch<DebugOverlayCubit>().state;

    return OKToast(
      child: ToastListenerWrapper(
        child: BlocListener<ShutdownCubit, ShutdownState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, shutdownState) {
            if (shutdownState.status == ShutdownStatus.exiting && !_poweroffScheduled) {
              debugPrint('Poweroff: shutdown animation complete, executing poweroff');
              if (Platform.isLinux && Platform.environment['USER'] == 'root') {
                _poweroffScheduled = true;
                Process.run('poweroff', []);
              }
            }
          },
          child: BlocListener<VehicleSync, VehicleData>(
            listenWhen: (prev, curr) => prev.state != curr.state,
            listener: (context, vehicleData) {
              final vehicleState = vehicleData.state;

              if (vehicleState != ScooterState.unknown && _startupTimer != null) {
                _startupTimer?.cancel();
                _startupTimer = null;
              }
            },
            child: BlocBuilder<VehicleSync, VehicleData>(
              buildWhen: (prev, curr) {
                final prevAllowed = _allowedStates.contains(prev.state);
                final currAllowed = _allowedStates.contains(curr.state);
                if (prevAllowed != currAllowed) return true;
                if (!currAllowed && prev.stateRaw != curr.stateRaw) return true;
                final prevUnknown = prev.state == ScooterState.unknown;
                final currUnknown = curr.state == ScooterState.unknown;
                return prevUnknown != currUnknown;
              },
              builder: (context, vehicleData) {
                final vehicleState = vehicleData.state;

                if (!_allowedStates.contains(vehicleState)) {
                  return SizedBox(
                    width: EnvConfig.resolution.width,
                    height: EnvConfig.resolution.height,
                    child: MaintenanceScreen(stateRaw: vehicleData.stateRaw),
                  );
                }

                if (vehicleState == ScooterState.unknown && _startupGraceElapsed) {
                  return SizedBox(
                    width: EnvConfig.resolution.width,
                    height: EnvConfig.resolution.height,
                    child: const MaintenanceScreen(showConnectionInfo: true),
                  );
                }

                // Only show full-screen connection screen if Redis never connected;
                // once connected, mid-session disconnects just show a toast
                final repo = context.read<MDBRepository>();
                if (repo is RedisMDBRepository && !repo.hasEverConnected && _prolongedDisconnectStream != null) {
                  return StreamBuilder<bool>(
                    stream: _prolongedDisconnectStream,
                    initialData: repo.prolongedDisconnect,
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return SizedBox(
                          width: EnvConfig.resolution.width,
                          height: EnvConfig.resolution.height,
                          child: const MaintenanceScreen(showConnectionInfo: true),
                        );
                      }
                      return _buildMainUI(context, state, menu, debugMode);
                    },
                  );
                }

                return _buildMainUI(context, state, menu, debugMode);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainUI(
    BuildContext context,
    ScreenState state,
    MenuCubit menu,
    DebugMode debugMode,
  ) {
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
            const UmsOverlay(),
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
          final errorMessage =
              bluetooth.serviceError.isNotEmpty ? bluetooth.serviceError : context.l10n.bluetoothCommError;
          debugPrint('BLE: Showing error toast: $errorMessage');
          ToastService.showError(context.l10n.bluetoothError(errorMessage));
        }
      },
      child: SizedBox(
        width: EnvConfig.resolution.width,
        height: EnvConfig.resolution.height,
        child: Stack(
          children: [
            switch (state) {
              // Map, cluster, and CarPlay screens allow menu access
              ScreenMap() => menuTrigger(const MapScreen()),
              ScreenCluster() => menuTrigger(const ClusterScreen()),
              ScreenCarPlay() => menuTrigger(BlocProvider(
                  create: (context) => CarPlayCubit(),
                  child: const CarPlayScreen(),
                )),
              ScreenAddressSelection() => BlocProvider(
                  create: AddressCubit.create,
                  child: const AddressSelectionScreen(),
                ),
              ScreenOtaBackground() => const OtaBackgroundScreen(),
              ScreenOta() => const OtaScreen(),
              ScreenDebug() => const DebugScreen(),
              ScreenAbout() => const AboutScreen(),
              ScreenNavigationSetup(:final setupMode) => NavigationSetupScreen(mode: setupMode),
              ScreenShuttingDown() => menuTrigger(const ClusterScreen()), // Fallback (shouldn't happen)
            },

            // Blinker overlay (fullscreen arrow when turn signal active, style='overlay')
            const BlinkerOverlay(),

            // Menu overlay
            MenuOverlay(),

            // Shortcut menu overlay
            const ShortcutMenuOverlay(),

            // Shutdown overlay (with translucency over active screen)
            ShutdownOverlay(),

            // UMS overlay (full-screen when USB Mass Storage is active)
            const UmsOverlay(),

            // Manual hibernation overlay
            const ManualHibernationOverlay(),

            // Bluetooth pin code overlay
            BluetoothPinCodeOverlay(),

            // Version information overlay (triggered by both brakes in parked state)
            VersionOverlay(),
          ],
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
