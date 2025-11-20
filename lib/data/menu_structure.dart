import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cubits/mdb_cubits.dart';
import '../cubits/menu_cubit.dart';
import '../cubits/saved_locations_cubit.dart';
import '../cubits/screen_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../cubits/trip_cubit.dart';
import '../models/menu_node.dart';
import '../services/settings_service.dart';
import '../state/enums.dart';

/// Builds the complete menu tree structure with current state
MenuNode buildMenuTree(BuildContext context) {
  // Read current state for dynamic values
  final theme = context.read<ThemeCubit>();
  final themeState = theme.state;
  final settings = context.read<SettingsSync>().state;
  final savedLocations = context.read<SavedLocationsCubit>();

  return MenuNode.submenu(
    id: 'root',
    title: 'Main Menu',
    headerTitle: 'MENU',
    children: [
      // CarPlay/Android Auto (conditional)
      MenuNode.action(
        id: 'carplay',
        title: '', // Will be set dynamically
        onAction: (context) {
          context.read<ScreenCubit>().showCarPlay();
          context.read<MenuCubit>().hideMenu();
        },
        isVisible: (context) {
          final carplay = context.read<CarPlayAvailabilitySync>().state;
          return carplay.isDongleAvailable;
        },
      ),

      // Toggle Hazard Lights (conditional - only for stock UNU MDB)
      MenuNode.action(
        id: 'hazard_lights',
        title: 'Toggle Hazard Lights',
        onAction: (context) {
          context.read<VehicleSync>().toggleHazardLights();
          context.read<MenuCubit>().hideMenu();
        },
        isVisible: (context) {
          // TODO: Check if stock UNU MDB
          return false; // Placeholder
        },
      ),

      // Switch to Cluster View (conditional - only show when on map)
      MenuNode.action(
        id: 'switch_cluster',
        title: 'Switch to Cluster View',
        onAction: (context) {
          context.read<ScreenCubit>().showCluster();
          context.read<MenuCubit>().hideMenu();
        },
        isVisible: (context) {
          final screen = context.read<ScreenCubit>();
          return screen.state is ScreenMap;
        },
      ),

      // Switch to Map View (conditional - only show when on cluster)
      MenuNode.action(
        id: 'switch_map',
        title: 'Switch to Map View',
        onAction: (context) {
          context.read<ScreenCubit>().showMap();
          context.read<MenuCubit>().hideMenu();
        },
        isVisible: (context) {
          final screen = context.read<ScreenCubit>();
          return screen.state is ScreenCluster;
        },
      ),

      // Navigation submenu
      MenuNode.submenu(
        id: 'navigation',
        title: 'Navigation',
        headerTitle: 'NAVIGATION',
        children: [
          MenuNode.action(
            id: 'nav_enter_code',
            title: 'Enter Destination Code',
            onAction: (context) {
              // TODO: Implement destination code entry
              context.read<MenuCubit>().hideMenu();
            },
          ),
          MenuNode.submenu(
            id: 'nav_saved_locations',
            title: 'Saved Locations',
            headerTitle: 'SAVED LOCATIONS',
            children: [
              // Save Current Location
              MenuNode.action(
                id: 'save_location',
                title: 'Save Current Location',
                onAction: (context) async {
                  final gps = context.read<GpsSync>().state;
                  final internet = context.read<InternetSync>().state;
                  await context.read<SavedLocationsCubit>().saveCurrentLocation(gps, internet);
                  context.read<MenuCubit>().hideMenu();
                },
              ),
              // Dynamic saved locations
              ...savedLocations.currentLocations.map((location) => MenuNode.submenu(
                id: 'location_${location.id}',
                title: location.label,
                children: [
                  MenuNode.action(
                    id: 'start_nav_${location.id}',
                    title: 'Start Navigation',
                    onAction: (context) async {
                      await context.read<NavigationSync>().setDestination(
                        location.latitude,
                        location.longitude,
                        address: location.label,
                      );
                      context.read<MenuCubit>().hideMenu();
                    },
                  ),
                  MenuNode.action(
                    id: 'delete_${location.id}',
                    title: 'Delete Location',
                    onAction: (context) async {
                      await context.read<SavedLocationsCubit>().deleteLocation(location.id);
                    },
                  ),
                ],
              )),
            ],
          ),
          MenuNode.action(
            id: 'nav_stop',
            title: 'Stop Navigation',
            onAction: (context) async {
              await context.read<NavigationSync>().clearDestination();
              context.read<MenuCubit>().hideMenu();
            },
          ),
        ],
      ),

      // Settings submenu
      MenuNode.submenu(
        id: 'settings',
        title: 'Settings',
        headerTitle: 'SETTINGS',
        children: [
          // Theme submenu
          MenuNode.submenu(
            id: 'settings_theme',
            title: 'Theme',
            headerTitle: 'CHANGE THEME',
            children: [
              MenuNode.setting(
                id: 'theme_auto',
                title: 'Automatic',
                currentValue: themeState.isAutoMode ? 1 : 0,
                onAction: (context) {
                  context.read<ThemeCubit>().updateAutoTheme(true);
                },
              ),
              MenuNode.setting(
                id: 'theme_dark',
                title: 'Dark',
                currentValue: (!themeState.isAutoMode && themeState.isDark) ? 1 : 0,
                onAction: (context) {
                  context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
                },
              ),
              MenuNode.setting(
                id: 'theme_light',
                title: 'Light',
                currentValue: (!themeState.isAutoMode && !themeState.isDark) ? 1 : 0,
                onAction: (context) {
                  context.read<ThemeCubit>().updateTheme(ThemeMode.light);
                },
              ),
            ],
          ),

          // Status Bar submenu
          MenuNode.submenu(
            id: 'settings_status_bar',
            title: 'Status Bar',
            children: [
              // Battery Display
              MenuNode.submenu(
                id: 'status_battery',
                title: 'Battery Display',
                children: [
                  MenuNode.setting(
                    id: 'battery_percentage',
                    title: 'Percentage',
                    currentValue: (settings.batteryDisplayMode ?? 'percentage') == 'percentage' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>()
                          .updateBatteryDisplayModeSetting('percentage');
                    },
                  ),
                  MenuNode.setting(
                    id: 'battery_range',
                    title: 'Range (km)',
                    currentValue: (settings.batteryDisplayMode ?? 'percentage') == 'range' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>()
                          .updateBatteryDisplayModeSetting('range');
                    },
                  ),
                ],
              ),
              // GPS Icon
              MenuNode.submenu(
                id: 'status_gps',
                title: 'GPS Icon',
                children: [
                  MenuNode.setting(
                    id: 'gps_always',
                    title: 'Always',
                    currentValue: (settings.showGps ?? 'auto') == 'always' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowGpsSetting('always');
                    },
                  ),
                  MenuNode.setting(
                    id: 'gps_auto',
                    title: 'Auto',
                    currentValue: (settings.showGps ?? 'auto') == 'auto' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowGpsSetting('auto');
                    },
                  ),
                  MenuNode.setting(
                    id: 'gps_never',
                    title: 'Never',
                    currentValue: (settings.showGps ?? 'auto') == 'never' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowGpsSetting('never');
                    },
                  ),
                ],
              ),
              // Bluetooth Icon
              MenuNode.submenu(
                id: 'status_bluetooth',
                title: 'Bluetooth Icon',
                children: [
                  MenuNode.setting(
                    id: 'bt_always',
                    title: 'Always',
                    currentValue: (settings.showBluetooth ?? 'auto') == 'always' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowBluetoothSetting('always');
                    },
                  ),
                  MenuNode.setting(
                    id: 'bt_auto',
                    title: 'Auto',
                    currentValue: (settings.showBluetooth ?? 'auto') == 'auto' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowBluetoothSetting('auto');
                    },
                  ),
                  MenuNode.setting(
                    id: 'bt_never',
                    title: 'Never',
                    currentValue: (settings.showBluetooth ?? 'auto') == 'never' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowBluetoothSetting('never');
                    },
                  ),
                ],
              ),
              // Cloud Icon
              MenuNode.submenu(
                id: 'status_cloud',
                title: 'Cloud Icon',
                children: [
                  MenuNode.setting(
                    id: 'cloud_always',
                    title: 'Always',
                    currentValue: (settings.showCloud ?? 'auto') == 'always' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowCloudSetting('always');
                    },
                  ),
                  MenuNode.setting(
                    id: 'cloud_auto',
                    title: 'Auto',
                    currentValue: (settings.showCloud ?? 'auto') == 'auto' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowCloudSetting('auto');
                    },
                  ),
                  MenuNode.setting(
                    id: 'cloud_never',
                    title: 'Never',
                    currentValue: (settings.showCloud ?? 'auto') == 'never' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowCloudSetting('never');
                    },
                  ),
                ],
              ),
              // Internet Icon
              MenuNode.submenu(
                id: 'status_internet',
                title: 'Internet Icon',
                children: [
                  MenuNode.setting(
                    id: 'inet_always',
                    title: 'Always',
                    currentValue: (settings.showInternet ?? 'auto') == 'always' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowInternetSetting('always');
                    },
                  ),
                  MenuNode.setting(
                    id: 'inet_auto',
                    title: 'Auto',
                    currentValue: (settings.showInternet ?? 'auto') == 'auto' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowInternetSetting('auto');
                    },
                  ),
                  MenuNode.setting(
                    id: 'inet_never',
                    title: 'Never',
                    currentValue: (settings.showInternet ?? 'auto') == 'never' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowInternetSetting('never');
                    },
                  ),
                ],
              ),
              // Clock
              MenuNode.submenu(
                id: 'status_clock',
                title: 'Clock',
                children: [
                  MenuNode.setting(
                    id: 'clock_show',
                    title: 'Show',
                    currentValue: (settings.showClock ?? 'show') == 'show' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowClockSetting('show');
                    },
                  ),
                  MenuNode.setting(
                    id: 'clock_hide',
                    title: 'Hide',
                    currentValue: (settings.showClock ?? 'show') == 'hide' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowClockSetting('hide');
                    },
                  ),
                ],
              ),
            ],
          ),

          // Map & Navigation submenu
          MenuNode.submenu(
            id: 'settings_map',
            title: 'Map & Navigation',
            children: [
              MenuNode.submenu(
                id: 'map_render_mode',
                title: 'Rendering Mode',
                children: [
                  MenuNode.setting(
                    id: 'render_vector',
                    title: 'Vector',
                    currentValue: settings.mapRenderMode == MapRenderMode.vector ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateMapRenderModeSetting('vector');
                    },
                  ),
                  MenuNode.setting(
                    id: 'render_raster',
                    title: 'Raster',
                    currentValue: settings.mapRenderMode == MapRenderMode.raster ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateMapRenderModeSetting('raster');
                    },
                  ),
                ],
              ),
              MenuNode.submenu(
                id: 'map_type',
                title: 'Map Type',
                children: [
                  MenuNode.setting(
                    id: 'map_online',
                    title: 'Online',
                    currentValue: settings.mapType == MapType.online ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateMapTypeSetting('online');
                    },
                  ),
                  MenuNode.setting(
                    id: 'map_offline',
                    title: 'Offline',
                    currentValue: settings.mapType == MapType.offline ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateMapTypeSetting('offline');
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Reset Trip Statistics
      MenuNode.action(
        id: 'reset_trip',
        title: 'Reset Trip Statistics',
        onAction: (context) {
          context.read<TripCubit>().reset();
          context.read<MenuCubit>().hideMenu();
        },
      ),

      // Exit Menu
      MenuNode.action(
        id: 'exit',
        title: 'Exit Menu',
        onAction: (context) {
          context.read<MenuCubit>().hideMenu();
        },
      ),
    ],
  );
}
