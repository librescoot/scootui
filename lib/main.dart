import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'cubits/all.dart';
import 'cubits/theme_cubit.dart';
import 'env_config.dart';
import 'repositories/all.dart';
import 'screens/main_screen.dart';
import 'utils/responsive_utils.dart';
import 'widgets/toast_listener_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  // Initialize environment configuration
  EnvConfig.initialize();

  await _setupPlatformConfigurations();

  runApp(const ScooterClusterApp());
}

Future<void> _setupPlatformConfigurations() async {
  if (kIsWeb) {
    // Web-specific setup
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Desktop-specific setup using window_manager
    await windowManager.ensureInitialized();

    // Determine screen configuration based on platform or environment
    final screenConfig = _getScreenConfig();

    WindowOptions windowOptions = WindowOptions(
      size: screenConfig.defaultSize,
      minimumSize: screenConfig.minSize,
      maximumSize: screenConfig.maxSize,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();

      // Set resizable based on configuration
      await windowManager.setResizable(screenConfig.allowResize);

      // For embedded systems or kiosk mode, set fullscreen
      if (!screenConfig.allowResize && screenConfig.defaultSize == const Size(480, 480)) {
        await windowManager.setFullScreen(true);
      }
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  } else {
    // Mobile/embedded setup
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
}

ScreenConfig _getScreenConfig() {
  // Check for environment variables or command line arguments
  // to determine if this is an embedded device
  final isEmbedded = const String.fromEnvironment('EMBEDDED_MODE') == 'true' ||
      Platform.environment['EMBEDDED_MODE'] == 'true';

  if (isEmbedded) {
    return ScreenConfig.embedded;
  }

  // For desktop development, use desktop configuration
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return ScreenConfig.desktop;
  }

  // Default to mobile configuration
  return ScreenConfig.mobile;
}

class ScooterClusterApp extends StatelessWidget {
  const ScooterClusterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: allRepositories,
      child: MultiBlocProvider(
        providers: allCubits,
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return ToastListenerWrapper(
              child: MaterialApp(
                title: 'Scooter Cluster',
                theme: state.lightTheme,
                darkTheme: state.darkTheme,
                themeMode: state.effectiveThemeMode,
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: MainScreen(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
