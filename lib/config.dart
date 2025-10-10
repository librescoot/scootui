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

  /// Redis settings cluster for persistent settings
  static const String redisSettingsPersistentCluster = 'settings';

  /// Default Valhalla endpoint URL
  static String valhallaEndpoint = 'http://localhost:8002/';

  /// Redis valhalla endpoint setting key
  static const String valhallaEndpointKey = 'dashboard.valhalla-url';

  /// Redis brightness sensor key
  static const String brightnessKey = 'brightness';

  /// Redis saved locations key prefix
  static const String savedLocationsPrefix = 'dashboard.saved-locations';

  /// Auto theme light threshold (lux) - switch to light theme above this value
  static const double autoThemeLightThreshold = 25.0;

  /// Auto theme dark threshold (lux) - switch to dark theme below this value
  static const double autoThemeDarkThreshold = 15.0;
}
