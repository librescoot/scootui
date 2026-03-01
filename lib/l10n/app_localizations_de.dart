// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get menuTitle => 'MENÜ';

  @override
  String get menuToggleHazardLights => 'Warnblinker umschalten';

  @override
  String get menuSwitchToCluster => 'Zur Tacho-Ansicht';

  @override
  String get menuSwitchToMap => 'Zur Kartenansicht';

  @override
  String get menuNavigation => 'Navigation';

  @override
  String get menuNavigationHeader => 'NAVIGATION';

  @override
  String get menuEnterDestinationCode => 'Zielcode eingeben';

  @override
  String get menuSavedLocations => 'Gespeicherte Orte';

  @override
  String get menuSavedLocationsHeader => 'GESPEICHERTE ORTE';

  @override
  String get menuSaveCurrentLocation => 'Aktuellen Standort speichern';

  @override
  String get menuStartNavigation => 'Navigation starten';

  @override
  String get menuDeleteLocation => 'Ort löschen';

  @override
  String get menuStopNavigation => 'Navigation beenden';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get menuSettingsHeader => 'EINSTELLUNGEN';

  @override
  String get menuTheme => 'Design';

  @override
  String get menuThemeHeader => 'DESIGN ÄNDERN';

  @override
  String get menuThemeAutomatic => 'Automatisch';

  @override
  String get menuThemeDark => 'Dunkel';

  @override
  String get menuThemeLight => 'Hell';

  @override
  String get menuLanguage => 'Sprache';

  @override
  String get menuLanguageHeader => 'SPRACHE';

  @override
  String get menuStatusBar => 'Statusleiste';

  @override
  String get menuBatteryDisplay => 'Batterieanzeige';

  @override
  String get menuBatteryPercentage => 'Prozent';

  @override
  String get menuBatteryRange => 'Reichweite (km)';

  @override
  String get menuGpsIcon => 'GPS-Symbol';

  @override
  String get menuBluetoothIcon => 'Bluetooth-Symbol';

  @override
  String get menuCloudIcon => 'Cloud-Symbol';

  @override
  String get menuInternetIcon => 'Internet-Symbol';

  @override
  String get menuClock => 'Uhr';

  @override
  String get menuAlways => 'Immer';

  @override
  String get menuActiveOrError => 'Aktiv oder Fehler';

  @override
  String get menuErrorOnly => 'Nur Fehler';

  @override
  String get menuNever => 'Nie';

  @override
  String get menuMapAndNavigation => 'Karte & Navigation';

  @override
  String get menuRenderingMode => 'Darstellungsmodus';

  @override
  String get menuVector => 'Vektor';

  @override
  String get menuRaster => 'Raster';

  @override
  String get menuMapType => 'Kartentyp';

  @override
  String get menuOnline => 'Online';

  @override
  String get menuOffline => 'Offline';

  @override
  String get menuSystem => 'System';

  @override
  String get menuEnterUmsMode => 'UMS-Modus starten';

  @override
  String get menuResetTripStatistics => 'Reisestatistik zurücksetzen';

  @override
  String get menuAboutAndLicenses => 'Über & Lizenzen';

  @override
  String get menuExitMenu => 'Menü schließen';

  @override
  String get shutdownShuttingDown => 'Wird heruntergefahren...';

  @override
  String get shutdownComplete => 'Herunterfahren abgeschlossen.\nKeycard antippen zum Entsperren.';

  @override
  String get shutdownSuspending => 'Wird pausiert...';

  @override
  String get shutdownHibernationImminent => 'Ruhezustand steht bevor...';

  @override
  String get shutdownSuspensionImminent => 'Standby steht bevor...';

  @override
  String get shutdownProcessing => 'Verarbeitung...';

  @override
  String otaUpdateMessage(String action, String version) {
    return '$action Update$version.\nDein Roller wird danach ausgeschaltet.\nDu kannst ihn jederzeit wieder entsperren.';
  }

  @override
  String get otaDownloading => 'Lade herunter';

  @override
  String get otaInstalling => 'Installiere';

  @override
  String get otaInitializing => 'Update wird initialisiert...';

  @override
  String get otaCheckingUpdates => 'Suche nach Updates...';

  @override
  String get otaCheckFailed => 'Update-Prüfung fehlgeschlagen.';

  @override
  String get otaDeviceUpdated => 'Gerät aktualisiert.';

  @override
  String get otaWaitingDashboard => 'Warte auf Dashboard...';

  @override
  String get otaDownloadingUpdates => 'Updates werden heruntergeladen...';

  @override
  String get otaDownloadFailed => 'Download fehlgeschlagen.';

  @override
  String get otaInstallingUpdates => 'Updates werden installiert...';

  @override
  String get otaInstallFailed => 'Installation fehlgeschlagen.';

  @override
  String get otaCompleteWaitingDashboardReboot => 'Installation abgeschlossen, warte auf Dashboard-Neustart...';

  @override
  String get otaCompleteWaitingReboot => 'Installation abgeschlossen, warte auf Neustart...';

  @override
  String otaDownloadingVersionUpdate(String versionText) {
    return 'Lade$versionText Update herunter';
  }

  @override
  String otaInstallingVersionUpdate(String versionText) {
    return 'Installiere$versionText Update';
  }

  @override
  String get otaWaitingForReboot => 'Update installiert. Warte auf Neustart';

  @override
  String otaUpdateFailedWithMessage(String errorMessage) {
    return 'Update fehlgeschlagen: $errorMessage';
  }

  @override
  String otaUpdateVersionFailed(String versionText) {
    return 'Update$versionText fehlgeschlagen';
  }

  @override
  String get otaStatusWaitingForReboot => 'Warte auf Neustart';

  @override
  String get otaStatusDownloading => 'Wird heruntergeladen';

  @override
  String get otaStatusInstalling => 'Wird installiert';

  @override
  String otaLibrescootVersion(String version) {
    return ' Librescoot $version';
  }

  @override
  String get otaUpdate => ' Update';

  @override
  String get otaInvalidRelease => 'Ungültige Version';

  @override
  String get otaDownloadFailedShort => 'Download fehlgeschlagen';

  @override
  String get otaInstallFailedShort => 'Installation fehlgeschlagen';

  @override
  String get otaRebootFailed => 'Neustart fehlgeschlagen';

  @override
  String get otaUpdateError => 'Update-Fehler';

  @override
  String get umsPreparingStorage => 'USB-Speicher wird vorbereitet...';

  @override
  String get umsProcessingFiles => 'Dateien werden verarbeitet...';

  @override
  String umsStatus(String status) {
    return 'USB-Massenspeicher: $status';
  }

  @override
  String get umsTitle => 'USB-Massenspeichermodus';

  @override
  String get umsConnectToComputer => 'Zum Dateitransfer mit Computer verbinden.';

  @override
  String get hibernationTitle => 'Manueller Ruhezustand';

  @override
  String get hibernationTapKeycardToConfirm => 'Keycard antippen zum Bestätigen';

  @override
  String get hibernationKeepHoldingBrakes => 'Bremsen weiterhin halten zum Erzwingen';

  @override
  String hibernationHoldBrakesForSeconds(int seconds) {
    return 'Beide Bremsen für ${seconds}s halten zum Erzwingen';
  }

  @override
  String get hibernationOrHoldBrakes => 'Oder beide Bremsen 15s halten zum Erzwingen';

  @override
  String get hibernationCancel => 'ABBRECHEN';

  @override
  String get hibernationKickstand => 'Seitenständer';

  @override
  String get hibernationConfirm => 'BESTÄTIGEN';

  @override
  String get hibernationTapKeycard => 'Keycard antippen';

  @override
  String get hibernationSeatboxOpen => 'Sitzbank offen';

  @override
  String get hibernationCloseSeatbox => 'Sitzbank schließen für Ruhezustand';

  @override
  String get hibernationHibernating => 'Ruhezustand wird aktiviert...';

  @override
  String get navRecalculating => 'Route wird neu berechnet...';

  @override
  String get navYouHaveArrived => 'Ziel erreicht!';

  @override
  String get navDistance => 'Entfernung';

  @override
  String get navRemaining => 'Verbleibend';

  @override
  String get navEta => 'Ankunft';

  @override
  String navThen(String instruction) {
    return 'Dann $instruction';
  }

  @override
  String navContinueFor(String distanceKm) {
    return 'Weiter für $distanceKm km';
  }

  @override
  String navKeepDirection(String direction) {
    return '$direction halten';
  }

  @override
  String navKeepDirectionOnto(String direction, String street) {
    return '$direction halten auf $street';
  }

  @override
  String navTurnDirection(String direction) {
    return '$direction abbiegen';
  }

  @override
  String navTurnDirectionOnto(String direction, String street) {
    return '$direction abbiegen auf $street';
  }

  @override
  String navTakeExit(String exitNumber) {
    return 'Ausfahrt $exitNumber nehmen';
  }

  @override
  String navTakeExitOnto(String exitNumber, String street) {
    return 'Ausfahrt $exitNumber nehmen auf $street';
  }

  @override
  String navTakeSideExit(String side) {
    return 'Die $side Ausfahrt nehmen';
  }

  @override
  String navTakeSideExitTo(String side, String street) {
    return 'Die $side Ausfahrt nehmen nach $street';
  }

  @override
  String navMergeDirection(String direction) {
    return '$direction einfädeln';
  }

  @override
  String navMergeDirectionOnto(String direction, String street) {
    return '$direction einfädeln auf $street';
  }

  @override
  String navContinueOnStreet(String street) {
    return 'Weiter auf $street';
  }

  @override
  String get navContinue => 'Weiter';

  @override
  String get navShortContinueStraight => 'geradeaus weiter';

  @override
  String navShortKeepDirection(String direction) {
    return '$direction halten';
  }

  @override
  String get navShortTurnLeft => 'links abbiegen';

  @override
  String get navShortTurnRight => 'rechts abbiegen';

  @override
  String get navShortTurnSlightlyLeft => 'leicht links abbiegen';

  @override
  String get navShortTurnSlightlyRight => 'leicht rechts abbiegen';

  @override
  String get navShortTurnSharplyLeft => 'scharf links abbiegen';

  @override
  String get navShortTurnSharplyRight => 'scharf rechts abbiegen';

  @override
  String get navShortUturn => 'wenden';

  @override
  String get navShortUturnRight => 'rechts wenden';

  @override
  String get navShortMerge => 'einfädeln';

  @override
  String get navShortMergeLeft => 'links einfädeln';

  @override
  String get navShortMergeRight => 'rechts einfädeln';

  @override
  String get navShortContinue => 'weiter';

  @override
  String navShortTakeSideExit(String side) {
    return 'die $side Ausfahrt nehmen';
  }

  @override
  String navShortTakeNumberedExit(String exitNumber) {
    return 'die $exitNumber Ausfahrt nehmen';
  }

  @override
  String get navReturnToRoute => 'Zurück zur Route';

  @override
  String get navCurrentPositionNotAvailable => 'Aktuelle Position nicht verfügbar';

  @override
  String get navCouldNotCalculateRoute => 'Route konnte nicht berechnet werden';

  @override
  String get navDestinationUnreachable => 'Ziel ist nicht erreichbar. Bitte anderen Standort wählen.';

  @override
  String get navNewDestination => 'Neues Navigationsziel empfangen. Route wird berechnet...';

  @override
  String get navWaitingForGps => 'Warte auf GPS-Signal';

  @override
  String get navWaitingForGpsRoute => 'Warte auf GPS-Signal zur Routenberechnung.';

  @override
  String get navResumingNavigation => 'Navigation wird fortgesetzt.';

  @override
  String get navArrivedAtDestination => 'Du hast dein Ziel erreicht!';

  @override
  String get navOffRouteRerouting => 'Abseits der Route. Neue Route wird berechnet...';

  @override
  String get navCouldNotCalculateNewRoute => 'Neue Route konnte nicht berechnet werden';

  @override
  String get batteryKm => 'km';

  @override
  String get batteryCbNotCharging => 'CB-Batterie lädt nicht';

  @override
  String get batteryAuxLowNotCharging => 'AUX-Batterie schwach und lädt nicht';

  @override
  String get batteryAuxVoltageLow => 'AUX-Batterie Spannung niedrig';

  @override
  String get batteryAuxVoltageVeryLowReplace => 'AUX-Batterie Spannung sehr niedrig - evtl. Austausch nötig';

  @override
  String get batteryAuxVoltageVeryLowCharge => 'AUX-Batterie Spannung sehr niedrig - Hauptbatterie einsetzen zum Laden';

  @override
  String get batteryEmptyRecharge => 'Batterie leer. Bitte aufladen';

  @override
  String get batteryMaxSpeedReduced => 'Höchstgeschwindigkeit reduziert. Batterie unter 5%';

  @override
  String get batteryLowPowerReduced => 'Batterie schwach. Leistung reduziert. Bitte aufladen';

  @override
  String get batteryLowPowerReducedShort => 'Batterie schwach. Leistung reduziert. Bitte aufladen';

  @override
  String get batterySlot0 => 'Batterie 0';

  @override
  String get batterySlot1 => 'Batterie 1';

  @override
  String get speedKmh => 'km/h';

  @override
  String get powerRegen => 'REKU';

  @override
  String get powerDischarge => 'ENTLADUNG';

  @override
  String get controlLeftBrake => 'Linke Bremse';

  @override
  String get controlRightBrake => 'Rechte Bremse';

  @override
  String get odometerTrip => 'STRECKE';

  @override
  String get odometerTotal => 'GESAMT';

  @override
  String get odometerAvgSpeed => 'Ø TEMPO';

  @override
  String odometerAvgSpeedValue(String speed) {
    return '$speed km/h';
  }

  @override
  String get odometerTripTime => 'FAHRZEIT';

  @override
  String get addressEditAction => 'Ändern';

  @override
  String get addressScrollAction => 'Scrollen';

  @override
  String get addressConfirmAction => 'Bestätigen';

  @override
  String get addressNextAction => 'Weiter';

  @override
  String get addressCloseAction => 'Schließen';

  @override
  String get addressScreenTitle => 'Zielcode eingeben';

  @override
  String get standbyWarning => 'Fahrzeug geht in Standby in';

  @override
  String get standbySeconds => 'Sekunden';

  @override
  String get standbyCancel => 'Bremse drücken oder Seitenständer bewegen zum Abbrechen';

  @override
  String bluetoothError(String errorMessage) {
    return 'Bluetooth: $errorMessage';
  }

  @override
  String get bluetoothCommError => 'Bluetooth-Kommunikationsfehler';

  @override
  String get bluetoothPinInstruction => 'Diesen Code zum Koppeln verwenden';

  @override
  String get lowTempMotor => 'Motor';

  @override
  String get lowTempBattery => 'Batterie';

  @override
  String get lowTemp12vBattery => '12V-Batterie';

  @override
  String get lowTempWarning => 'Niedrige Temperaturen - Vorsichtig fahren';

  @override
  String get faultSignalWireBroken => 'Signaldraht defekt';

  @override
  String get faultCriticalOverTemp => 'Kritische Übertemperatur';

  @override
  String get faultShortCircuit => 'Kurzschluss';

  @override
  String get faultBmsNotFollowing => 'BMS reagiert nicht auf Befehle';

  @override
  String get faultBmsCommError => 'BMS-Kommunikationsfehler';

  @override
  String get faultNfcReaderError => 'NFC-Leser Fehler';

  @override
  String get faultOverTempCharging => 'Übertemperatur beim Laden';

  @override
  String get faultUnderTempCharging => 'Untertemperatur beim Laden';

  @override
  String get faultOverTempDischarging => 'Übertemperatur beim Entladen';

  @override
  String get faultUnderTempDischarging => 'Untertemperatur beim Entladen';

  @override
  String get faultMosfetOverTemp => 'MOSFET-Übertemperatur';

  @override
  String get faultCellOverVoltage => 'Zellen-Überspannung';

  @override
  String get faultCellUnderVoltage => 'Zellen-Unterspannung';

  @override
  String get faultOverCurrentCharging => 'Überstrom beim Laden';

  @override
  String get faultOverCurrentDischarging => 'Überstrom beim Entladen';

  @override
  String get faultPackOverVoltage => 'Pack-Überspannung';

  @override
  String get faultPackUnderVoltage => 'Pack-Unterspannung';

  @override
  String get faultReserved => 'Reserviert';

  @override
  String get faultBmsZeroData => 'BMS hat keine Daten';

  @override
  String get faultUnknown => 'Unbekannter Fehler';

  @override
  String get faultMultipleCritical => 'Mehrere kritische Probleme';

  @override
  String get faultMultipleBattery => 'Mehrere Batterieprobleme';

  @override
  String get addressLoading => 'Adressdatenbank wird geladen...';

  @override
  String get addressMapNotFound => 'Kartendatei nicht gefunden.';

  @override
  String get addressRebuildingHash => 'Adressdatenbank wird wegen Hash-Abweichung neu erstellt...';

  @override
  String get addressHashMismatch => 'Hash-Abweichung nach Neuerstellung.';

  @override
  String get addressCreatingDb => 'Adressdatenbank wird erstellt...';

  @override
  String get addressBuildFailed => 'Adressdatenbank konnte nicht erstellt werden.';

  @override
  String get savedLocationsFailed => 'Gespeicherte Orte konnten nicht geladen werden';

  @override
  String get aboutNonCommercialTitle => 'NICHT-KOMMERZIELLE SOFTWARE';

  @override
  String get aboutFossDescription => 'FOSS-Firmware für unu Scooter Pro E-Mopeds';

  @override
  String aboutCommercialProhibited(String licenseId) {
    return 'Kommerzieller Vertrieb, Weiterverkauf oder Vorinstallation auf Geräten zum Verkauf ist unter $licenseId untersagt.';
  }

  @override
  String aboutScamWarning(String websiteUrl) {
    return 'Falls du für diese Software bezahlt hast, bist du möglicherweise Opfer eines Betrugs geworden. Bitte melde es auf $websiteUrl.';
  }

  @override
  String get aboutOpenSourceComponents => 'OPEN-SOURCE-KOMPONENTEN';

  @override
  String get aboutScrollAction => 'Scrollen';

  @override
  String get aboutBackAction => 'Zurück';

  @override
  String get aboutBootThemeRestored => 'Boot-Theme: LibreScoot wiederhergestellt.';

  @override
  String get aboutGenuineAdvantage => 'Genuine Advantage aktiviert.';
}
