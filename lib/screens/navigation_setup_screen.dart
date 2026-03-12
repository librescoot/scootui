import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../cubits/map_download_cubit.dart';
import '../cubits/mdb_cubits.dart';
import '../cubits/navigation_availability_cubit.dart';
import '../cubits/screen_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../l10n/l10n.dart';
import '../state/enums.dart';
import '../state/gps.dart';
import '../widgets/general/control_gestures_detector.dart';
import '../widgets/general/control_hints.dart';

const _docsUrl = 'https://librescoot.org/docs/navigation.html';

class NavigationSetupScreen extends StatelessWidget {
  final SetupMode mode;

  const NavigationSetupScreen({super.key, this.mode = SetupMode.both});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapDownloadCubit(),
      child: _Content(mode: mode),
    );
  }
}

class _Content extends StatelessWidget {
  final SetupMode mode;

  const _Content({required this.mode});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeCubit.watch(context).isDark;
    final navState = NavigationAvailabilityCubit.watch(context);
    final l10n = context.l10n;
    final vehicleSync = context.read<VehicleSync>();

    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;
    final fgDim = isDark ? Colors.white60 : Colors.black54;
    final divider = isDark ? Colors.white12 : Colors.black12;

    final downloadState = context.watch<MapDownloadCubit>().state;
    final needsDisplayMaps = !navState.localDisplayMapsAvailable;
    final needsRoutingMaps = !navState.routingAvailable;
    final hasRelevantPartial = switch (mode) {
      SetupMode.displayMaps => downloadState.hasPartialDisplayDownload,
      SetupMode.routing => downloadState.hasPartialRoutingDownload,
      SetupMode.both => downloadState.hasPartialDownload,
    };
    final showDownloadSection = switch (mode) {
      SetupMode.displayMaps => needsDisplayMaps || downloadState.updateAvailable || hasRelevantPartial,
      SetupMode.routing => needsRoutingMaps || downloadState.updateAvailable || hasRelevantPartial,
      SetupMode.both => needsDisplayMaps || needsRoutingMaps || downloadState.updateAvailable || hasRelevantPartial,
    };

    final internet = context.watch<InternetSync>().state;
    final gps = context.watch<GpsSync>().state;
    final isOnline = internet.status == ConnectionStatus.connected;
    final hasGps = gps.state == GpsState.fixEstablished && gps.latitude != 0;
    final canDownload = showDownloadSection &&
        downloadState.status == MapDownloadStatus.idle &&
        isOnline &&
        hasGps;

    if (hasGps && isOnline && downloadState.regionName == null) {
      context.read<MapDownloadCubit>().resolveRegion(gps.latitude, gps.longitude);
    }

    final String downloadLabel;
    if (downloadState.updateAvailable) {
      downloadLabel = l10n.navSetupUpdateButton;
    } else if (hasRelevantPartial) {
      downloadLabel = l10n.navSetupResumeButton;
    } else {
      downloadLabel = l10n.navSetupDownloadButton;
    }

    void triggerDownload() {
      context.read<MapDownloadCubit>().startDownload(
            latitude: gps.latitude,
            longitude: gps.longitude,
            needsDisplayMaps: downloadState.updateAvailable || (mode != SetupMode.routing && needsDisplayMaps),
            needsRoutingMaps: downloadState.updateAvailable || (mode != SetupMode.displayMaps && needsRoutingMaps),
          );
    }

    final String title;
    switch (mode) {
      case SetupMode.displayMaps:
        title = l10n.navSetupTitleMapsUnavailable;
      case SetupMode.routing:
        title = l10n.navSetupTitleRoutingUnavailable;
      case SetupMode.both:
        if (needsRoutingMaps && needsDisplayMaps) {
          title = l10n.navSetupTitleBothUnavailable;
        } else if (needsRoutingMaps) {
          title = l10n.navSetupTitleRoutingUnavailable;
        } else if (needsDisplayMaps) {
          title = l10n.navSetupTitleMapsUnavailable;
        } else {
          title = l10n.navSetupTitle;
        }
    }

    final String body;
    switch (mode) {
      case SetupMode.displayMaps:
        body = l10n.navSetupDisplayMapsBody;
      case SetupMode.routing:
        body = l10n.navSetupRoutingBody;
      case SetupMode.both:
        body = l10n.navSetupNoRoutingBody;
    }

    final showDisplayMapsRow = mode == SetupMode.displayMaps || mode == SetupMode.both;
    final showRoutingRow = mode == SetupMode.routing || mode == SetupMode.both;

