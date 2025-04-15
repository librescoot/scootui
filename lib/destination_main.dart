import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/all.dart';
import 'cubits/theme_cubit.dart';
import 'repositories/mdb_repository.dart';
import 'repositories/redis_mdb_repository.dart';
import 'screens/destination_screen.dart';
import 'theme_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  _setupPlatformConfigurations();

  runApp(const DestinationApp());
}

void _setupPlatformConfigurations() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    const windowSize = Size(800.0, 600.0);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChannels.platform.invokeMethod('Window.setSize', {
        'width': windowSize.width,
        'height': windowSize.height,
      });
      SystemChannels.platform.invokeMethod('Window.center');
    });
  }
}

class DestinationApp extends StatelessWidget {
  const DestinationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      // use InMemoryMDBRepository for web and RedisMDBRepository for other platforms
      create: kIsWeb ? InMemoryMDBRepository.create : RedisMDBRepository.create,
      child: MultiBlocProvider(
        providers: allCubits,
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'Destination Selector',
              theme: state.lightTheme,
              darkTheme: state.darkTheme,
              themeMode: state.themeMode,
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: DestinationScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
