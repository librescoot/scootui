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
  @StateField(name: 'dashboard.battery-display-mode', defaultValue: 'percentage')
  String? batteryDisplayMode;

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
  @StateField(name: 'dashboard.show-clock', defaultValue: 'always')
  String? showClock;

  @override
  @StateField(name: 'dashboard.map.type', defaultValue: 'offline')
  MapType mapType;

  @override
  @StateField(name: 'dashboard.map.render-mode', defaultValue: 'raster')
  MapRenderMode mapRenderMode;

  @override
  @StateField(name: 'dashboard.power-display-mode', defaultValue: 'kw')
  PowerDisplayMode powerDisplayMode;

  @override
  @StateField(name: 'dashboard.theme', defaultValue: 'dark')
  String? theme;

  @override
  @StateField(name: 'dashboard.mode', defaultValue: 'speedometer')
  String? mode;

  @override
  @StateField(name: 'dashboard.language', defaultValue: 'en')
  String? language;

  @override
  @StateField(name: 'dashboard.valhalla-url')
  String? valhallaUrl;

  // Constructor for initial values
  SettingsData({
    this.showRawSpeed,
    this.batteryDisplayMode,
    this.showGps,
    this.showBluetooth,
    this.showCloud,
    this.showInternet,
    this.showClock,
    this.mapType = MapType.offline,
    this.mapRenderMode = MapRenderMode.raster,
    this.powerDisplayMode = PowerDisplayMode.kw,
    this.theme,
    this.mode,
    this.language,
    this.valhallaUrl,
  });

  factory SettingsData.initial() => SettingsData();

  bool get showRawSpeedBool => showRawSpeed == 'true';
  bool get showBatteryAsRange => batteryDisplayMode == 'range';
}