    return BlocListener<MapDownloadCubit, MapDownloadState>(
      listenWhen: (prev, curr) => prev.status != curr.status && curr.status == MapDownloadStatus.done,
      listener: (context, _) {
        context.read<NavigationAvailabilityCubit>().recheck();
      },
      child: ControlGestureDetector(
        stream: vehicleSync.stream,
        initialData: vehicleSync.state,
        requireInitialRelease: true,
        onRightTap: () => context.read<ScreenCubit>().closeNavigationSetup(),
        onLeftTap: canDownload ? triggerDownload : null,
        child: Container(
          color: bg,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: fg),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      if (showDisplayMapsRow) ...[
                        _StatusRow(
                          label: l10n.navSetupLocalDisplayMaps,
                          available: navState.localDisplayMapsAvailable,
                          isDark: isDark,
                        ),
                        if (showRoutingRow) const SizedBox(height: 8),
                      ],
                      if (showRoutingRow)
                        _StatusRow(
                          label: l10n.navSetupRoutingEngine,
                          available: navState.routingAvailable,
                          isDark: isDark,
                        ),
                      if (showDownloadSection) ...[
                        const SizedBox(height: 12),
                        Divider(color: divider),
                        const SizedBox(height: 4),
                        _DownloadSection(isDark: isDark, mode: mode),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        body,
                        style: TextStyle(fontSize: 14, color: fgDim, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      QrImageView(
                        data: _docsUrl,
                        version: QrVersions.auto,
                        size: 110,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.navSetupScanForInstructions,
                        style: TextStyle(fontSize: 12, color: fgDim),
                      ),
                    ],
                  ),
                ),
              ),

              // Controls bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: divider)),
                ),
                child: ControlHints(
                  leftAction: canDownload ? downloadLabel : null,
                  rightAction: l10n.aboutBackAction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadSection extends StatelessWidget {
  final bool isDark;
  final SetupMode mode;

  const _DownloadSection({required this.isDark, required this.mode});

  @override
  Widget build(BuildContext context) {
    final downloadState = context.watch<MapDownloadCubit>().state;
    final internet = context.watch<InternetSync>().state;
    final gps = context.watch<GpsSync>().state;
    final l10n = context.l10n;

    final fgDim = isDark ? Colors.white60 : Colors.black54;
    final isOnline = internet.status == ConnectionStatus.connected;
    final hasGps = gps.state == GpsState.fixEstablished && gps.latitude != 0;

    switch (downloadState.status) {
      case MapDownloadStatus.checkingUpdates:
        return Text(l10n.navSetupCheckingUpdates,
            style: TextStyle(fontSize: 13, color: fgDim));

      case MapDownloadStatus.locating:
        return Text(l10n.navSetupDownloadLocating,
            style: TextStyle(fontSize: 13, color: fgDim));

      case MapDownloadStatus.downloading:
        final percent = (downloadState.progress * 100).toInt();
        final downloadedMB = (downloadState.downloadedBytes / 1048576).toStringAsFixed(0);
        final totalMB = (downloadState.totalBytes / 1048576).toStringAsFixed(0);
        final hasSize = downloadState.totalBytes > 0;
        return Column(
          children: [
            LinearProgressIndicator(
              value: downloadState.progress,
              color: Colors.green.shade600,
              backgroundColor: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 6),
            Text(
              hasSize
                  ? l10n.navSetupDownloadProgressBytes(downloadedMB, totalMB)
                  : l10n.navSetupDownloadProgress(percent),
              style: TextStyle(fontSize: 13, color: fgDim),
            ),
          ],
        );

      case MapDownloadStatus.installing:
        return Text(l10n.navSetupDownloadInstalling,
            style: TextStyle(fontSize: 13, color: fgDim));

      case MapDownloadStatus.done:
        return Text(l10n.navSetupDownloadDone,
            style: TextStyle(fontSize: 13, color: Colors.green.shade600));

      case MapDownloadStatus.error:
        final errorMsg = downloadState.errorMessage == 'insufficient_space'
            ? l10n.navSetupInsufficientSpace
            : downloadState.errorMessage == 'unsupported'
                ? l10n.navSetupDownloadUnsupported
                : l10n.navSetupDownloadError;
        return Text(errorMsg,
            style: TextStyle(fontSize: 13, color: Colors.red.shade400));

      case MapDownloadStatus.idle:
        if (!isOnline) {
          return Text(l10n.navSetupDownloadNoInternet,
              style: TextStyle(fontSize: 13, color: fgDim));
        }
        if (!hasGps) {
          return Text(l10n.navSetupDownloadWaitingGps,
              style: TextStyle(fontSize: 13, color: fgDim));
        }
        final region = downloadState.regionName;
        if (region != null) {
          final sizeBytes = switch (mode) {
            SetupMode.displayMaps => downloadState.estimatedDisplayBytes,
            SetupMode.routing => downloadState.estimatedRoutingBytes,
            SetupMode.both => downloadState.estimatedDisplayBytes + downloadState.estimatedRoutingBytes,
          };
          final sizeMB = sizeBytes > 0 ? (sizeBytes / 1048576).toStringAsFixed(0) : null;
          final sizeText = sizeMB != null ? ' ($sizeMB MB)' : '';
          return Text('$region$sizeText',
              style: TextStyle(fontSize: 13, color: fgDim));
        }
        return const SizedBox.shrink();
    }
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool available;
  final bool isDark;

  const _StatusRow({
    required this.label,
    required this.available,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : Colors.black;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          available ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: available ? Colors.green : Colors.red.shade400,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 15, color: fg)),
      ],
    );
  }
}
