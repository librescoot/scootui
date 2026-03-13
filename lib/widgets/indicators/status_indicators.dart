import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/theme_cubit.dart';
import '../../state/bluetooth.dart';
import '../../state/enums.dart';
import '../../state/gps.dart';
import '../../state/internet.dart';
import 'indicator_light.dart';
import 'internet_indicator.dart';
import 'ota_status_indicator.dart';

class _Icons {
  static const String connected0 = 'librescoot-internet-modem-connected-0.svg';
  static const String connected1 = 'librescoot-internet-modem-connected-1.svg';
  static const String connected2 = 'librescoot-internet-modem-connected-2.svg';
  static const String connected3 = 'librescoot-internet-modem-connected-3.svg';
  static const String connected4 = 'librescoot-internet-modem-connected-4.svg';
  static const String diconnected = 'librescoot-internet-modem-disconnected.svg';
  static const String bluetoothConnected = 'librescoot-bluetooth-connected.svg';
  static const String bluetoothDisconnected = 'librescoot-bluetooth-disconnected.svg';
  static const String bluetoothError = 'librescoot-bluetooth-error.svg';
  static const String cloudConnected = 'librescoot-internet-cloud-connected.svg';
  static const String cloudDisconnected = 'librescoot-internet-cloud-disconnected.svg';
  static const String gpsOff = 'librescoot-gps-off.svg';
  static const String gpsSearching = 'librescoot-gps-searching.svg';
  static const String gpsCenterDot = 'librescoot-gps-center-dot.svg';
  static const String gpsFixEstablished = 'librescoot-gps-fix-established.svg';
  static const String gpsError = 'librescoot-gps-error.svg';
}

final signalQuality = [
  (86, _Icons.connected4),
  (66, _Icons.connected3),
  (43, _Icons.connected2),
  (24, _Icons.connected1),
  (0, _Icons.connected0),
];

class StatusIndicators extends StatelessWidget {
  const StatusIndicators({super.key});

  String internetIcon(InternetData internet) {
    return switch (internet.status) {
      ConnectionStatus.disconnected => _Icons.diconnected,
      ConnectionStatus.connected => signalQuality.firstWhere((element) => internet.signalQuality >= element.$1).$2
    };
  }

  String bluetoothIcon(BluetoothData bluetooth) {
    // Show error icon if service health is bad
    if (bluetoothHasError(bluetooth)) {
      return _Icons.bluetoothError;
    }

    return switch (bluetooth.status) {
      ConnectionStatus.connected => _Icons.bluetoothConnected,
      ConnectionStatus.disconnected => _Icons.bluetoothDisconnected,
    };
  }

  String cloudIcon(InternetData internet) {
    return switch (internet.unuCloud) {
      ConnectionStatus.connected => _Icons.cloudConnected,
      ConnectionStatus.disconnected => _Icons.cloudDisconnected,
    };
  }

  String gpsIcon(GpsData gps) {
    // Support both state field and timestamp-based detection
    // On stock MDB, state field doesn't exist so it defaults to 'off'
    // Use timestamp logic when state is 'off' (stock MDB case)
    if (gps.state == GpsState.off) {
      // Use timestamp-based detection for stock MDB
      if (gps.hasRecentFix) {
        return _Icons.gpsFixEstablished;
      } else if (gps.timestamp.isNotEmpty) {
        return _Icons.gpsSearching; // Had fix before but now stale
      } else {
        return _Icons.gpsOff; // No timestamp data
      }
    }

    // Use explicit state field (non-stock MDB)
    return switch (gps.state) {
      GpsState.searching => _Icons.gpsSearching,
      GpsState.fixEstablished => gps.hasRecentFix ? _Icons.gpsFixEstablished : _Icons.gpsSearching,
      GpsState.error => _Icons.gpsError,
      GpsState.off => _Icons.gpsOff, // Shouldn't reach here due to check above
    };
  }

  bool gpsIsActive(GpsData gps) {
    if (gps.state == GpsState.off) {
      return gps.hasRecentFix;
    }
    return gps.state == GpsState.fixEstablished && gps.hasRecentFix;
  }

  bool gpsHasError(GpsData gps) {
    return gps.state == GpsState.error;
  }

  // Field-based variants used when GPS fields are accessed via select()
  bool _gpsIsActiveFields(GpsState state, bool hasRecentFix) {
    if (state == GpsState.off) return hasRecentFix;
    return state == GpsState.fixEstablished && hasRecentFix;
  }

  bool _gpsHasErrorFields(GpsState state) => state == GpsState.error;

  /// Whether the GPS indicator should show the searching animation (pulsing center dot)
  bool _gpsIsSearching(GpsState state, bool hasRecentFix, bool hasTimestamp) {
    if (state == GpsState.off) {
      return !hasRecentFix && hasTimestamp;
    }
    return state == GpsState.searching ||
        (state == GpsState.fixEstablished && !hasRecentFix);
  }

  String _gpsIconFields(GpsState state, bool hasRecentFix, bool hasTimestamp) {
    if (state == GpsState.off) {
      if (hasRecentFix) return _Icons.gpsFixEstablished;
      if (hasTimestamp) return _Icons.gpsSearching;
      return _Icons.gpsOff;
    }
    return switch (state) {
      GpsState.searching => _Icons.gpsSearching,
      GpsState.fixEstablished => hasRecentFix ? _Icons.gpsFixEstablished : _Icons.gpsSearching,
      GpsState.error => _Icons.gpsError,
      GpsState.off => _Icons.gpsOff,
    };
  }

