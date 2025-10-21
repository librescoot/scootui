import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/mdb_repository.dart';
import '../state/aux_battery.dart';
import '../state/battery.dart';
import '../state/bluetooth.dart';
import '../state/cb_battery.dart';
import '../state/engine.dart';
import '../state/gps.dart';
import '../state/internet.dart';
import '../state/navigation.dart';
import '../state/ota.dart';
import '../state/settings.dart';
import '../state/speed_limit.dart';
import '../state/vehicle.dart';
import 'syncable_cubit.dart';

class EngineSync extends SyncableCubit<EngineData> {
  static EngineData watch(BuildContext context) => context.watch<EngineSync>().state;

  static EngineSync create(BuildContext context) => EngineSync(RepositoryProvider.of<MDBRepository>(context))..start();

  static T select<T>(BuildContext context, T Function(EngineData) selector) =>
      selector(context.select((EngineSync e) => e.state));

  EngineSync(MDBRepository repo) : super(redisRepository: repo, initialState: EngineData());
}

class VehicleSync extends SyncableCubit<VehicleData> {
  static VehicleData watch(BuildContext context) => context.watch<VehicleSync>().state;

  static VehicleSync create(BuildContext context) =>
      VehicleSync(RepositoryProvider.of<MDBRepository>(context))..start();

  VehicleSync(MDBRepository repo) : super(redisRepository: repo, initialState: VehicleData());

  void toggleHazardLights() {
    final command = state.blinkerState == BlinkerState.both ? BlinkerState.off : BlinkerState.both;

    super.redisRepository.push("scooter:blinker", command.name);
  }
}

class BatterySync extends SyncableCubit<BatteryData> {
  final String id;

  BatterySync(MDBRepository repo, this.id) : super(redisRepository: repo, initialState: BatteryData(id: id));
}

class Battery0Sync extends BatterySync {
  static BatteryData watch(BuildContext context) => context.watch<Battery0Sync>().state;

  static Battery0Sync create(BuildContext context) =>
      Battery0Sync(RepositoryProvider.of<MDBRepository>(context))..start();

  Battery0Sync(MDBRepository repo) : super(repo, "0");
}

class Battery1Sync extends BatterySync {
  static BatteryData watch(BuildContext context) => context.watch<Battery1Sync>().state;

  static Battery1Sync create(BuildContext context) =>
      Battery1Sync(RepositoryProvider.of<MDBRepository>(context))..start();

  Battery1Sync(MDBRepository repo) : super(repo, "1");
}

class BluetoothSync extends SyncableCubit<BluetoothData> {
  static BluetoothData watch(BuildContext context) => context.watch<BluetoothSync>().state;

  static BluetoothSync create(BuildContext context) =>
      BluetoothSync(RepositoryProvider.of<MDBRepository>(context))..start();

  BluetoothSync(MDBRepository repo) : super(redisRepository: repo, initialState: BluetoothData());
}

class GpsSync extends SyncableCubit<GpsData> {
  static GpsData watch(BuildContext context) => context.watch<GpsSync>().state;

  static GpsSync create(BuildContext context) => GpsSync(RepositoryProvider.of<MDBRepository>(context))..start();

  GpsSync(MDBRepository repo) : super(redisRepository: repo, initialState: GpsData());
}

class InternetSync extends SyncableCubit<InternetData> {
  static InternetData watch(BuildContext context) => context.watch<InternetSync>().state;

  static InternetSync create(BuildContext context) =>
      InternetSync(RepositoryProvider.of<MDBRepository>(context))..start();

  InternetSync(MDBRepository repo) : super(redisRepository: repo, initialState: InternetData());
}

class NavigationSync extends SyncableCubit<NavigationData> {
  static NavigationData watch(BuildContext context) => context.watch<NavigationSync>().state;

  static NavigationSync create(BuildContext context) =>
      NavigationSync(RepositoryProvider.of<MDBRepository>(context))..start();

  NavigationSync(MDBRepository repo) : super(redisRepository: repo, initialState: NavigationData());

