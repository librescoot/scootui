import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/carplay_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../l10n/l10n.dart';
import '../env_config.dart';
import '../widgets/carplay/carplay_video_widget.dart';
import '../widgets/cluster/blinker_row.dart';
import '../widgets/cluster/cluster_bottom_bar.dart';
import '../widgets/status_bars/top_status_bar.dart';
import '../widgets/status_bars/unified_bottom_status_bar.dart';

class CarPlayScreen extends StatefulWidget {
  const CarPlayScreen({super.key});

  @override
  State<CarPlayScreen> createState() => _CarPlayScreenState();
}

class _CarPlayScreenState extends State<CarPlayScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-connect to CarPlay backend on screen init
    context.read<CarPlayCubit>().connect();
  }

  Widget _buildCarPlayContent(BuildContext context, CarPlayState state) {
    return switch (state) {
      CarPlayDisconnected() => _buildStatusMessage(
          context,
          context.l10n.carplayDisconnected,
          context.l10n.carplayConnectingSubtitle,
          icon: Icons.link_off,
        ),
      CarPlayConnecting() => _buildStatusMessage(
          context,
          context.l10n.carplayConnecting,
          context.l10n.carplayInitializingStream,
          showSpinner: true,
        ),
      CarPlayConnected() => const CarPlayVideoWidget(),
      CarPlayError(:final message) => _buildErrorMessage(context, message),
    };
  }

  Widget _buildStatusMessage(
    BuildContext context,
    String title,
    String subtitle, {
    IconData? icon,
    bool showSpinner = false,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSpinner)
            const CircularProgressIndicator()
          else if (icon != null)
            Icon(icon, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.carplayConnectionError,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CarPlayCubit>().retry();
              },
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.carplayRetryConnection),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme) = ThemeCubit.watch(context);

    return Container(
      width: EnvConfig.resolution.width,
      height: EnvConfig.resolution.height,
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Top status bar
          StatusBar(),

          // Main CarPlay area
          Expanded(
            child: Stack(
              children: [
                // CarPlay video or status messages
                BlocBuilder<CarPlayCubit, CarPlayState>(
                  builder: (context, state) {
                    return _buildCarPlayContent(context, state);
                  },
                ),

                // Overlay content (blinkers and indicators)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      // Blinker row
                      const BlinkerRow(),

                      // Free space
                      const Expanded(child: SizedBox()),

                      // Bottom row with telltales or power display
                      const ClusterBottomBar(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom status bar
          const UnifiedBottomStatusBar(),
        ],
      ),
    );
  }
}
