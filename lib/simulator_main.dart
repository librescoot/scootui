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
import 'repositories/mdb_repository.dart';
import 'screens/simulator_screen.dart';
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

  // Initialize environment configuration
  EnvConfig.initialize();

  await _setupPlatformConfigurations();

  runApp(const SimulatorApp());
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

    // Use window_manager to set window size
    await windowManager.ensureInitialized();
    await windowManager.setSize(const Size(1280, 720));
    await windowManager.center();
  } else {
    // Mobile/embedded setup
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
}

class SimulatorApp extends StatelessWidget {
  const SimulatorApp({super.key});

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
                title: 'Cluster Simulator',
                theme: state.lightTheme,
                darkTheme: state.darkTheme,
                themeMode: state.themeMode,
                debugShowCheckedModeBanner: false,
                home: Builder(
                  builder: (context) => SimulatorScreen(
                    repository: context.read<MDBRepository>(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
