import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

import '../services/settings_service.dart';
import '../services/auto_theme_service.dart';
import 'address_repository.dart';
import 'mdb_repository.dart';
import 'redis_mdb_repository.dart';
import 'tiles_repository.dart';

// Initialize the MDB repository first, then settings service which depends on it
final List<SingleChildWidget> allRepositories = [
  RepositoryProvider<MDBRepository>(
      // Explicitly provide MDBRepository
      // use in-memory mdb repository for web
      create: kIsWeb ? InMemoryMDBRepository.create : RedisMDBRepository.create),
  RepositoryProvider(
    create: (context) => SettingsService(context.read<MDBRepository>())..initialize(),
  ),
  RepositoryProvider(
    create: (context) => AutoThemeService(context.read<MDBRepository>()),
  ),
  RepositoryProvider(create: AddressRepository.create),
  RepositoryProvider(create: TilesRepository.create),
];
