/// Static configuration values for the application
class AppConfig {
  /// Default configuration file path (can be overridden with environment variables)
  static String? settingsFilePath;

  /// Redis settings cluster name
  static const String redisSettingsCluster = 'dashboard';

  /// Redis theme setting key
  static const String themeSettingKey = 'dashboard.theme';

  /// Redis mode setting key
  static const String modeSettingKey = 'dashboard.mode';

  /// Redis show raw speed setting key
  static const String showRawSpeedKey = 'dashboard.show-raw-speed';

  /// Redis battery display mode setting key
  static const String batteryDisplayModeKey = 'dashboard.battery-display-mode';

  /// Redis map type setting key
  static const String mapTypeKey = 'dashboard.map.type';

  /// Redis map render mode setting key
  static const String mapRenderModeKey = 'dashboard.map.render-mode';

  /// Redis settings cluster for persistent settings
  static const String redisSettingsPersistentCluster = 'settings';

  /// On-device Valhalla endpoint URL
  static const String valhallaOnDeviceEndpoint = 'http://localhost:8002/';

  /// Online OpenStreetMap Valhalla endpoint URL
  static const String valhallaOnlineEndpoint = 'https://valhalla1.openstreetmap.de/';

  /// Default Valhalla endpoint URL
  static String valhallaEndpoint = 'http://localhost:8002/';

  /// Redis valhalla endpoint setting key
  static const String valhallaEndpointKey = 'dashboard.valhalla-url';

  /// Redis brightness sensor key
  static const String brightnessKey = 'brightness';

  /// Redis saved locations key prefix
  static const String savedLocationsPrefix = 'dashboard.saved-locations';

  /// Redis language setting key
  static const String languageSettingKey = 'dashboard.language';

  /// Redis key for map tiles availability
  static const String mapsAvailableKey = 'dashboard.maps-available';

  /// Redis key for full navigation availability (maps + routing engine)
  static const String navigationAvailableKey = 'dashboard.navigation-available';

  /// Auto theme light threshold (lux) - switch to light theme above this value
  static const double autoThemeLightThreshold = 25.0;

  /// Auto theme dark threshold (lux) - switch to dark theme below this value
  static const double autoThemeDarkThreshold = 15.0;

  /// Maximum battery range in kilometers at 100% SOC and 100% SOH
  static const double maxBatteryRangeKm = 45.0;

  /// Redis blinker style setting key ('small' or 'overlay')
  static const String blinkerStyleKey = 'dashboard.blinker-style';

  /// Redis dual battery setting key ('true' or 'false')
  static const String dualBatteryKey = 'scooter.dual-battery';
}
