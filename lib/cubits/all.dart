import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

import 'address_cubit.dart';
import 'carplay_cubit.dart';
import 'debug_overlay_cubit.dart';
import 'map_cubit.dart';
import 'mdb_cubits.dart';
import 'menu_cubit.dart';
import 'navigation_cubit.dart';
import 'ota_cubit.dart';
import 'saved_locations_cubit.dart';
import 'screen_cubit.dart';
import 'shortcut_menu_cubit.dart';
import 'shutdown_cubit.dart';
import 'system_cubit.dart';
import 'theme_cubit.dart';
import 'trip_cubit.dart';
import 'version_overlay_cubit.dart';
import 'dashboard_cubit.dart';

final List<SingleChildWidget> allCubits = [
  BlocProvider(create: ThemeCubit.create),
  BlocProvider(create: EngineSync.create),
  BlocProvider(create: VehicleSync.create),
  BlocProvider(create: Battery0Sync.create),
  BlocProvider(create: Battery1Sync.create),
  BlocProvider(create: CbBatterySync.create),
  BlocProvider(create: AuxBatterySync.create),
  BlocProvider(create: BluetoothSync.create),
  BlocProvider(create: GpsSync.create),
  BlocProvider(create: InternetSync.create),
  BlocProvider(create: NavigationSync.create),
  BlocProvider(
      create: (context) => NavigationCubit(
            gpsStream: context.read<GpsSync>().stream,
            navigationSync: context.read<NavigationSync>(),
            vehicleStream: context.read<VehicleSync>().stream,
            tilesRepository: context.read(),
          )),
  BlocProvider(create: SpeedLimitSync.create),
  BlocProvider(create: CarPlayAvailabilitySync.create),
  BlocProvider(create: SettingsSync.create),
  BlocProvider(create: SystemCubit.create),
  BlocProvider(create: TripCubit.create),
  BlocProvider(create: ShutdownCubit.create),
  BlocProvider(create: MapCubit.create),
  BlocProvider(create: (context) => CarPlayCubit()),
  BlocProvider(create: OtaSync.create),
  BlocProvider(create: OtaCubit.create),
  BlocProvider(create: ScreenCubit.create),
  BlocProvider(create: MenuCubit.create),
  BlocProvider(create: AddressCubit.create),
  BlocProvider(create: SavedLocationsCubit.create),
  BlocProvider(create: DebugOverlayCubit.create),
  BlocProvider(create: ShortcutMenuCubit.create),
  BlocProvider(create: VersionOverlayCubit.create),
  BlocProvider(create: DashboardSyncCubit.create),
];
