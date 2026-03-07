// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menuTitle => 'MENU';

  @override
  String get menuToggleHazardLights => 'Toggle Hazard Lights';

  @override
  String get menuSwitchToCluster => 'Switch to Cluster View';

  @override
  String get menuSwitchToMap => 'Switch to Map View';

  @override
  String get menuNavigation => 'Navigation';

  @override
  String get menuNavigationHeader => 'NAVIGATION';

  @override
  String get menuNavigationSetup => 'Navigation Setup';

  @override
  String get navSetupTitle => 'Navigation Setup';

  @override
  String get navSetupTitleRoutingUnavailable => 'Routing Not Available';

  @override
  String get navSetupTitleMapsUnavailable => 'Map Tiles Not Available';

  @override
  String get navSetupTitleBothUnavailable => 'Navigation Not Available';

  @override
  String get navSetupLocalDisplayMaps => 'Offline display maps';

  @override
  String get navSetupRoutingEngine => 'Routing engine';

  @override
  String get navSetupNoRoutingBody =>
      'Map display and routing are independent. Display tiles can be local (offline .mbtiles) or online. Routing requires a Valhalla engine — local (needs routing maps) or a remote server.';

  @override
  String get navSetupScanForInstructions => 'Scan for setup instructions';

  @override
  String get menuEnterDestinationCode => 'Enter Destination Code';

  @override
  String get menuSavedLocations => 'Saved Locations';

  @override
  String get menuSavedLocationsHeader => 'SAVED LOCATIONS';

  @override
  String get menuSaveCurrentLocation => 'Save Current Location';

  @override
  String get menuStartNavigation => 'Start Navigation';

  @override
  String get menuDeleteLocation => 'Delete Location';

  @override
  String get menuStopNavigation => 'Stop Navigation';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuSettingsHeader => 'SETTINGS';

  @override
  String get menuTheme => 'Theme';

  @override
  String get menuThemeHeader => 'CHANGE THEME';

  @override
  String get menuThemeAutomatic => 'Automatic';

  @override
  String get menuThemeDark => 'Dark';

  @override
  String get menuThemeLight => 'Light';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuLanguageHeader => 'LANGUAGE';

  @override
  String get menuStatusBar => 'Status Bar';

  @override
  String get menuBatteryDisplay => 'Battery Display';

  @override
  String get menuBatteryPercentage => 'Percentage';

  @override
  String get menuBatteryRange => 'Range (km)';

  @override
  String get menuGpsIcon => 'GPS Icon';

  @override
  String get menuBluetoothIcon => 'Bluetooth Icon';

  @override
  String get menuCloudIcon => 'Cloud Icon';

  @override
  String get menuInternetIcon => 'Internet Icon';

  @override
  String get menuClock => 'Clock';

  @override
  String get menuAlways => 'Always';

  @override
  String get menuActiveOrError => 'Active or Error';

  @override
  String get menuErrorOnly => 'Error Only';

  @override
  String get menuNever => 'Never';

  @override
  String get menuMapAndNavigation => 'Map & Navigation';

  @override
  String get menuRenderingMode => 'Rendering Mode';

  @override
  String get menuVector => 'Vector';

  @override
  String get menuRaster => 'Raster';

  @override
  String get menuMapType => 'Map Type';

  @override
  String get menuOnline => 'Online';

  @override
  String get menuOffline => 'Offline';

  @override
  String get menuNavigationRouting => 'Navigation Routing';

  @override
  String get menuOnlineOpenStreetMap => 'Online (OpenStreetMap)';

  @override
  String get menuBlinkerStyle => 'Blinker Style';

  @override
  String get menuBlinkerStyleIcon => 'Icon (default)';

  @override
  String get menuBlinkerStyleOverlay => 'Fullscreen Arrow';

  @override
  String get menuSystem => 'System';

  @override
  String get menuEnterUmsMode => 'Enter UMS mode';

  @override
  String get menuResetTripStatistics => 'Reset Trip Statistics';

  @override
  String get menuAboutAndLicenses => 'About & Licenses';

  @override
  String get menuExitMenu => 'Exit Menu';

  @override
  String get shutdownShuttingDown => 'Shutting down...';

  @override
  String get shutdownComplete => 'Shutdown complete.\nTap keycard to unlock.';

  @override
  String get shutdownSuspending => 'Suspending...';

  @override
  String get shutdownHibernationImminent => 'Hibernation imminent...';

  @override
  String get shutdownSuspensionImminent => 'Suspension imminent...';

  @override
  String get shutdownProcessing => 'Processing...';

  @override
  String otaUpdateMessage(String action, String version) {
    return '$action update$version.\nYour scooter will turn off when done.\nYou can unlock it again at any point.';
  }

  @override
  String get otaDownloading => 'Downloading';

  @override
  String get otaInstalling => 'Installing';

  @override
  String get otaInitializing => 'Initializing update...';

  @override
  String get otaCheckingUpdates => 'Checking for updates...';

  @override
  String get otaCheckFailed => 'Update check failed.';

  @override
  String get otaDeviceUpdated => 'Device updated.';

  @override
  String get otaWaitingDashboard => 'Waiting for dashboard...';

  @override
  String get otaDownloadingUpdates => 'Downloading updates...';

  @override
  String get otaDownloadFailed => 'Download failed.';

  @override
  String get otaInstallingUpdates => 'Installing updates...';

  @override
  String get otaInstallFailed => 'Installation failed.';

  @override
  String get otaCompleteWaitingDashboardReboot => 'Installation complete, waiting for dashboard reboot...';

  @override
  String get otaCompleteWaitingReboot => 'Installation complete, waiting for reboot...';

  @override
  String otaDownloadingVersionUpdate(String versionText) {
    return 'Downloading$versionText update';
  }

  @override
  String otaInstallingVersionUpdate(String versionText) {
    return 'Installing$versionText update';
  }

  @override
  String get otaWaitingForReboot => 'Update installed. Waiting for reboot';

  @override
  String otaUpdateFailedWithMessage(String errorMessage) {
    return 'Update failed: $errorMessage';
  }

  @override
  String otaUpdateVersionFailed(String versionText) {
    return 'Update$versionText failed';
  }

  @override
  String get otaStatusWaitingForReboot => 'Waiting for reboot';

  @override
  String get otaStatusDownloading => 'Downloading';

  @override
  String get otaStatusInstalling => 'Installing';

  @override
  String otaLibrescootVersion(String version) {
    return ' Librescoot $version';
  }

  @override
  String get otaUpdate => ' update';

  @override
  String get otaInvalidRelease => 'Invalid release';

  @override
  String get otaDownloadFailedShort => 'Download failed';

  @override
  String get otaInstallFailedShort => 'Install failed';

  @override
  String get otaRebootFailed => 'Reboot failed';

  @override
  String get otaUpdateError => 'Update error';

  @override
  String get umsPreparingStorage => 'Preparing USB storage...';

  @override
  String get umsProcessingFiles => 'Processing files...';

  @override
  String umsStatus(String status) {
    return 'USB Mass Storage: $status';
  }

  @override
  String get umsTitle => 'USB Mass Storage Mode';

  @override
  String get umsConnectToComputer => 'Connect to a computer to transfer files.';

  @override
  String get hibernationTitle => 'Manual Hibernation';

  @override
  String get hibernationTapKeycardToConfirm => 'Tap keycard to confirm';

  @override
  String get hibernationKeepHoldingBrakes => 'Keep holding brakes to force';

  @override
  String hibernationHoldBrakesForSeconds(int seconds) {
    return 'Hold both brakes for ${seconds}s to force';
  }

  @override
  String get hibernationOrHoldBrakes => 'Or hold both brakes for 15s to force';

  @override
  String get hibernationCancel => 'CANCEL';

  @override
  String get hibernationKickstand => 'Kickstand';

  @override
  String get hibernationConfirm => 'CONFIRM';

  @override
  String get hibernationTapKeycard => 'Tap Keycard';

  @override
  String get hibernationSeatboxOpen => 'Seatbox Open';

  @override
  String get hibernationCloseSeatbox => 'Close seatbox to hibernate';

  @override
  String get hibernationHibernating => 'Hibernating...';

  @override
  String get navRecalculating => 'Recalculating route...';

  @override
  String get navYouHaveArrived => 'You have arrived!';

  @override
  String get navDistance => 'Distance';

  @override
  String get navRemaining => 'Remaining';

  @override
  String get navEta => 'ETA';

  @override
  String navThen(String instruction) {
    return 'Then $instruction';
  }

  @override
  String navContinueFor(String distanceKm) {
    return 'Continue for $distanceKm km';
  }

  @override
  String navKeepDirection(String direction) {
    return 'Keep $direction';
  }

  @override
  String navKeepDirectionOnto(String direction, String street) {
    return 'Keep $direction on $street';
  }

  @override
  String navTurnDirection(String direction) {
    return 'Turn $direction';
  }

  @override
  String navTurnDirectionOnto(String direction, String street) {
    return 'Turn $direction onto $street';
  }

  @override
  String navTakeExit(String exitNumber) {
    return 'Take exit $exitNumber';
  }

  @override
  String navTakeExitOnto(String exitNumber, String street) {
    return 'Take exit $exitNumber onto $street';
  }

  @override
  String navTakeSideExit(String side) {
    return 'Take the $side exit';
  }

  @override
  String navTakeSideExitTo(String side, String street) {
    return 'Take the $side exit to $street';
  }

  @override
  String navMergeDirection(String direction) {
    return 'Merge $direction';
  }

  @override
  String navMergeDirectionOnto(String direction, String street) {
    return 'Merge $direction onto $street';
  }

  @override
  String navContinueOnStreet(String street) {
    return 'Continue on $street';
  }

  @override
  String get navContinue => 'Continue';

  @override
  String get navShortContinueStraight => 'continue straight';

  @override
  String navShortKeepDirection(String direction) {
    return 'keep $direction';
  }

  @override
  String get navShortTurnLeft => 'turn left';

  @override
  String get navShortTurnRight => 'turn right';

  @override
  String get navShortTurnSlightlyLeft => 'turn slightly left';

  @override
  String get navShortTurnSlightlyRight => 'turn slightly right';

  @override
  String get navShortTurnSharplyLeft => 'turn sharply left';

  @override
  String get navShortTurnSharplyRight => 'turn sharply right';

  @override
  String get navShortUturn => 'make a U-turn';

  @override
  String get navShortUturnRight => 'make a right U-turn';

  @override
  String get navShortMerge => 'merge';

  @override
  String get navShortMergeLeft => 'merge left';

  @override
  String get navShortMergeRight => 'merge right';

  @override
  String get navShortContinue => 'continue';

  @override
  String navShortTakeSideExit(String side) {
    return 'take the $side exit';
  }

  @override
  String navShortTakeNumberedExit(String exitNumber) {
    return 'take the $exitNumber exit';
  }

  @override
  String get navReturnToRoute => 'Return to the route';

  @override
  String get navCurrentPositionNotAvailable => 'Current position not available';

  @override
  String get navCouldNotCalculateRoute => 'Could not calculate route';

  @override
  String get navDestinationUnreachable => 'Destination is unreachable. Please select a different location.';

  @override
  String get navNewDestination => 'New navigation destination received. Calculating route...';

  @override
  String get navWaitingForGps => 'Waiting for GPS fix';

  @override
  String get navWaitingForGpsRoute => 'Waiting for recent GPS fix to calculate route.';

  @override
  String get navResumingNavigation => 'Resuming navigation.';

  @override
  String get navArrivedAtDestination => 'You have arrived at your destination!';

  @override
  String get navOffRouteRerouting => 'Off route. Attempting to reroute...';

  @override
  String get navCouldNotCalculateNewRoute => 'Could not calculate new route';

  @override
  String get batteryKm => 'km';

  @override
  String get batteryCbNotCharging => 'CB Battery not charging';

  @override
  String get batteryAuxLowNotCharging => 'AUX Battery low and not charging';

  @override
  String get batteryAuxVoltageLow => 'AUX Battery voltage low';

  @override
  String get batteryAuxVoltageVeryLowReplace => 'AUX Battery voltage very low - may need replacement';

  @override
  String get batteryAuxVoltageVeryLowCharge => 'AUX Battery voltage very low - insert main battery to charge';

  @override
  String get batteryEmptyRecharge => 'Battery empty. Recharge battery';

  @override
  String get batteryMaxSpeedReduced => 'Max speed is reduced. Battery is below 5%';

  @override
  String get batteryLowPowerReduced => 'Battery low. Power reduced. Please recharge battery';

  @override
  String get batteryLowPowerReducedShort => 'Battery low. Power reduced. Recharge battery';

  @override
  String get batterySlot0 => 'Battery 0';

  @override
  String get batterySlot1 => 'Battery 1';

  @override
  String get speedKmh => 'km/h';

  @override
  String get powerRegen => 'REGEN';

  @override
  String get powerDischarge => 'DISCHARGE';

  @override
  String get controlLeftBrake => 'Left Brake';

  @override
  String get controlRightBrake => 'Right Brake';

  @override
  String get controlNextItem => 'Next Item';

  @override
  String get controlSelect => 'Select';

  @override
  String get controlPressRightBrakeConfirm => 'Press Right Brake to Confirm';

  @override
  String get controlPressLeftBrakeEdit => 'Press Left Brake to Edit';

  @override
  String get statusBarDuration => 'DURATION';

  @override
  String get statusBarAvgSpeed => 'Ø SPEED';

  @override
  String get statusBarTrip => 'TRIP';

  @override
  String get statusBarTotal => 'TOTAL';

  @override
  String get statusBarKmh => 'km/h';

  @override
  String get odometerTrip => 'TRIP';

  @override
  String get odometerTotal => 'TOTAL';

  @override
  String get odometerAvgSpeed => 'AVG SPEED';

  @override
  String odometerAvgSpeedValue(String speed) {
    return '$speed km/h';
  }

  @override
  String get odometerTripTime => 'TRIP TIME';

  @override
  String get addressEditAction => 'Edit';

  @override
  String get addressScrollAction => 'Scroll';

  @override
  String get addressConfirmAction => 'Confirm';

  @override
  String get addressNextAction => 'Next';

  @override
  String get addressCloseAction => 'Close';

  @override
  String get addressScreenTitle => 'Enter Destination Code';

  @override
  String get standbyWarning => 'Vehicle will enter standby in';

  @override
  String get standbySeconds => 'seconds';

  @override
  String get standbyCancel => 'Press brake or move kickstand to cancel';

  @override
  String bluetoothError(String errorMessage) {
    return 'Bluetooth: $errorMessage';
  }

  @override
  String get bluetoothCommError => 'Bluetooth service communication error';

  @override
  String get bluetoothPinInstruction => 'Use this code to pair your device';

  @override
  String get lowTempMotor => 'Motor';

  @override
  String get lowTempBattery => 'Battery';

  @override
  String get lowTemp12vBattery => '12V Battery';

  @override
  String get lowTempWarning => 'Low Temperatures - Ride Carefully';

  @override
  String get faultSignalWireBroken => 'Signal wire broken';

  @override
  String get faultCriticalOverTemp => 'Critical over-temperature';

  @override
  String get faultShortCircuit => 'Short circuit';

  @override
  String get faultBmsNotFollowing => 'BMS not following commands';

  @override
  String get faultBmsCommError => 'BMS communication error';

  @override
  String get faultNfcReaderError => 'NFC reader error';

  @override
  String get faultOverTempCharging => 'Over-temperature while charging';

  @override
  String get faultUnderTempCharging => 'Under-temperature while charging';

  @override
  String get faultOverTempDischarging => 'Over-temperature while discharging';

  @override
  String get faultUnderTempDischarging => 'Under-temperature while discharging';

  @override
  String get faultMosfetOverTemp => 'MOSFET over-temperature';

  @override
  String get faultCellOverVoltage => 'Cell over-voltage';

  @override
  String get faultCellUnderVoltage => 'Cell under-voltage';

  @override
  String get faultOverCurrentCharging => 'Over-current while charging';

  @override
  String get faultOverCurrentDischarging => 'Over-current while discharging';

  @override
  String get faultPackOverVoltage => 'Pack over-voltage';

  @override
  String get faultPackUnderVoltage => 'Pack under-voltage';

  @override
  String get faultReserved => 'Reserved';

  @override
  String get faultBmsZeroData => 'BMS has zero data';

  @override
  String get faultUnknown => 'Unknown fault';

  @override
  String get faultMultipleCritical => 'Multiple Critical Issues';

  @override
  String get faultMultipleBattery => 'Multiple Battery Issues';

  @override
  String get addressLoading => 'Loading address database...';

  @override
  String get addressMapNotFound => 'Map file not found.';

  @override
  String get addressRebuildingHash => 'Rebuilding address database due to hash mismatch...';

  @override
  String get addressHashMismatch => 'Map hash mismatch after rebuild.';

  @override
  String get addressCreatingDb => 'Creating address database...';

  @override
  String get addressBuildFailed => 'Failed to build address database.';

  @override
  String get savedLocationsFailed => 'Failed to load saved locations';

  @override
  String get aboutNonCommercialTitle => 'NON-COMMERCIAL SOFTWARE';

  @override
  String get aboutFossDescription => 'FOSS firmware for unu Scooter Pro e-mopeds';

  @override
  String aboutCommercialProhibited(String licenseId) {
    return 'Commercial distribution, resale, or preinstallation on devices for sale is prohibited under $licenseId.';
  }

  @override
  String aboutScamWarning(String websiteUrl) {
    return 'If you paid money for this software, you may have been the victim of a scam. Please report it at $websiteUrl.';
  }

  @override
  String get aboutOpenSourceComponents => 'OPEN SOURCE COMPONENTS';

  @override
  String get aboutScrollAction => 'Scroll';

  @override
  String get aboutBackAction => 'Back';

  @override
  String get aboutBootThemeRestored => 'Boot theme: LibreScoot restored.';

  @override
  String get aboutGenuineAdvantage => 'Genuine Advantage activated.';

  @override
  String get connectionLost => 'Connection to vehicle system lost';

  @override
  String get connectionReconnecting => 'Attempting to reconnect to vehicle system...';

  @override
  String get connectionRestored => 'Connected to vehicle system';

  @override
  String get shortcutPressToConfirm => 'Press to confirm';

  @override
  String get carplayDisconnected => 'Disconnected from CarPlay';

  @override
  String get carplayConnecting => 'Connecting to CarPlay...';

  @override
  String get carplayConnectingSubtitle => 'Connecting to localhost:8001...';

  @override
  String get carplayInitializingStream => 'Initializing MJPEG stream';

  @override
  String get carplayConnectionError => 'CarPlay Connection Error';

  @override
  String get carplayRetryConnection => 'Retry Connection';

  @override
  String get carplayWaitingForVideo => 'Waiting for video...';

  @override
  String get connectingTitle => 'Trying to connect to vehicle system...';

  @override
  String get connectingExplanation =>
      'This usually indicates a missing or unreliable connection between the dashboard computer (DBC) and the middle driver board (MDB). Check the USB cable if this persists.';

  @override
  String get connectingBypassHint =>
      'To put your scooter into drive mode anyway, raise the kickstand, hold both brakes and press the seatbox button.';

  @override
  String get destinationOfflineOnly => 'The destination selector only works with offline maps';

  @override
  String get destinationInstallMapData => 'Please install the map data to use this feature';

  @override
  String get mapWaitingForGps => 'Waiting for GPS fix';

  @override
  String get mapOutOfCoverage => 'No map data for current location';
}
