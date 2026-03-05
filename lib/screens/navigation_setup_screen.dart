import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../cubits/mdb_cubits.dart';
import '../cubits/navigation_availability_cubit.dart';
import '../cubits/screen_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../l10n/l10n.dart';
import '../widgets/general/control_gestures_detector.dart';
import '../widgets/general/control_hints.dart';

const _docsUrl = 'https://librescoot.org/docs/navigation.html';

class NavigationSetupScreen extends StatelessWidget {
  const NavigationSetupScreen({super.key});

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

    return ControlGestureDetector(
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
                    const SizedBox(height: 16),
                    Text(
                      l10n.navSetupNoRoutingBody,
                      style: TextStyle(fontSize: 14, color: fgDim, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    QrImageView(
                      data: _docsUrl,
                      version: QrVersions.auto,
                      size: 140,
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
