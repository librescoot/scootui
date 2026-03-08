import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:path_provider/path_provider.dart';

import '../config.dart';
import '../repositories/mdb_repository.dart';
import '../state/settings.dart';

/// Service for managing persistent settings across app restarts.
///
/// Receives settings updates via [connectSettingsStream] (called from
/// SettingsSync.create after SettingsSync is set up). File persistence
/// provides initial values before Redis is available.
class SettingsService {
  final MDBRepository _mdbRepository;
  String? _configFilePath;
  Map<String, dynamic> _settings = {};
  bool _initialized = false;
  StreamSubscription<SettingsData>? _settingsSyncSubscription;

  final _settingsController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get settingsStream => _settingsController.stream;

  SettingsService(this._mdbRepository);

  Future<void> initialize({String? configFilePath}) async {
    if (_initialized) return;

    _configFilePath = configFilePath ?? AppConfig.settingsFilePath ?? await _getDefaultConfigPath();

    await _loadFromFile();

    _settingsController.add(_settings);

    _initialized = true;
  }

  /// Called from SettingsSync.create to wire up settings data from Redis.
  void connectSettingsStream(Stream<SettingsData> stream) {
    _settingsSyncSubscription?.cancel();
    _settingsSyncSubscription = stream.listen(_applySettingsData);
  }

  void _applySettingsData(SettingsData data) {
    bool changed = false;

    void set(String key, String? value, [String? fallback]) {
      if (value != null && value.isNotEmpty) {
        if (_settings[key] != value) {
          _settings[key] = value;
          changed = true;
        }
      } else if (fallback != null && !_settings.containsKey(key)) {
        _settings[key] = fallback;
        changed = true;
      }
    }

    set(AppConfig.themeSettingKey, data.theme, 'dark');
    set(AppConfig.modeSettingKey, data.mode, 'speedometer');
    set(AppConfig.languageSettingKey, data.language, 'en');
    set(AppConfig.showRawSpeedKey, data.showRawSpeed, 'false');
    set(AppConfig.batteryDisplayModeKey, data.batteryDisplayMode, 'percentage');
    set(AppConfig.blinkerStyleKey, data.blinkerStyle, 'icon');

    if (data.valhallaUrl != null && data.valhallaUrl!.isNotEmpty) {
      if (_settings[AppConfig.valhallaEndpointKey] != data.valhallaUrl) {
        _settings[AppConfig.valhallaEndpointKey] = data.valhallaUrl;
        AppConfig.valhallaEndpoint = data.valhallaUrl!;
        changed = true;
      }
    }

    // Indicator display settings
    final indicators = {
      'dashboard.show-gps': data.showGps,
      'dashboard.show-bluetooth': data.showBluetooth,
      'dashboard.show-cloud': data.showCloud,
      'dashboard.show-internet': data.showInternet,
      'dashboard.show-clock': data.showClock,
    };
    for (final entry in indicators.entries) {
      if (entry.value != null && entry.value!.isNotEmpty) {
        if (_settings[entry.key] != entry.value) {
          _settings[entry.key] = entry.value;
          changed = true;
        }
      }
    }

    if (changed) {
      _settingsController.add(_settings);
    }
  }

  Future<String> _getDefaultConfigPath() async {
    if (kIsWeb) return '';
    final directory = await getApplicationSupportDirectory();
    return '${directory.path}/settings.json';
  }

  Future<void> _loadFromFile() async {
    if (_configFilePath == null || _configFilePath!.isEmpty || kIsWeb) return;

    try {
      final file = File(_configFilePath!);
      if (await file.exists()) {
        final String contents = await file.readAsString();
        _settings = jsonDecode(contents) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('SettingsService: Error loading settings from file: $e');
    }
  }

  ThemeMode getThemeSetting() {
    final value = _settings[AppConfig.themeSettingKey];
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'auto':
        return ThemeMode.dark;
      default:
        return ThemeMode.dark;
    }
  }

  bool getAutoThemeSetting() {
    return _settings[AppConfig.themeSettingKey] == 'auto';
  }

  String getScreenSetting() {
    return (_settings[AppConfig.modeSettingKey] as String?) ?? 'speedometer';
  }

  bool getShowRawSpeedSetting() {
    return (_settings[AppConfig.showRawSpeedKey] as String?) == 'true';
  }

  String getValhallaEndpointSetting() {
    return (_settings[AppConfig.valhallaEndpointKey] as String?) ?? AppConfig.valhallaEndpoint;
  }

