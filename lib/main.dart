import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'cubits/all.dart';
import 'cubits/theme_cubit.dart';
import 'env_config.dart';
import 'repositories/address_repository.dart' as addr;
import 'repositories/all.dart';
import 'repositories/tiles_repository.dart' as tiles;
import 'screens/main_screen.dart';
import 'widgets/toast_listener_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress vector map tile cancellation exceptions
  FlutterError.onError = (FlutterErrorDetails details) {
    final exception = details.exception;
    final isCancelledException = exception.toString().contains('Cancelled') &&
        details.stack.toString().contains('vector_map_tiles');

    if (!isCancelledException) {
      FlutterError.presentError(details);
    }
  };

  // Also handle async errors from isolates and image loading
  PlatformDispatcher.instance.onError = (error, stack) {
    final isCancelledException = error.toString().contains('Cancelled') &&
        stack.toString().contains('vector_map_tiles');

    if (isCancelledException) {
      return true; // Suppress the error
    }

    // Let other errors through
    return false;
  };

  if (kDebugMode) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  // Initialize environment configuration
  EnvConfig.initialize();

  await _setupPlatformConfigurations();

  // Trigger background address database build if needed (don't await)
  _buildAddressDatabaseIfNeeded();

  runApp(const ScooterClusterApp());
}

void _buildAddressDatabaseIfNeeded() async {
  try {
    final addressRepository = addr.AddressRepository();
    final tilesRepository = tiles.TilesRepository();

    // Check if database exists and is valid
    final result = await addressRepository.loadDatabase();

    switch (result) {
      case addr.NotFound():
        // Database doesn't exist, build it
        print('[Startup] Address database not found, building in background...');
        await addressRepository.buildDatabase(tilesRepository);
        print('[Startup] Address database build complete');
        break;

      case addr.Success(:final database):
        // Check if map hash matches
        final currentHash = await tilesRepository.getMapHash();
        if (currentHash != null && currentHash != database.mapHash) {
          print('[Startup] Map hash mismatch, rebuilding address database...');
          await addressRepository.buildDatabase(tilesRepository);
          print('[Startup] Address database rebuild complete');
        }
        break;

      case addr.Error(:final message):
        print('[Startup] Error loading address database: $message');
        break;
    }
  } catch (e) {
    print('[Startup] Failed to build address database: $e');
  }
}

Future<void> _setupPlatformConfigurations() async {
  if (kIsWeb) {
    // Web-specific setup
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Desktop-specific setup
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Try to use window_manager for desktop environments
    // This will gracefully fail on embedded devices (DRM/GBM backend)
    try {
      await windowManager.ensureInitialized();
      await windowManager.setSize(const Size(480, 480));
      await windowManager.setResizable(false);
      await windowManager.center();
    } on MissingPluginException {
      // Running on embedded device or environment without window manager support
      // Continue without window manager functionality
    }
  } else {
    // Mobile/embedded setup
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
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
