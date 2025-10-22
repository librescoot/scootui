import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'config.dart';

/// Loads environment-specific configuration
class EnvConfig {
  static const Size defaultResolution = Size(480, 480);
  static Size _resolution = defaultResolution;
  static double _scaleFactor = 1.0;
  static bool _isCarPlayMode = false;

  /// Get the configured resolution
  static Size get resolution => _resolution;

  /// Get the scale factor relative to the default 480x480 resolution
  static double get scaleFactor => _scaleFactor;

  /// Check if CarPlay mode is enabled
  static bool get isCarPlayMode => _isCarPlayMode;

  /// Initialize application configuration from environment variables
  static void initialize() {
    // Only process environment variables on native platforms
    if (kIsWeb) return;

    // Get settings file path from environment variable if available
    final configPath = Platform.environment['SCOOTUI_SETTINGS_PATH'];
    if (configPath != null && configPath.isNotEmpty) {
      AppConfig.settingsFilePath = configPath;
      debugPrint('Using settings file from environment: $configPath');
    }

    // Check if CarPlay mode is enabled
    final carplayEnv = Platform.environment['CARPLAY'];
    if (carplayEnv == '1') {
      _isCarPlayMode = true;
      debugPrint('CarPlay mode enabled');
    }

    // Parse resolution from environment variable
    // Format: SCOOTUI_RESOLUTION=widthxheight (e.g., SCOOTUI_RESOLUTION=800x600)
    final resolutionStr = Platform.environment['SCOOTUI_RESOLUTION'];
    if (resolutionStr != null && resolutionStr.isNotEmpty) {
      final parts = resolutionStr.toLowerCase().split('x');
      if (parts.length == 2) {
        try {
          final width = double.parse(parts[0]);
          final height = double.parse(parts[1]);
          _resolution = Size(width, height);

          // Calculate scale factor based on the smallest dimension
          // This ensures UI elements scale proportionally
          final defaultMinDimension = defaultResolution.width < defaultResolution.height
              ? defaultResolution.width
              : defaultResolution.height;
          final newMinDimension = width < height ? width : height;
          _scaleFactor = newMinDimension / defaultMinDimension;

          debugPrint('Using resolution from environment: ${width}x$height');
          debugPrint('Scale factor: $_scaleFactor');
        } catch (e) {
          debugPrint('Invalid SCOOTUI_RESOLUTION format: $resolutionStr');
          debugPrint('Expected format: widthxheight (e.g., 800x600)');
        }
      } else {
        debugPrint('Invalid SCOOTUI_RESOLUTION format: $resolutionStr');
        debugPrint('Expected format: widthxheight (e.g., 800x600)');
      }
    }
  }
}
