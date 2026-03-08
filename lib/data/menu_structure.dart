import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../cubits/locale_cubit.dart';
import '../state/internet.dart';
import '../cubits/mdb_cubits.dart';
import '../cubits/navigation_availability_cubit.dart';
import '../cubits/menu_cubit.dart';
import '../cubits/saved_locations_cubit.dart';
import '../cubits/screen_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../cubits/trip_cubit.dart';
import '../globals/mdb_type.dart';
import '../l10n/l10n.dart';
import '../models/menu_node.dart';
import '../repositories/mdb_repository.dart';
import '../services/settings_service.dart';
import '../state/enums.dart';

/// Builds the complete menu tree structure with current state
MenuNode buildMenuTree(BuildContext context) {
  final l10n = context.l10n;
  // Read current state for dynamic values
  final theme = context.read<ThemeCubit>();
  final themeState = theme.state;
  final settings = context.read<SettingsSync>().state;
  final savedLocations = context.read<SavedLocationsCubit>();
  final localeCubit = context.read<LocaleCubit>();
  final currentLang = localeCubit.state.languageCode;

  return MenuNode.submenu(
    id: 'root',
    title: l10n.menuTitle,
    headerTitle: l10n.menuTitle,
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

      // Toggle Hazard Lights (only show for stock UNU MDB)
       MenuNode.action(
         id: 'hazard_lights',
         title: l10n.menuToggleHazardLights,
         onAction: (context) {
           context.read<VehicleSync>().toggleHazardLights();
           context.read<MenuCubit>().hideMenu();
         },
         isVisible: (context) => isStockUnuMdb.value,
       ),

      // Switch to Cluster View (conditional - only show when on map)
      MenuNode.action(
        id: 'switch_cluster',
        title: l10n.menuSwitchToCluster,
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
        title: l10n.menuSwitchToMap,
        onAction: (context) {
          context.read<ScreenCubit>().showMap();
          context.read<MenuCubit>().hideMenu();
        },
        isVisible: (context) {
          final screen = context.read<ScreenCubit>();
          return screen.state is ScreenCluster;
        },
      ),

      // Navigation unavailable info (shown when offline nav is not ready)
      MenuNode.action(
        id: 'navigation_setup',
        title: l10n.menuNavigationSetup,
        isVisible: (context) {
          final navState = context.read<NavigationAvailabilityCubit>().state;
          final internet = context.read<InternetSync>().state;
          final s = context.read<SettingsSync>().state;
          final isOnline = internet.modemState == ModemState.connected;
          final routingIsOnline = s.valhallaUrl == AppConfig.valhallaOnlineEndpoint;
          final mapIsOnline = s.mapType == MapType.online;
          if (isOnline) {
            return (!routingIsOnline && !navState.routingAvailable) ||
                (!mapIsOnline && !navState.localDisplayMapsAvailable);
          } else {
            // Offline: only show setup if routing is configured offline and not ready.
            // If routing is set to online, getting internet is the fix — not nav setup.
            return !routingIsOnline && !navState.routingAvailable;
          }
        },
        onAction: (context) {
          context.read<MenuCubit>().hideMenu();
          context.read<ScreenCubit>().showNavigationSetup();
        },
      ),

      // Navigation submenu (shown when routing is ready or online routing is reachable)
      MenuNode.submenu(
        id: 'navigation',
        title: l10n.menuNavigation,
        headerTitle: l10n.menuNavigationHeader,
        isVisible: (context) {
          final navState = context.read<NavigationAvailabilityCubit>().state;
          final internet = context.read<InternetSync>().state;
          final s = context.read<SettingsSync>().state;
          final isOnline = internet.modemState == ModemState.connected;
          final routingIsOnline = s.valhallaUrl == AppConfig.valhallaOnlineEndpoint;
          return navState.routingAvailable || (isOnline && routingIsOnline);
        },
        children: [
          MenuNode.action(
            id: 'nav_enter_code',
            title: l10n.menuEnterDestinationCode,
            onAction: (context) {
              context.read<ScreenCubit>().showAddressSelection();
              context.read<MenuCubit>().hideMenu();
            },
          ),
          MenuNode.submenu(
            id: 'nav_saved_locations',
            title: l10n.menuSavedLocations,
            headerTitle: l10n.menuSavedLocationsHeader,
            children: [
              MenuNode.action(
                id: 'save_location',
                title: l10n.menuSaveCurrentLocation,
                onAction: (context) async {
                  final gps = context.read<GpsSync>().state;
                  final internet = context.read<InternetSync>().state;
                  await context.read<SavedLocationsCubit>().saveCurrentLocation(gps, internet);
                  context.read<MenuCubit>().hideMenu();
                },
              ),
              ...savedLocations.currentLocations.map((location) => MenuNode.submenu(
                id: 'location_${location.id}',
                title: location.label,
                children: [
                  MenuNode.action(
                    id: 'start_nav_${location.id}',
                    title: l10n.menuStartNavigation,
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
                    title: l10n.menuDeleteLocation,
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
            title: l10n.menuStopNavigation,
            onAction: (context) async {
              await context.read<NavigationSync>().clearDestination();
              context.read<MenuCubit>().hideMenu();
            },
          ),
          MenuNode.action(
            id: 'nav_setup_info',
            title: l10n.menuNavigationSetup,
            onAction: (context) {
              context.read<MenuCubit>().hideMenu();
              context.read<ScreenCubit>().showNavigationSetup();
            },
          ),
        ],
      ),

      // Settings submenu
      MenuNode.submenu(
        id: 'settings',
        title: l10n.menuSettings,
        headerTitle: l10n.menuSettingsHeader,
        children: [
          // Theme submenu
          MenuNode.submenu(
            id: 'settings_theme',
            title: l10n.menuTheme,
            headerTitle: l10n.menuThemeHeader,
            children: [
              MenuNode.setting(
                id: 'theme_auto',
                title: l10n.menuThemeAutomatic,
                currentValue: themeState.isAutoMode ? 1 : 0,
                onAction: (context) {
                  context.read<ThemeCubit>().updateAutoTheme(true);
                },
              ),
              MenuNode.setting(
                id: 'theme_dark',
                title: l10n.menuThemeDark,
                currentValue: (!themeState.isAutoMode && themeState.isDark) ? 1 : 0,
                onAction: (context) {
                  context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
                },
              ),
              MenuNode.setting(
                id: 'theme_light',
                title: l10n.menuThemeLight,
                currentValue: (!themeState.isAutoMode && !themeState.isDark) ? 1 : 0,
                onAction: (context) {
                  context.read<ThemeCubit>().updateTheme(ThemeMode.light);
                },
              ),
            ],
          ),

          // Language submenu (language names stay untranslated)
          MenuNode.submenu(
            id: 'settings_language',
            title: l10n.menuLanguage,
            headerTitle: l10n.menuLanguageHeader,
            children: [
              MenuNode.setting(
                id: 'lang_en',
                title: 'English',
                currentValue: currentLang == 'en' ? 1 : 0,
                onAction: (context) {
                  context.read<LocaleCubit>().setLocale('en');
                },
              ),
              MenuNode.setting(
                id: 'lang_de',
                title: 'Deutsch',
                currentValue: currentLang == 'de' ? 1 : 0,
                onAction: (context) {
                  context.read<LocaleCubit>().setLocale('de');
                },
              ),
            ],
          ),

          // Status Bar submenu
          MenuNode.submenu(
            id: 'settings_status_bar',
            title: l10n.menuStatusBar,
            children: [
              MenuNode.submenu(
                id: 'status_battery',
                title: l10n.menuBatteryDisplay,
                children: [
                  MenuNode.setting(
                    id: 'battery_percentage',
                    title: l10n.menuBatteryPercentage,
                    currentValue: (settings.batteryDisplayMode ?? 'percentage') == 'percentage' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>()
                          .updateBatteryDisplayModeSetting('percentage');
                    },
                  ),
                  MenuNode.setting(
                    id: 'battery_range',
                    title: l10n.menuBatteryRange,
                    currentValue: (settings.batteryDisplayMode ?? 'percentage') == 'range' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>()
                          .updateBatteryDisplayModeSetting('range');
                    },
                  ),
                ],
              ),
              MenuNode.submenu(
                id: 'status_gps',
                title: l10n.menuGpsIcon,
                children: [
                  MenuNode.setting(
                    id: 'gps_always',
                    title: l10n.menuAlways,
                    currentValue: (settings.showGps ?? 'error') == 'always' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowGpsSetting('always');
                    },
                  ),
                  MenuNode.setting(
                    id: 'gps_active_or_error',
                    title: l10n.menuActiveOrError,
                    currentValue: (settings.showGps ?? 'error') == 'active-or-error' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowGpsSetting('active-or-error');
                    },
                  ),
                  MenuNode.setting(
                    id: 'gps_error',
                    title: l10n.menuErrorOnly,
                    currentValue: (settings.showGps ?? 'error') == 'error' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowGpsSetting('error');
                    },
                  ),
                  MenuNode.setting(
                    id: 'gps_never',
                    title: l10n.menuNever,
                    currentValue: (settings.showGps ?? 'error') == 'never' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowGpsSetting('never');
                    },
                  ),
                ],
              ),
              MenuNode.submenu(
                id: 'status_bluetooth',
                title: l10n.menuBluetoothIcon,
                children: [
                  MenuNode.setting(
                    id: 'bt_always',
                    title: l10n.menuAlways,
                    currentValue: (settings.showBluetooth ?? 'active-or-error') == 'always' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowBluetoothSetting('always');
                    },
                  ),
                  MenuNode.setting(
                    id: 'bt_active_or_error',
                    title: l10n.menuActiveOrError,
                    currentValue: (settings.showBluetooth ?? 'active-or-error') == 'active-or-error' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowBluetoothSetting('active-or-error');
                    },
                  ),
                  MenuNode.setting(
                    id: 'bt_error',
                    title: l10n.menuErrorOnly,
                    currentValue: (settings.showBluetooth ?? 'active-or-error') == 'error' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowBluetoothSetting('error');
                    },
                  ),
                  MenuNode.setting(
                    id: 'bt_never',
                    title: l10n.menuNever,
                    currentValue: (settings.showBluetooth ?? 'active-or-error') == 'never' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowBluetoothSetting('never');
                    },
                  ),
                ],
              ),
              MenuNode.submenu(
                id: 'status_cloud',
                title: l10n.menuCloudIcon,
                children: [
                  MenuNode.setting(
                    id: 'cloud_always',
                    title: l10n.menuAlways,
                    currentValue: (settings.showCloud ?? 'error') == 'always' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowCloudSetting('always');
                    },
                  ),
                  MenuNode.setting(
                    id: 'cloud_active_or_error',
                    title: l10n.menuActiveOrError,
                    currentValue: (settings.showCloud ?? 'error') == 'active-or-error' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowCloudSetting('active-or-error');
                    },
                  ),
                  MenuNode.setting(
                    id: 'cloud_error',
                    title: l10n.menuErrorOnly,
                    currentValue: (settings.showCloud ?? 'error') == 'error' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowCloudSetting('error');
                    },
                  ),
                  MenuNode.setting(
                    id: 'cloud_never',
                    title: l10n.menuNever,
                    currentValue: (settings.showCloud ?? 'error') == 'never' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowCloudSetting('never');
                    },
                  ),
                ],
              ),
              MenuNode.submenu(
                id: 'status_internet',
                title: l10n.menuInternetIcon,
                children: [
                  MenuNode.setting(
                    id: 'inet_always',
                    title: l10n.menuAlways,
                    currentValue: (settings.showInternet ?? 'always') == 'always' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowInternetSetting('always');
                    },
                  ),
                  MenuNode.setting(
                    id: 'inet_active_or_error',
                    title: l10n.menuActiveOrError,
                    currentValue: (settings.showInternet ?? 'always') == 'active-or-error' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowInternetSetting('active-or-error');
                    },
                  ),
                  MenuNode.setting(
                    id: 'inet_error',
                    title: l10n.menuErrorOnly,
                    currentValue: (settings.showInternet ?? 'always') == 'error' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowInternetSetting('error');
                    },
                  ),
                  MenuNode.setting(
                    id: 'inet_never',
                    title: l10n.menuNever,
                    currentValue: (settings.showInternet ?? 'always') == 'never' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowInternetSetting('never');
                    },
                  ),
                ],
              ),
              MenuNode.submenu(
                id: 'status_clock',
                title: l10n.menuClock,
                children: [
                  MenuNode.setting(
                    id: 'clock_always',
                    title: l10n.menuAlways,
                    currentValue: (settings.showClock ?? 'always') != 'never' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowClockSetting('always');
                    },
                  ),
                  MenuNode.setting(
                    id: 'clock_never',
                    title: l10n.menuNever,
                    currentValue: (settings.showClock ?? 'always') == 'never' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateShowClockSetting('never');
                    },
                  ),
                ],
              ),
            ],
          ),

          // Map & Navigation submenu
          MenuNode.submenu(
            id: 'settings_map',
            title: l10n.menuMapAndNavigation,
            children: [
              MenuNode.submenu(
                id: 'map_render_mode',
                title: l10n.menuRenderingMode,
                children: [
                  MenuNode.setting(
                    id: 'render_vector',
                    title: l10n.menuVector,
                    currentValue: settings.mapRenderMode == MapRenderMode.vector ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateMapRenderModeSetting('vector');
                    },
                  ),
                  MenuNode.setting(
                    id: 'render_raster',
                    title: l10n.menuRaster,
                    currentValue: settings.mapRenderMode == MapRenderMode.raster ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateMapRenderModeSetting('raster');
                    },
                  ),
                ],
              ),
              MenuNode.submenu(
                id: 'map_type',
                title: l10n.menuMapType,
                children: [
                  MenuNode.setting(
                    id: 'map_online',
                    title: l10n.menuOnline,
                    currentValue: settings.mapType == MapType.online ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateMapTypeSetting('online');
                    },
                  ),
                  MenuNode.setting(
                    id: 'map_offline',
                    title: l10n.menuOffline,
                    currentValue: settings.mapType == MapType.offline ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateMapTypeSetting('offline');
                    },
                  ),
                ],
               ),
              MenuNode.submenu(
                id: 'navigation_routing',
                title: l10n.menuNavigationRouting,
                children: [
                  MenuNode.setting(
                    id: 'routing_online',
                    title: l10n.menuOnlineOpenStreetMap,
                    currentValue: settings.valhallaUrl == AppConfig.valhallaOnlineEndpoint ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>()
                          .updateValhallaEndpointSetting(AppConfig.valhallaOnlineEndpoint);
                    },
                  ),
                  MenuNode.setting(
                    id: 'routing_offline',
                    title: l10n.menuOffline,
                    currentValue: (settings.valhallaUrl == null ||
                            settings.valhallaUrl!.isEmpty ||
                            settings.valhallaUrl == AppConfig.valhallaOnDeviceEndpoint)
                        ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>()
                          .updateValhallaEndpointSetting(AppConfig.valhallaOnDeviceEndpoint);
                    },
                  ),
                ],
              ),
             ],
           ),

          // Blinker Style submenu
          MenuNode.submenu(
            id: 'settings_blinker_style',
            title: l10n.menuBlinkerStyle,
            children: [
              MenuNode.setting(
                id: 'blinker_small',
                title: l10n.menuBlinkerStyleIcon,
                currentValue: (settings.blinkerStyle ?? 'small') == 'icon' ? 1 : 0,
                onAction: (context) async {
                  await context.read<SettingsService>().updateBlinkerStyleSetting('icon');
                },
              ),
              MenuNode.setting(
                id: 'blinker_overlay',
                title: l10n.menuBlinkerStyleOverlay,
                currentValue: (settings.blinkerStyle ?? 'small') == 'overlay' ? 1 : 0,
                onAction: (context) async {
                  await context.read<SettingsService>().updateBlinkerStyleSetting('overlay');
                },
              ),
            ],
          ),

          // Battery Mode submenu
          MenuNode.submenu(
            id: 'settings_battery_mode',
            title: l10n.menuBatteryMode,
            children: [
              MenuNode.setting(
                id: 'battery_mode_single',
                title: l10n.menuBatteryModeSingle,
                currentValue: (settings.dualBattery ?? 'false') != 'true' ? 1 : 0,
                onAction: (context) async {
                  await context.read<SettingsService>().updateDualBatterySetting(false);
                },
              ),
              MenuNode.setting(
                id: 'battery_mode_dual',
                title: l10n.menuBatteryModeDual,
                currentValue: (settings.dualBattery ?? 'false') == 'true' ? 1 : 0,
                onAction: (context) async {
                  await context.read<SettingsService>().updateDualBatterySetting(true);
                },
              ),
            ],
          ),

          // Alarm submenu
          MenuNode.submenu(
            id: 'settings_alarm',
            title: l10n.menuAlarm,
            headerTitle: l10n.menuAlarmHeader,
            children: [
              MenuNode.setting(
                id: 'alarm_enabled',
                title: l10n.menuAlarmEnabled,
                currentValue: (settings.alarmEnabled ?? 'false') == 'true' ? 1 : 0,
                onAction: (context) async {
                  final current = context.read<SettingsSync>().state.alarmEnabled ?? 'false';
                  await context.read<SettingsService>().updateAlarmEnabledSetting(current != 'true');
                },
              ),
              MenuNode.setting(
                id: 'alarm_honk',
                title: l10n.menuAlarmHonk,
                currentValue: (settings.alarmHonk ?? 'false') == 'true' ? 1 : 0,
                onAction: (context) async {
                  final current = context.read<SettingsSync>().state.alarmHonk ?? 'false';
                  await context.read<SettingsService>().updateAlarmHonkSetting(current != 'true');
                },
              ),
              MenuNode.submenu(
                id: 'alarm_duration',
                title: l10n.menuAlarmDuration,
                headerTitle: l10n.menuAlarmDurationHeader,
                children: [
                  MenuNode.setting(
                    id: 'alarm_duration_10s',
                    title: l10n.menuAlarmDuration10s,
                    currentValue: (settings.alarmDuration ?? '10') == '10' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateAlarmDurationSetting(10);
                    },
                  ),
                  MenuNode.setting(
                    id: 'alarm_duration_20s',
                    title: l10n.menuAlarmDuration20s,
                    currentValue: (settings.alarmDuration ?? '10') == '20' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateAlarmDurationSetting(20);
                    },
                  ),
                  MenuNode.setting(
                    id: 'alarm_duration_30s',
                    title: l10n.menuAlarmDuration30s,
                    currentValue: (settings.alarmDuration ?? '10') == '30' ? 1 : 0,
                    onAction: (context) async {
                      await context.read<SettingsService>().updateAlarmDurationSetting(30);
                    },
                  ),
                ],
              ),
            ],
          ),

           // System submenu
           MenuNode.submenu(
             id: 'settings_system',
             title: l10n.menuSystem,
             children: [
               MenuNode.action(
                 id: 'enter_ums_mode',
                 title: l10n.menuEnterUmsMode,
                 onAction: (context) async {
                   await context.read<MDBRepository>().set('usb', 'mode', 'ums-by-dbc');
                   context.read<MenuCubit>().hideMenu();
                 },
               ),
             ],
           ),
         ],
       ),

       // Reset Trip Statistics
      MenuNode.action(
        id: 'reset_trip',
        title: l10n.menuResetTripStatistics,
        onAction: (context) {
          context.read<TripCubit>().reset();
          context.read<MenuCubit>().hideMenu();
        },
      ),

      // About & Licenses
      MenuNode.action(
        id: 'about',
        title: l10n.menuAboutAndLicenses,
        onAction: (context) {
          context.read<MenuCubit>().hideMenu();
          context.read<ScreenCubit>().showAbout();
        },
      ),

      // Exit Menu
      MenuNode.action(
        id: 'exit',
        title: l10n.menuExitMenu,
        onAction: (context) {
          context.read<MenuCubit>().hideMenu();
        },
      ),
    ],
  );
}
