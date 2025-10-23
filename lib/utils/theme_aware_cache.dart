import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Provides separate cache directories for light and dark themes
/// to ensure cached tiles don't persist styling from the previous theme
class ThemeAwareCache {
  static Future<Directory> Function() getCacheFolderProvider(String themeMode) {
    return () async {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/maps/cache/$themeMode');

      // Ensure directory exists
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      return cacheDir;
    };
  }

  /// Clear cache for a specific theme
  static Future<void> clearThemeCache(String themeMode) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/maps/cache/$themeMode');

    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  /// Clear all theme caches
  static Future<void> clearAllCaches() async {
    await Future.wait([
      clearThemeCache('dark'),
      clearThemeCache('light'),
    ]);
  }
}