  String getLanguageSetting() {
    return (_settings[AppConfig.languageSettingKey] as String?) ?? 'en';
  }

  Future<void> updateThemeSetting(ThemeMode themeMode) async {
    final value = switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    _settings[AppConfig.themeSettingKey] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, AppConfig.themeSettingKey, value);
    _settingsController.add(_settings);
  }

  Future<void> updateAutoThemeSetting(bool enabled) async {
    final value = enabled ? 'auto' : 'dark';
    _settings[AppConfig.themeSettingKey] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, AppConfig.themeSettingKey, value);
    _settingsController.add(_settings);
  }

  Future<void> updateScreenSetting(String screenMode) async {
    _settings[AppConfig.modeSettingKey] = screenMode;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, AppConfig.modeSettingKey, screenMode);
    _settingsController.add(_settings);
  }

  Future<void> updateShowRawSpeedSetting(bool enabled) async {
    final value = enabled ? 'true' : 'false';
    _settings[AppConfig.showRawSpeedKey] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, AppConfig.showRawSpeedKey, value);
    _settingsController.add(_settings);
  }

  Future<void> updateBatteryDisplayModeSetting(String mode) async {
    _settings[AppConfig.batteryDisplayModeKey] = mode;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, AppConfig.batteryDisplayModeKey, mode);
    _settingsController.add(_settings);
  }

  Future<void> updateValhallaEndpointSetting(String url) async {
    _settings[AppConfig.valhallaEndpointKey] = url;
    AppConfig.valhallaEndpoint = url;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, AppConfig.valhallaEndpointKey, url);
    _settingsController.add(_settings);
  }

  Future<void> updateShowGpsSetting(String value) async {
    const key = 'dashboard.show-gps';
    _settings[key] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, key, value);
    _settingsController.add(_settings);
  }

  Future<void> updateShowBluetoothSetting(String value) async {
    const key = 'dashboard.show-bluetooth';
    _settings[key] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, key, value);
    _settingsController.add(_settings);
  }

  Future<void> updateShowCloudSetting(String value) async {
    const key = 'dashboard.show-cloud';
    _settings[key] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, key, value);
    _settingsController.add(_settings);
  }

  Future<void> updateShowInternetSetting(String value) async {
    const key = 'dashboard.show-internet';
    _settings[key] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, key, value);
    _settingsController.add(_settings);
  }

  Future<void> updateShowClockSetting(String value) async {
    const key = 'dashboard.show-clock';
    _settings[key] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, key, value);
    _settingsController.add(_settings);
  }

  Future<void> updateMapTypeSetting(String value) async {
    _settings[AppConfig.mapTypeKey] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, AppConfig.mapTypeKey, value);
    _settingsController.add(_settings);
  }

  Future<void> updateLanguageSetting(String languageCode) async {
    _settings[AppConfig.languageSettingKey] = languageCode;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, AppConfig.languageSettingKey, languageCode);
    _settingsController.add(_settings);
  }

  Future<void> updateMapRenderModeSetting(String value) async {
    _settings[AppConfig.mapRenderModeKey] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, AppConfig.mapRenderModeKey, value);
    _settingsController.add(_settings);
  }

  String getBlinkerStyleSetting() {
    return (_settings[AppConfig.blinkerStyleKey] as String?) ?? 'icon';
  }

  Future<void> updateBlinkerStyleSetting(String value) async {
    _settings[AppConfig.blinkerStyleKey] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, AppConfig.blinkerStyleKey, value);
    _settingsController.add(_settings);
  }

  Future<void> updateAlarmEnabledSetting(bool enabled) async {
    const key = 'alarm.enabled';
    final value = enabled ? 'true' : 'false';
    _settings[key] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, key, value);
    _settingsController.add(_settings);
  }

  Future<void> updateAlarmHonkSetting(bool enabled) async {
    const key = 'alarm.honk';
    final value = enabled ? 'true' : 'false';
    _settings[key] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, key, value);
    _settingsController.add(_settings);
  }

  Future<void> updateAlarmDurationSetting(int seconds) async {
    const key = 'alarm.duration';
    final value = seconds.toString();
    _settings[key] = value;
    await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, key, value);
    _settingsController.add(_settings);
  }

  void dispose() {
    _settingsSyncSubscription?.cancel();
    _settingsController.close();
  }
}
