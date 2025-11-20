import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

import '../globals/mdb_type.dart';
import '../services/auto_theme_service.dart';
import '../services/settings_service.dart';
import 'address_repository.dart';
import 'mdb_repository.dart';
import 'redis_mdb_repository.dart';
import 'tiles_repository.dart';

// Initialize the MDB repository first, then settings service which depends on it
final List<SingleChildWidget> allRepositories = [
  RepositoryProvider<MDBRepository>(
      // Explicitly provide MDBRepository
      // use in-memory mdb repository for web
      create: kIsWeb
          ? (context) {
              isStockUnuMdb.value = true; // Assume stock UNU for web
              return InMemoryMDBRepository.create(context);
            }
          : (context) {
              final repo = RedisMDBRepository.create(context);
              // Check MDB type once on startup
              repo.get('system', 'mdb-version').then((version) {
                isStockUnuMdb.value = isStockMdbVersion(version);
              }).catchError((_) {
                isStockUnuMdb.value = false;
              });
              return repo;
            }),
  RepositoryProvider(
    create: (context) => SettingsService(context.read<MDBRepository>())..initialize(),
  ),
  RepositoryProvider(
    create: (context) => AutoThemeService(context.read<MDBRepository>()),
  ),
  RepositoryProvider(create: AddressRepository.create),
  RepositoryProvider(create: TilesRepository.create),
];
