import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/all.dart';
import 'cubits/theme_cubit.dart';
import 'env_config.dart';
import 'repositories/all.dart';
import 'screens/main_screen.dart';
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
  // Embedded Linux setup with DRM/GBM backend
  // Set preferred orientations based on screen size
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide system UI for full-screen embedded display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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