  /// Set a navigation destination with coordinates and optional address
  Future<void> setDestination(double latitude, double longitude, {String? address}) async {
    final channel = state.syncSettings.channel;
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final coords = "$latitude,$longitude";

    // Set all fields
    await redisRepository.set(channel, "latitude", latitude.toString());
    await redisRepository.set(channel, "longitude", longitude.toString());
    await redisRepository.set(channel, "timestamp", timestamp);
    await redisRepository.set(channel, "destination", coords); // Legacy field

    if (address != null && address.isNotEmpty) {
      await redisRepository.set(channel, "address", address);
    }

    // Publish notification
    await redisRepository.publish(channel, "destination");

    print("NavigationSync: Set destination to $latitude,$longitude${address != null ? ' ($address)' : ''}");
  }

  Future<void> clearDestination() async {
    // Get the channel name from syncSettings (e.g., "navigation")
    final channel = state.syncSettings.channel;

    // Delete all navigation fields from Redis
    final fields = ["latitude", "longitude", "address", "timestamp", "destination"];
    for (final field in fields) {
      await redisRepository.hdel(channel, field);
    }

    // Publish notification
    await redisRepository.publish(channel, "cleared");

    // Update local state to empty
    emit(NavigationData());
    print("NavigationSync: Cleared destination");
  }
}

class OtaSync extends SyncableCubit<OtaData> {
  static OtaData watch(BuildContext context) => context.watch<OtaSync>().state;

  static OtaSync create(BuildContext context) => OtaSync(RepositoryProvider.of<MDBRepository>(context))..start();

  OtaSync(MDBRepository repo) : super(redisRepository: repo, initialState: OtaData());
}

class SpeedLimitSync extends SyncableCubit<SpeedLimitData> {
  static SpeedLimitData watch(BuildContext context) => context.watch<SpeedLimitSync>().state;

  static SpeedLimitSync create(BuildContext context) =>
      SpeedLimitSync(RepositoryProvider.of<MDBRepository>(context))..start();

  static T select<T>(BuildContext context, T Function(SpeedLimitData) selector) =>
      selector(context.select((SpeedLimitSync e) => e.state));

  SpeedLimitSync(MDBRepository repo) : super(redisRepository: repo, initialState: SpeedLimitData());
}

class SettingsSync extends SyncableCubit<SettingsData> {
  static SettingsData watch(BuildContext context) => context.watch<SettingsSync>().state;

  static SettingsSync create(BuildContext context) =>
      SettingsSync(RepositoryProvider.of<MDBRepository>(context))..start();

  static T select<T>(BuildContext context, T Function(SettingsData) selector) =>
      selector(context.select((SettingsSync e) => e.state));

  SettingsSync(MDBRepository repo) : super(redisRepository: repo, initialState: SettingsData());
}

class CbBatterySync extends SyncableCubit<CbBatteryData> {
  static CbBatteryData watch(BuildContext context) => context.watch<CbBatterySync>().state;

  static CbBatterySync create(BuildContext context) =>
      CbBatterySync(RepositoryProvider.of<MDBRepository>(context), context.read<VehicleSync>())..start();

  CbBatterySync(MDBRepository repo, VehicleSync vehicleSync) : super(redisRepository: repo, initialState: CbBatteryData()) {
    vehicleSync.stream.listen((vehicleState) {
      // Check if seatbox just closed
      if (vehicleState.seatboxLock == SeatboxLock.closed) {
        this.refreshAllFields();
      }
    });
  }
}

class AuxBatterySync extends SyncableCubit<AuxBatteryData> {
  static AuxBatteryData watch(BuildContext context) => context.watch<AuxBatterySync>().state;

  static AuxBatterySync create(BuildContext context) =>
      AuxBatterySync(RepositoryProvider.of<MDBRepository>(context), context.read<VehicleSync>())..start();

  AuxBatterySync(MDBRepository repo, VehicleSync vehicleSync) : super(redisRepository: repo, initialState: AuxBatteryData()) {
    vehicleSync.stream.listen((vehicleState) {
      // Check if seatbox just closed
      if (vehicleState.seatboxLock == SeatboxLock.closed) {
        this.refreshAllFields();
      }
    });
  }
}
