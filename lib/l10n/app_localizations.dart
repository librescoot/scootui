import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de'), Locale('en')];

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'MENU'**
  String get menuTitle;

  /// No description provided for @menuToggleHazardLights.
  ///
  /// In en, this message translates to:
  /// **'Toggle Hazard Lights'**
  String get menuToggleHazardLights;

  /// No description provided for @menuSwitchToCluster.
  ///
  /// In en, this message translates to:
  /// **'Switch to Cluster View'**
  String get menuSwitchToCluster;

  /// No description provided for @menuSwitchToMap.
  ///
  /// In en, this message translates to:
  /// **'Switch to Map View'**
  String get menuSwitchToMap;

  /// No description provided for @menuNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get menuNavigation;

  /// No description provided for @menuNavigationHeader.
  ///
  /// In en, this message translates to:
  /// **'NAVIGATION'**
  String get menuNavigationHeader;

  /// No description provided for @menuNavigationSetup.
  ///
  /// In en, this message translates to:
  /// **'Navigation Setup'**
  String get menuNavigationSetup;

  /// No description provided for @navSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Routing Not Available'**
  String get navSetupTitle;

  /// No description provided for @navSetupLocalDisplayMaps.
  ///
  /// In en, this message translates to:
  /// **'Offline display maps'**
  String get navSetupLocalDisplayMaps;

  /// No description provided for @navSetupRoutingEngine.
  ///
  /// In en, this message translates to:
  /// **'Routing engine'**
  String get navSetupRoutingEngine;

  /// No description provided for @navSetupNoRoutingBody.
  ///
  /// In en, this message translates to:
  /// **'Map display and routing are independent. Display tiles can be local (offline .mbtiles) or online. Routing requires a Valhalla engine — local (needs routing maps) or a remote server.'**
  String get navSetupNoRoutingBody;

  /// No description provided for @navSetupScanForInstructions.
  ///
  /// In en, this message translates to:
  /// **'Scan for setup instructions'**
  String get navSetupScanForInstructions;

  /// No description provided for @menuEnterDestinationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Destination Code'**
  String get menuEnterDestinationCode;

  /// No description provided for @menuSavedLocations.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations'**
  String get menuSavedLocations;

  /// No description provided for @menuSavedLocationsHeader.
  ///
  /// In en, this message translates to:
  /// **'SAVED LOCATIONS'**
  String get menuSavedLocationsHeader;

  /// No description provided for @menuSaveCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Current Location'**
  String get menuSaveCurrentLocation;

  /// No description provided for @menuStartNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get menuStartNavigation;

  /// No description provided for @menuDeleteLocation.
  ///
  /// In en, this message translates to:
  /// **'Delete Location'**
  String get menuDeleteLocation;

  /// No description provided for @menuStopNavigation.
  ///
  /// In en, this message translates to:
  /// **'Stop Navigation'**
  String get menuStopNavigation;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuSettingsHeader.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get menuSettingsHeader;

  /// No description provided for @menuTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get menuTheme;

  /// No description provided for @menuThemeHeader.
  ///
  /// In en, this message translates to:
  /// **'CHANGE THEME'**
  String get menuThemeHeader;

  /// No description provided for @menuThemeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get menuThemeAutomatic;

  /// No description provided for @menuThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get menuThemeDark;

  /// No description provided for @menuThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get menuThemeLight;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @menuLanguageHeader.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get menuLanguageHeader;

  /// No description provided for @menuStatusBar.
  ///
  /// In en, this message translates to:
  /// **'Status Bar'**
  String get menuStatusBar;

  /// No description provided for @menuBatteryDisplay.
  ///
  /// In en, this message translates to:
  /// **'Battery Display'**
  String get menuBatteryDisplay;

  /// No description provided for @menuBatteryPercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get menuBatteryPercentage;

  /// No description provided for @menuBatteryRange.
  ///
  /// In en, this message translates to:
  /// **'Range (km)'**
  String get menuBatteryRange;

  /// No description provided for @menuGpsIcon.
  ///
  /// In en, this message translates to:
  /// **'GPS Icon'**
  String get menuGpsIcon;

  /// No description provided for @menuBluetoothIcon.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Icon'**
  String get menuBluetoothIcon;

  /// No description provided for @menuCloudIcon.
  ///
  /// In en, this message translates to:
  /// **'Cloud Icon'**
  String get menuCloudIcon;

  /// No description provided for @menuInternetIcon.
  ///
  /// In en, this message translates to:
  /// **'Internet Icon'**
  String get menuInternetIcon;

  /// No description provided for @menuClock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get menuClock;

  /// No description provided for @menuAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get menuAlways;

  /// No description provided for @menuActiveOrError.
  ///
  /// In en, this message translates to:
  /// **'Active or Error'**
  String get menuActiveOrError;

  /// No description provided for @menuErrorOnly.
  ///
  /// In en, this message translates to:
  /// **'Error Only'**
  String get menuErrorOnly;

  /// No description provided for @menuNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get menuNever;

  /// No description provided for @menuMapAndNavigation.
  ///
  /// In en, this message translates to:
  /// **'Map & Navigation'**
  String get menuMapAndNavigation;

  /// No description provided for @menuRenderingMode.
  ///
  /// In en, this message translates to:
  /// **'Rendering Mode'**
  String get menuRenderingMode;

  /// No description provided for @menuVector.
  ///
  /// In en, this message translates to:
  /// **'Vector'**
  String get menuVector;

  /// No description provided for @menuRaster.
  ///
  /// In en, this message translates to:
  /// **'Raster'**
  String get menuRaster;

  /// No description provided for @menuMapType.
  ///
  /// In en, this message translates to:
  /// **'Map Type'**
  String get menuMapType;

  /// No description provided for @menuOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get menuOnline;

  /// No description provided for @menuOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get menuOffline;

  /// No description provided for @menuSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get menuSystem;

  /// No description provided for @menuEnterUmsMode.
  ///
  /// In en, this message translates to:
  /// **'Enter UMS mode'**
  String get menuEnterUmsMode;

  /// No description provided for @menuResetTripStatistics.
  ///
  /// In en, this message translates to:
  /// **'Reset Trip Statistics'**
  String get menuResetTripStatistics;

  /// No description provided for @menuAboutAndLicenses.
  ///
  /// In en, this message translates to:
  /// **'About & Licenses'**
  String get menuAboutAndLicenses;

  /// No description provided for @menuExitMenu.
  ///
  /// In en, this message translates to:
  /// **'Exit Menu'**
  String get menuExitMenu;

  /// No description provided for @shutdownShuttingDown.
  ///
  /// In en, this message translates to:
  /// **'Shutting down...'**
  String get shutdownShuttingDown;

  /// No description provided for @shutdownComplete.
  ///
  /// In en, this message translates to:
  /// **'Shutdown complete.\nTap keycard to unlock.'**
  String get shutdownComplete;

  /// No description provided for @shutdownSuspending.
  ///
  /// In en, this message translates to:
  /// **'Suspending...'**
  String get shutdownSuspending;

  /// No description provided for @shutdownHibernationImminent.
  ///
  /// In en, this message translates to:
  /// **'Hibernation imminent...'**
  String get shutdownHibernationImminent;

  /// No description provided for @shutdownSuspensionImminent.
  ///
  /// In en, this message translates to:
  /// **'Suspension imminent...'**
  String get shutdownSuspensionImminent;

  /// No description provided for @shutdownProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get shutdownProcessing;

  /// No description provided for @otaUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'{action} update{version}.\nYour scooter will turn off when done.\nYou can unlock it again at any point.'**
  String otaUpdateMessage(String action, String version);

  /// No description provided for @otaDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get otaDownloading;

  /// No description provided for @otaInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing'**
  String get otaInstalling;

  /// No description provided for @otaInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing update...'**
  String get otaInitializing;

  /// No description provided for @otaCheckingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get otaCheckingUpdates;

  /// No description provided for @otaCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Update check failed.'**
  String get otaCheckFailed;

  /// No description provided for @otaDeviceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Device updated.'**
  String get otaDeviceUpdated;

  /// No description provided for @otaWaitingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Waiting for dashboard...'**
  String get otaWaitingDashboard;

  /// No description provided for @otaDownloadingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Downloading updates...'**
  String get otaDownloadingUpdates;

  /// No description provided for @otaDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed.'**
  String get otaDownloadFailed;

  /// No description provided for @otaInstallingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Installing updates...'**
  String get otaInstallingUpdates;

  /// No description provided for @otaInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Installation failed.'**
  String get otaInstallFailed;

  /// No description provided for @otaCompleteWaitingDashboardReboot.
  ///
  /// In en, this message translates to:
  /// **'Installation complete, waiting for dashboard reboot...'**
  String get otaCompleteWaitingDashboardReboot;

  /// No description provided for @otaCompleteWaitingReboot.
  ///
  /// In en, this message translates to:
  /// **'Installation complete, waiting for reboot...'**
  String get otaCompleteWaitingReboot;

  /// No description provided for @otaDownloadingVersionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading{versionText} update'**
  String otaDownloadingVersionUpdate(String versionText);

  /// No description provided for @otaInstallingVersionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Installing{versionText} update'**
  String otaInstallingVersionUpdate(String versionText);

  /// No description provided for @otaWaitingForReboot.
  ///
  /// In en, this message translates to:
  /// **'Update installed. Waiting for reboot'**
  String get otaWaitingForReboot;

  /// No description provided for @otaUpdateFailedWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {errorMessage}'**
  String otaUpdateFailedWithMessage(String errorMessage);

  /// No description provided for @otaUpdateVersionFailed.
  ///
  /// In en, this message translates to:
  /// **'Update{versionText} failed'**
  String otaUpdateVersionFailed(String versionText);

  /// No description provided for @otaStatusWaitingForReboot.
  ///
  /// In en, this message translates to:
  /// **'Waiting for reboot'**
  String get otaStatusWaitingForReboot;

  /// No description provided for @otaStatusDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get otaStatusDownloading;

  /// No description provided for @otaStatusInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing'**
  String get otaStatusInstalling;

  /// No description provided for @otaLibrescootVersion.
  ///
  /// In en, this message translates to:
  /// **' Librescoot {version}'**
  String otaLibrescootVersion(String version);

  /// No description provided for @otaUpdate.
  ///
  /// In en, this message translates to:
  /// **' update'**
  String get otaUpdate;

  /// No description provided for @otaInvalidRelease.
  ///
  /// In en, this message translates to:
  /// **'Invalid release'**
  String get otaInvalidRelease;

  /// No description provided for @otaDownloadFailedShort.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get otaDownloadFailedShort;

  /// No description provided for @otaInstallFailedShort.
  ///
  /// In en, this message translates to:
  /// **'Install failed'**
  String get otaInstallFailedShort;

  /// No description provided for @otaRebootFailed.
  ///
  /// In en, this message translates to:
  /// **'Reboot failed'**
  String get otaRebootFailed;

  /// No description provided for @otaUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Update error'**
  String get otaUpdateError;

  /// No description provided for @umsPreparingStorage.
  ///
  /// In en, this message translates to:
  /// **'Preparing USB storage...'**
  String get umsPreparingStorage;

  /// No description provided for @umsProcessingFiles.
  ///
  /// In en, this message translates to:
  /// **'Processing files...'**
  String get umsProcessingFiles;

  /// No description provided for @umsStatus.
  ///
  /// In en, this message translates to:
  /// **'USB Mass Storage: {status}'**
  String umsStatus(String status);

  /// No description provided for @umsTitle.
  ///
  /// In en, this message translates to:
  /// **'USB Mass Storage Mode'**
  String get umsTitle;

  /// No description provided for @umsConnectToComputer.
  ///
  /// In en, this message translates to:
  /// **'Connect to a computer to transfer files.'**
  String get umsConnectToComputer;

  /// No description provided for @hibernationTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Hibernation'**
  String get hibernationTitle;

  /// No description provided for @hibernationTapKeycardToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Tap keycard to confirm'**
  String get hibernationTapKeycardToConfirm;

  /// No description provided for @hibernationKeepHoldingBrakes.
  ///
  /// In en, this message translates to:
  /// **'Keep holding brakes to force'**
  String get hibernationKeepHoldingBrakes;

  /// No description provided for @hibernationHoldBrakesForSeconds.
  ///
  /// In en, this message translates to:
  /// **'Hold both brakes for {seconds}s to force'**
  String hibernationHoldBrakesForSeconds(int seconds);

  /// No description provided for @hibernationOrHoldBrakes.
  ///
  /// In en, this message translates to:
  /// **'Or hold both brakes for 15s to force'**
  String get hibernationOrHoldBrakes;

  /// No description provided for @hibernationCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get hibernationCancel;

  /// No description provided for @hibernationKickstand.
  ///
  /// In en, this message translates to:
  /// **'Kickstand'**
  String get hibernationKickstand;

  /// No description provided for @hibernationConfirm.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get hibernationConfirm;

  /// No description provided for @hibernationTapKeycard.
  ///
  /// In en, this message translates to:
  /// **'Tap Keycard'**
  String get hibernationTapKeycard;

  /// No description provided for @hibernationSeatboxOpen.
  ///
  /// In en, this message translates to:
  /// **'Seatbox Open'**
  String get hibernationSeatboxOpen;

  /// No description provided for @hibernationCloseSeatbox.
  ///
  /// In en, this message translates to:
  /// **'Close seatbox to hibernate'**
  String get hibernationCloseSeatbox;

  /// No description provided for @hibernationHibernating.
  ///
  /// In en, this message translates to:
  /// **'Hibernating...'**
  String get hibernationHibernating;

  /// No description provided for @navRecalculating.
  ///
  /// In en, this message translates to:
  /// **'Recalculating route...'**
  String get navRecalculating;

  /// No description provided for @navYouHaveArrived.
  ///
  /// In en, this message translates to:
  /// **'You have arrived!'**
  String get navYouHaveArrived;

  /// No description provided for @navDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get navDistance;

  /// No description provided for @navRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get navRemaining;

  /// No description provided for @navEta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get navEta;

  /// No description provided for @navThen.
  ///
  /// In en, this message translates to:
  /// **'Then {instruction}'**
  String navThen(String instruction);

  /// No description provided for @navContinueFor.
  ///
  /// In en, this message translates to:
  /// **'Continue for {distanceKm} km'**
  String navContinueFor(String distanceKm);

  /// No description provided for @navKeepDirection.
  ///
  /// In en, this message translates to:
  /// **'Keep {direction}'**
  String navKeepDirection(String direction);

  /// No description provided for @navKeepDirectionOnto.
  ///
  /// In en, this message translates to:
  /// **'Keep {direction} on {street}'**
  String navKeepDirectionOnto(String direction, String street);

  /// No description provided for @navTurnDirection.
  ///
  /// In en, this message translates to:
  /// **'Turn {direction}'**
  String navTurnDirection(String direction);

  /// No description provided for @navTurnDirectionOnto.
  ///
  /// In en, this message translates to:
  /// **'Turn {direction} onto {street}'**
  String navTurnDirectionOnto(String direction, String street);

  /// No description provided for @navTakeExit.
  ///
  /// In en, this message translates to:
  /// **'Take exit {exitNumber}'**
  String navTakeExit(String exitNumber);

  /// No description provided for @navTakeExitOnto.
  ///
  /// In en, this message translates to:
  /// **'Take exit {exitNumber} onto {street}'**
  String navTakeExitOnto(String exitNumber, String street);

  /// No description provided for @navTakeSideExit.
  ///
  /// In en, this message translates to:
  /// **'Take the {side} exit'**
  String navTakeSideExit(String side);

  /// No description provided for @navTakeSideExitTo.
  ///
  /// In en, this message translates to:
  /// **'Take the {side} exit to {street}'**
  String navTakeSideExitTo(String side, String street);

  /// No description provided for @navMergeDirection.
  ///
  /// In en, this message translates to:
  /// **'Merge {direction}'**
  String navMergeDirection(String direction);

  /// No description provided for @navMergeDirectionOnto.
  ///
  /// In en, this message translates to:
  /// **'Merge {direction} onto {street}'**
  String navMergeDirectionOnto(String direction, String street);

  /// No description provided for @navContinueOnStreet.
  ///
  /// In en, this message translates to:
  /// **'Continue on {street}'**
  String navContinueOnStreet(String street);

  /// No description provided for @navContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get navContinue;

  /// No description provided for @navShortContinueStraight.
  ///
  /// In en, this message translates to:
  /// **'continue straight'**
  String get navShortContinueStraight;

  /// No description provided for @navShortKeepDirection.
  ///
  /// In en, this message translates to:
  /// **'keep {direction}'**
  String navShortKeepDirection(String direction);

  /// No description provided for @navShortTurnLeft.
  ///
  /// In en, this message translates to:
  /// **'turn left'**
  String get navShortTurnLeft;

  /// No description provided for @navShortTurnRight.
  ///
  /// In en, this message translates to:
  /// **'turn right'**
  String get navShortTurnRight;

  /// No description provided for @navShortTurnSlightlyLeft.
  ///
  /// In en, this message translates to:
  /// **'turn slightly left'**
  String get navShortTurnSlightlyLeft;

  /// No description provided for @navShortTurnSlightlyRight.
  ///
  /// In en, this message translates to:
  /// **'turn slightly right'**
  String get navShortTurnSlightlyRight;

  /// No description provided for @navShortTurnSharplyLeft.
  ///
  /// In en, this message translates to:
  /// **'turn sharply left'**
  String get navShortTurnSharplyLeft;

  /// No description provided for @navShortTurnSharplyRight.
  ///
  /// In en, this message translates to:
  /// **'turn sharply right'**
  String get navShortTurnSharplyRight;

  /// No description provided for @navShortUturn.
  ///
  /// In en, this message translates to:
  /// **'make a U-turn'**
  String get navShortUturn;

  /// No description provided for @navShortUturnRight.
  ///
  /// In en, this message translates to:
  /// **'make a right U-turn'**
  String get navShortUturnRight;

  /// No description provided for @navShortMerge.
  ///
  /// In en, this message translates to:
  /// **'merge'**
  String get navShortMerge;

  /// No description provided for @navShortMergeLeft.
  ///
  /// In en, this message translates to:
  /// **'merge left'**
  String get navShortMergeLeft;

  /// No description provided for @navShortMergeRight.
  ///
  /// In en, this message translates to:
  /// **'merge right'**
  String get navShortMergeRight;

  /// No description provided for @navShortContinue.
  ///
  /// In en, this message translates to:
  /// **'continue'**
  String get navShortContinue;

  /// No description provided for @navShortTakeSideExit.
  ///
  /// In en, this message translates to:
  /// **'take the {side} exit'**
  String navShortTakeSideExit(String side);

  /// No description provided for @navShortTakeNumberedExit.
  ///
  /// In en, this message translates to:
  /// **'take the {exitNumber} exit'**
  String navShortTakeNumberedExit(String exitNumber);

  /// No description provided for @navReturnToRoute.
  ///
  /// In en, this message translates to:
  /// **'Return to the route'**
  String get navReturnToRoute;

  /// No description provided for @navCurrentPositionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Current position not available'**
  String get navCurrentPositionNotAvailable;

  /// No description provided for @navCouldNotCalculateRoute.
  ///
  /// In en, this message translates to:
  /// **'Could not calculate route'**
  String get navCouldNotCalculateRoute;

  /// No description provided for @navDestinationUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Destination is unreachable. Please select a different location.'**
  String get navDestinationUnreachable;

  /// No description provided for @navNewDestination.
  ///
  /// In en, this message translates to:
  /// **'New navigation destination received. Calculating route...'**
  String get navNewDestination;

  /// No description provided for @navWaitingForGps.
  ///
  /// In en, this message translates to:
  /// **'Waiting for GPS fix'**
  String get navWaitingForGps;

  /// No description provided for @navWaitingForGpsRoute.
  ///
  /// In en, this message translates to:
  /// **'Waiting for recent GPS fix to calculate route.'**
  String get navWaitingForGpsRoute;

  /// No description provided for @navResumingNavigation.
  ///
  /// In en, this message translates to:
  /// **'Resuming navigation.'**
  String get navResumingNavigation;

  /// No description provided for @navArrivedAtDestination.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at your destination!'**
  String get navArrivedAtDestination;

  /// No description provided for @navOffRouteRerouting.
  ///
  /// In en, this message translates to:
  /// **'Off route. Attempting to reroute...'**
  String get navOffRouteRerouting;

  /// No description provided for @navCouldNotCalculateNewRoute.
  ///
  /// In en, this message translates to:
  /// **'Could not calculate new route'**
  String get navCouldNotCalculateNewRoute;

  /// No description provided for @batteryKm.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get batteryKm;

  /// No description provided for @batteryCbNotCharging.
  ///
  /// In en, this message translates to:
  /// **'CB Battery not charging'**
  String get batteryCbNotCharging;

  /// No description provided for @batteryAuxLowNotCharging.
  ///
  /// In en, this message translates to:
  /// **'AUX Battery low and not charging'**
  String get batteryAuxLowNotCharging;

  /// No description provided for @batteryAuxVoltageLow.
  ///
  /// In en, this message translates to:
  /// **'AUX Battery voltage low'**
  String get batteryAuxVoltageLow;

  /// No description provided for @batteryAuxVoltageVeryLowReplace.
  ///
  /// In en, this message translates to:
  /// **'AUX Battery voltage very low - may need replacement'**
  String get batteryAuxVoltageVeryLowReplace;

  /// No description provided for @batteryAuxVoltageVeryLowCharge.
  ///
  /// In en, this message translates to:
  /// **'AUX Battery voltage very low - insert main battery to charge'**
  String get batteryAuxVoltageVeryLowCharge;

  /// No description provided for @batteryEmptyRecharge.
  ///
  /// In en, this message translates to:
  /// **'Battery empty. Recharge battery'**
  String get batteryEmptyRecharge;

  /// No description provided for @batteryMaxSpeedReduced.
  ///
  /// In en, this message translates to:
  /// **'Max speed is reduced. Battery is below 5%'**
  String get batteryMaxSpeedReduced;

  /// No description provided for @batteryLowPowerReduced.
  ///
  /// In en, this message translates to:
  /// **'Battery low. Power reduced. Please recharge battery'**
  String get batteryLowPowerReduced;

  /// No description provided for @batteryLowPowerReducedShort.
  ///
  /// In en, this message translates to:
  /// **'Battery low. Power reduced. Recharge battery'**
  String get batteryLowPowerReducedShort;

  /// No description provided for @batterySlot0.
  ///
  /// In en, this message translates to:
  /// **'Battery 0'**
  String get batterySlot0;

  /// No description provided for @batterySlot1.
  ///
  /// In en, this message translates to:
  /// **'Battery 1'**
  String get batterySlot1;

  /// No description provided for @speedKmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get speedKmh;

  /// No description provided for @powerRegen.
  ///
  /// In en, this message translates to:
  /// **'REGEN'**
  String get powerRegen;

  /// No description provided for @powerDischarge.
  ///
  /// In en, this message translates to:
  /// **'DISCHARGE'**
  String get powerDischarge;

  /// No description provided for @controlLeftBrake.
  ///
  /// In en, this message translates to:
  /// **'Left Brake'**
  String get controlLeftBrake;

  /// No description provided for @controlRightBrake.
  ///
  /// In en, this message translates to:
  /// **'Right Brake'**
  String get controlRightBrake;

  /// No description provided for @controlNextItem.
  ///
  /// In en, this message translates to:
  /// **'Next Item'**
  String get controlNextItem;

  /// No description provided for @controlSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get controlSelect;

  /// No description provided for @controlPressRightBrakeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Press Right Brake to Confirm'**
  String get controlPressRightBrakeConfirm;

  /// No description provided for @controlPressLeftBrakeEdit.
  ///
  /// In en, this message translates to:
  /// **'Press Left Brake to Edit'**
  String get controlPressLeftBrakeEdit;

  /// No description provided for @statusBarDuration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get statusBarDuration;

  /// No description provided for @statusBarAvgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Ø SPEED'**
  String get statusBarAvgSpeed;

  /// No description provided for @statusBarTrip.
  ///
  /// In en, this message translates to:
  /// **'TRIP'**
  String get statusBarTrip;

  /// No description provided for @statusBarTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get statusBarTotal;

  /// No description provided for @statusBarKmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get statusBarKmh;

  /// No description provided for @odometerTrip.
  ///
  /// In en, this message translates to:
  /// **'TRIP'**
  String get odometerTrip;

  /// No description provided for @odometerTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get odometerTotal;

  /// No description provided for @odometerAvgSpeed.
  ///
  /// In en, this message translates to:
  /// **'AVG SPEED'**
  String get odometerAvgSpeed;

  /// No description provided for @odometerAvgSpeedValue.
  ///
  /// In en, this message translates to:
  /// **'{speed} km/h'**
  String odometerAvgSpeedValue(String speed);

  /// No description provided for @odometerTripTime.
  ///
  /// In en, this message translates to:
  /// **'TRIP TIME'**
  String get odometerTripTime;

  /// No description provided for @addressEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get addressEditAction;

  /// No description provided for @addressScrollAction.
  ///
  /// In en, this message translates to:
  /// **'Scroll'**
  String get addressScrollAction;

  /// No description provided for @addressConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get addressConfirmAction;

  /// No description provided for @addressNextAction.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get addressNextAction;

  /// No description provided for @addressCloseAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get addressCloseAction;

  /// No description provided for @addressScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Destination Code'**
  String get addressScreenTitle;

  /// No description provided for @standbyWarning.
  ///
  /// In en, this message translates to:
  /// **'Vehicle will enter standby in'**
  String get standbyWarning;

  /// No description provided for @standbySeconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get standbySeconds;

  /// No description provided for @standbyCancel.
  ///
  /// In en, this message translates to:
  /// **'Press brake or move kickstand to cancel'**
  String get standbyCancel;

  /// No description provided for @bluetoothError.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth: {errorMessage}'**
  String bluetoothError(String errorMessage);

  /// No description provided for @bluetoothCommError.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth service communication error'**
  String get bluetoothCommError;

  /// No description provided for @bluetoothPinInstruction.
  ///
  /// In en, this message translates to:
  /// **'Use this code to pair your device'**
  String get bluetoothPinInstruction;

  /// No description provided for @lowTempMotor.
  ///
  /// In en, this message translates to:
  /// **'Motor'**
  String get lowTempMotor;

  /// No description provided for @lowTempBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get lowTempBattery;

  /// No description provided for @lowTemp12vBattery.
  ///
  /// In en, this message translates to:
  /// **'12V Battery'**
  String get lowTemp12vBattery;

  /// No description provided for @lowTempWarning.
  ///
  /// In en, this message translates to:
  /// **'Low Temperatures - Ride Carefully'**
  String get lowTempWarning;

  /// No description provided for @faultSignalWireBroken.
  ///
  /// In en, this message translates to:
  /// **'Signal wire broken'**
  String get faultSignalWireBroken;

  /// No description provided for @faultCriticalOverTemp.
  ///
  /// In en, this message translates to:
  /// **'Critical over-temperature'**
  String get faultCriticalOverTemp;

  /// No description provided for @faultShortCircuit.
  ///
  /// In en, this message translates to:
  /// **'Short circuit'**
  String get faultShortCircuit;

  /// No description provided for @faultBmsNotFollowing.
  ///
  /// In en, this message translates to:
  /// **'BMS not following commands'**
  String get faultBmsNotFollowing;

  /// No description provided for @faultBmsCommError.
  ///
  /// In en, this message translates to:
  /// **'BMS communication error'**
  String get faultBmsCommError;

  /// No description provided for @faultNfcReaderError.
  ///
  /// In en, this message translates to:
  /// **'NFC reader error'**
  String get faultNfcReaderError;

  /// No description provided for @faultOverTempCharging.
  ///
  /// In en, this message translates to:
  /// **'Over-temperature while charging'**
  String get faultOverTempCharging;

  /// No description provided for @faultUnderTempCharging.
  ///
  /// In en, this message translates to:
  /// **'Under-temperature while charging'**
  String get faultUnderTempCharging;

  /// No description provided for @faultOverTempDischarging.
  ///
  /// In en, this message translates to:
  /// **'Over-temperature while discharging'**
  String get faultOverTempDischarging;

  /// No description provided for @faultUnderTempDischarging.
  ///
  /// In en, this message translates to:
  /// **'Under-temperature while discharging'**
  String get faultUnderTempDischarging;

  /// No description provided for @faultMosfetOverTemp.
  ///
  /// In en, this message translates to:
  /// **'MOSFET over-temperature'**
  String get faultMosfetOverTemp;

  /// No description provided for @faultCellOverVoltage.
  ///
  /// In en, this message translates to:
  /// **'Cell over-voltage'**
  String get faultCellOverVoltage;

  /// No description provided for @faultCellUnderVoltage.
  ///
  /// In en, this message translates to:
  /// **'Cell under-voltage'**
  String get faultCellUnderVoltage;

  /// No description provided for @faultOverCurrentCharging.
  ///
  /// In en, this message translates to:
  /// **'Over-current while charging'**
  String get faultOverCurrentCharging;

  /// No description provided for @faultOverCurrentDischarging.
  ///
  /// In en, this message translates to:
  /// **'Over-current while discharging'**
  String get faultOverCurrentDischarging;

  /// No description provided for @faultPackOverVoltage.
  ///
  /// In en, this message translates to:
  /// **'Pack over-voltage'**
  String get faultPackOverVoltage;

  /// No description provided for @faultPackUnderVoltage.
  ///
  /// In en, this message translates to:
  /// **'Pack under-voltage'**
  String get faultPackUnderVoltage;

  /// No description provided for @faultReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get faultReserved;

  /// No description provided for @faultBmsZeroData.
  ///
  /// In en, this message translates to:
  /// **'BMS has zero data'**
  String get faultBmsZeroData;

  /// No description provided for @faultUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown fault'**
  String get faultUnknown;

  /// No description provided for @faultMultipleCritical.
  ///
  /// In en, this message translates to:
  /// **'Multiple Critical Issues'**
  String get faultMultipleCritical;

  /// No description provided for @faultMultipleBattery.
  ///
  /// In en, this message translates to:
  /// **'Multiple Battery Issues'**
  String get faultMultipleBattery;

  /// No description provided for @addressLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading address database...'**
  String get addressLoading;

  /// No description provided for @addressMapNotFound.
  ///
  /// In en, this message translates to:
  /// **'Map file not found.'**
  String get addressMapNotFound;

  /// No description provided for @addressRebuildingHash.
  ///
  /// In en, this message translates to:
  /// **'Rebuilding address database due to hash mismatch...'**
  String get addressRebuildingHash;

  /// No description provided for @addressHashMismatch.
  ///
  /// In en, this message translates to:
  /// **'Map hash mismatch after rebuild.'**
  String get addressHashMismatch;

  /// No description provided for @addressCreatingDb.
  ///
  /// In en, this message translates to:
  /// **'Creating address database...'**
  String get addressCreatingDb;

  /// No description provided for @addressBuildFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to build address database.'**
  String get addressBuildFailed;

  /// No description provided for @savedLocationsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load saved locations'**
  String get savedLocationsFailed;

  /// No description provided for @aboutNonCommercialTitle.
  ///
  /// In en, this message translates to:
  /// **'NON-COMMERCIAL SOFTWARE'**
  String get aboutNonCommercialTitle;

  /// No description provided for @aboutFossDescription.
  ///
  /// In en, this message translates to:
  /// **'FOSS firmware for unu Scooter Pro e-mopeds'**
  String get aboutFossDescription;

  /// No description provided for @aboutCommercialProhibited.
  ///
  /// In en, this message translates to:
  /// **'Commercial distribution, resale, or preinstallation on devices for sale is prohibited under {licenseId}.'**
  String aboutCommercialProhibited(String licenseId);

  /// No description provided for @aboutScamWarning.
  ///
  /// In en, this message translates to:
  /// **'If you paid money for this software, you may have been the victim of a scam. Please report it at {websiteUrl}.'**
  String aboutScamWarning(String websiteUrl);

  /// No description provided for @aboutOpenSourceComponents.
  ///
  /// In en, this message translates to:
  /// **'OPEN SOURCE COMPONENTS'**
  String get aboutOpenSourceComponents;

  /// No description provided for @aboutScrollAction.
  ///
  /// In en, this message translates to:
  /// **'Scroll'**
  String get aboutScrollAction;

  /// No description provided for @aboutBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get aboutBackAction;

  /// No description provided for @aboutBootThemeRestored.
  ///
  /// In en, this message translates to:
  /// **'Boot theme: LibreScoot restored.'**
  String get aboutBootThemeRestored;

  /// No description provided for @aboutGenuineAdvantage.
  ///
  /// In en, this message translates to:
  /// **'Genuine Advantage activated.'**
  String get aboutGenuineAdvantage;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection to vehicle system lost'**
  String get connectionLost;

  /// No description provided for @connectionReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Attempting to reconnect to vehicle system...'**
  String get connectionReconnecting;

  /// No description provided for @connectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Connected to vehicle system'**
  String get connectionRestored;

  /// No description provided for @shortcutPressToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Press to confirm'**
  String get shortcutPressToConfirm;

  /// No description provided for @carplayDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from CarPlay'**
  String get carplayDisconnected;

  /// No description provided for @carplayConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to CarPlay...'**
  String get carplayConnecting;

  /// No description provided for @carplayConnectingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connecting to localhost:8001...'**
  String get carplayConnectingSubtitle;

  /// No description provided for @carplayInitializingStream.
  ///
  /// In en, this message translates to:
  /// **'Initializing MJPEG stream'**
  String get carplayInitializingStream;

  /// No description provided for @carplayConnectionError.
  ///
  /// In en, this message translates to:
  /// **'CarPlay Connection Error'**
  String get carplayConnectionError;

  /// No description provided for @carplayRetryConnection.
  ///
  /// In en, this message translates to:
  /// **'Retry Connection'**
  String get carplayRetryConnection;

  /// No description provided for @carplayWaitingForVideo.
  ///
  /// In en, this message translates to:
  /// **'Waiting for video...'**
  String get carplayWaitingForVideo;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError('AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
