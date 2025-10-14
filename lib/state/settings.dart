import 'package:scooter_cluster/builders/sync/annotations.dart';
import 'package:scooter_cluster/builders/sync/settings.dart';
import 'enums.dart';

part 'settings.g.dart';

@StateClass('settings', Duration(seconds: 5))
class SettingsData with $SettingsData implements Syncable<SettingsData> {
  @override
  @StateField(name: 'dashboard.show-raw-speed', defaultValue: 'false')
  String? showRawSpeed;

  @override
  @StateField(name: 'dashboard.show-gps', defaultValue: 'error')
  String? showGps;

  @override
  @StateField(name: 'dashboard.show-bluetooth', defaultValue: 'active-or-error')
  String? showBluetooth;

  @override
  @StateField(name: 'dashboard.show-cloud', defaultValue: 'error')
  String? showCloud;

  @override
  @StateField(name: 'dashboard.show-internet', defaultValue: 'always')
  String? showInternet;

  @override
  @StateField(name: 'dashboard.map.type', defaultValue: 'offline')
  MapType mapType;

  @override
  @StateField(name: 'dashboard.map.render-mode', defaultValue: 'raster')
  MapRenderMode mapRenderMode;

  // Constructor for initial values
  SettingsData({
    this.showRawSpeed,
    this.showGps,
    this.showBluetooth,
    this.showCloud,
    this.showInternet,
    this.mapType = MapType.offline,
    this.mapRenderMode = MapRenderMode.raster,
  });

  // Factory for a completely initial state
  factory SettingsData.initial() => SettingsData();

  bool get showRawSpeedBool => showRawSpeed == 'true';
}