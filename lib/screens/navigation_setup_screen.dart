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
  const NavigationSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapDownloadCubit(),
      child: const _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

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

    final anyMissing = !navState.localDisplayMapsAvailable || !navState.routingAvailable;
    final downloadState = context.watch<MapDownloadCubit>().state;
    final showDownloadSection = anyMissing || downloadState.updateAvailable || downloadState.hasPartialDownload;

    final String title;
    if (!navState.routingAvailable && !navState.localDisplayMapsAvailable) {
      title = l10n.navSetupTitleBothUnavailable;
    } else if (!navState.routingAvailable) {
      title = l10n.navSetupTitleRoutingUnavailable;
    } else if (!navState.localDisplayMapsAvailable) {
      title = l10n.navSetupTitleMapsUnavailable;
    } else {
      title = l10n.navSetupTitle;
    }

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
        child: Container(
          color: bg,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: fg),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _StatusRow(
                        label: l10n.navSetupLocalDisplayMaps,
                        available: navState.localDisplayMapsAvailable,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _StatusRow(
                        label: l10n.navSetupRoutingEngine,
                        available: navState.routingAvailable,
                        isDark: isDark,
                      ),
                      if (showDownloadSection) ...[
                        const SizedBox(height: 12),
                        Divider(color: divider),
                        const SizedBox(height: 4),
                        _DownloadSection(isDark: isDark, navState: navState),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        l10n.navSetupNoRoutingBody,
                        style: TextStyle(fontSize: 14, color: fgDim, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      QrImageView(
                        data: _docsUrl,
                        version: QrVersions.auto,
                        size: 130,
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
                  leftAction: null,
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
  final NavigationAvailabilityState navState;

  const _DownloadSection({required this.isDark, required this.navState});

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
        return Column(
          children: [
            Text(errorMsg,
                style: TextStyle(fontSize: 13, color: Colors.red.shade400)),
            const SizedBox(height: 4),
            _downloadButton(context, gps, l10n, downloadState),
          ],
        );

      case MapDownloadStatus.idle:
        if (!isOnline) {
          return Text(l10n.navSetupDownloadNoInternet,
              style: TextStyle(fontSize: 13, color: fgDim));
        }
        if (!hasGps) {
          return Text(l10n.navSetupDownloadWaitingGps,
              style: TextStyle(fontSize: 13, color: fgDim));
        }
        return _downloadButton(context, gps, l10n, downloadState);
    }
  }

  Widget _downloadButton(
      BuildContext context, GpsData gps, dynamic l10n, MapDownloadState downloadState) {
    final isUpdate = downloadState.updateAvailable;
    final isResume = downloadState.hasPartialDownload && !isUpdate;
    final label = isUpdate
        ? l10n.navSetupUpdateButton
        : isResume
            ? l10n.navSetupResumeButton
            : l10n.navSetupDownloadButton;
    final icon = isUpdate ? Icons.update_outlined : Icons.download_outlined;

    return TextButton.icon(
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      icon: Icon(icon, color: Colors.green.shade600, size: 18),
      label: Text(label,
          style: TextStyle(color: Colors.green.shade600, fontSize: 13)),
      onPressed: () => context.read<MapDownloadCubit>().startDownload(
            latitude: gps.latitude,
            longitude: gps.longitude,
            needsDisplayMaps: isUpdate || !navState.localDisplayMapsAvailable,
            needsRoutingMaps: isUpdate || !navState.routingAvailable,
          ),
    );
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
