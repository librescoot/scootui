import 'package:flutter/material.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/theme_cubit.dart';
import '../../state/bluetooth.dart';
import '../../state/enums.dart';
import '../../state/gps.dart';
import '../../state/internet.dart';
import 'indicator_light.dart';
import 'ota_status_indicator.dart';

class _Icons {
  static const String connected0 = 'librescoot-internet-modem-connected-0.svg';
  static const String connected1 = 'librescoot-internet-modem-connected-1.svg';
  static const String connected2 = 'librescoot-internet-modem-connected-2.svg';
  static const String connected3 = 'librescoot-internet-modem-connected-3.svg';
  static const String connected4 = 'librescoot-internet-modem-connected-4.svg';
  static const String diconnected = 'librescoot-internet-modem-disconnected.svg';
  static const String off = 'librescoot-internet-modem-off.svg';
  static const String bluetoothConnected = 'librescoot-bluetooth-connected.svg';
  static const String bluetoothDisconnected = 'librescoot-bluetooth-disconnected.svg';
  static const String cloudConnected = 'librescoot-internet-cloud-connected.svg';
  static const String cloudDisconnected = 'librescoot-internet-cloud-disconnected.svg';
  static const String gpsOff = 'librescoot-gps-off.svg';
  static const String gpsSearching = 'librescoot-gps-searching.svg';
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

  bool bluetoothIsActive(BluetoothData bluetooth) {
    return bluetooth.status == ConnectionStatus.connected;
  }

  bool cloudIsActive(InternetData internet) {
    return internet.unuCloud == ConnectionStatus.connected;
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
    final internet = InternetSync.watch(context);
    final bluetooth = BluetoothSync.watch(context);
    final gps = GpsSync.watch(context);
    final settings = SettingsSync.watch(context);
    final ThemeState(:isDark) = ThemeCubit.watch(context);

    final color = isDark ? Colors.white : Colors.black;
    final size = 24.0;

    final children = <Widget>[
      const OtaStatusIndicator(),
    ];

    if (shouldShowIndicator(settings.showGps ?? 'error', gpsIsActive(gps), gpsHasError(gps))) {
      children.add(IndicatorLight(
        icon: IndicatorLight.svgAsset(gpsIcon(gps)),
        isActive: true,
        size: size,
        activeColor: color,
      ));
    }

    if (shouldShowIndicator(settings.showBluetooth ?? 'active-or-error', bluetoothIsActive(bluetooth), false)) {
      children.add(IndicatorLight(
        icon: IndicatorLight.svgAsset(bluetoothIcon(bluetooth)),
        isActive: true,
        size: size,
        activeColor: color,
      ));
    }

    if (shouldShowIndicator(settings.showCloud ?? 'error', cloudIsActive(internet), false)) {
      children.add(IndicatorLight(
        icon: IndicatorLight.svgAsset(cloudIcon(internet)),
        isActive: true,
        size: size,
        activeColor: color,
      ));
    }

    if (shouldShowIndicator(settings.showInternet ?? 'always', internetIsActive(internet), false)) {
      children.add(IndicatorLight(
        icon: IndicatorLight.svgAsset(internetIcon(internet)),
        isActive: true,
        activeColor: color,
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