  /// Builds the GPS indicator widget — uses a pulsing center dot animation for searching state
  Widget _buildGpsIndicator(GpsState gpsState, bool gpsRecent, bool gpsHasTs, Color color, double size) {
    if (_gpsIsSearching(gpsState, gpsRecent, gpsHasTs)) {
      // Searching: show crosshair solidly + pulse the center dot
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Base crosshair (always visible)
            SvgPicture.asset(
              'assets/icons/${_Icons.gpsSearching}',
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              width: size,
              height: size,
            ),
            // Pulsing center dot overlay
            CustomAnimationBuilder<double>(
              control: Control.loop,
              tween: TweenSequence<double>([
                TweenSequenceItem(
                  tween: Tween(begin: 0.0, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeInOut)),
                  weight: 600,
                ),
                TweenSequenceItem(
                  tween: Tween(begin: 1.0, end: 0.0)
                      .chain(CurveTween(curve: Curves.easeInOut)),
                  weight: 600,
                ),
                TweenSequenceItem(
                  tween: ConstantTween<double>(0.0),
                  weight: 300,
                ),
              ]),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: SvgPicture.asset(
                  'assets/icons/${_Icons.gpsCenterDot}',
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  width: size,
                  height: size,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return IndicatorLight(
      icon: IndicatorLight.svgAsset(_gpsIconFields(gpsState, gpsRecent, gpsHasTs)),
      isActive: true,
      size: size,
      activeColor: color,
    );
  }

  bool bluetoothIsActive(BluetoothData bluetooth) {
    return bluetooth.status == ConnectionStatus.connected;
  }

  bool bluetoothHasError(BluetoothData bluetooth) {
    // Check if service explicitly reports error state
    if (bluetooth.serviceHealth == 'error') {
      return true;
    }

    // Check if heartbeat is stale (service crashed/hung)
    if (bluetooth.lastUpdate.isNotEmpty) {
      try {
        final lastUpdateTimestamp = int.parse(bluetooth.lastUpdate);
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Unix timestamp in seconds
        const staleThresholdSeconds = 30; // Consider stale if no update in 30 seconds

        if (now - lastUpdateTimestamp > staleThresholdSeconds) {
          return true;
        }
      } catch (e) {
        // If we can't parse the timestamp, treat as error
        return true;
      }
    }

    return false;
  }

  bool cloudIsActive(InternetData internet) {
    return internet.unuCloud == ConnectionStatus.connected;
  }

  bool cloudHasError(InternetData internet) {
    return internet.unuCloud == ConnectionStatus.disconnected;
  }

  bool internetIsActive(InternetData internet) {
    return internet.status == ConnectionStatus.connected;
  }

  bool shouldShowIndicator(String setting, bool isActive, bool hasError) {
    return switch (setting) {
      'always' => true,
      'active-or-error' => isActive || hasError,
      'error' => hasError,
      'never' => false,
      _ => true, // Default to always if unknown setting
    };
  }

  @override
  Widget build(BuildContext context) {
    // GPS: select only the fields used here — avoids 1 Hz rebuilds from lat/lng/speed changes
    final (gpsState, gpsRecent, gpsHasTs) = context.select(
        (GpsSync g) => (g.state.state, g.state.hasRecentFix, g.state.timestamp.isNotEmpty));
    // Internet and Bluetooth are event-driven (not periodic), watch() is fine
    final internet = InternetSync.watch(context);
    final bluetooth = BluetoothSync.watch(context);
    // Settings: select only the four display-control flags
    final (showGps, showBt, showCloud, showInternet) = context.select((SettingsSync s) =>
        (s.state.showGps, s.state.showBluetooth, s.state.showCloud, s.state.showInternet));
    final isDark = context.select((ThemeCubit t) => t.state.isDark);

    final color = isDark ? Colors.white : Colors.black;
    final size = 24.0;

    final children = <Widget>[
      const OtaStatusIndicator(),
    ];

    if (shouldShowIndicator(showGps ?? 'error', _gpsIsActiveFields(gpsState, gpsRecent), _gpsHasErrorFields(gpsState))) {
      children.add(_buildGpsIndicator(gpsState, gpsRecent, gpsHasTs, color, size));
    }

    if (shouldShowIndicator(showBt ?? 'active-or-error', bluetoothIsActive(bluetooth), bluetoothHasError(bluetooth))) {
      children.add(IndicatorLight(
        icon: IndicatorLight.svgAsset(bluetoothIcon(bluetooth)),
        isActive: true,
        size: size,
        activeColor: color,
      ));
    }

    if (shouldShowIndicator(showCloud ?? 'error', cloudIsActive(internet), cloudHasError(internet))) {
      children.add(IndicatorLight(
        icon: IndicatorLight.svgAsset(cloudIcon(internet)),
        isActive: true,
        size: size,
        activeColor: color,
      ));
    }

    if (shouldShowIndicator(showInternet ?? 'always', internetIsActive(internet), false)) {
      children.add(InternetIndicator(
        iconName: internetIcon(internet),
        internet: internet,
        color: color,
        size: size,
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 4,
      children: children,
    );
  }
}
