import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../repositories/mdb_repository.dart';
import '../repositories/tiles_repository.dart';

class NavigationAvailabilityState {
  final bool mapsAvailable;
  final bool navigationAvailable;

  const NavigationAvailabilityState({
    this.mapsAvailable = false,
    this.navigationAvailable = false,
  });

  @override
  bool operator ==(Object other) =>
      other is NavigationAvailabilityState &&
      other.mapsAvailable == mapsAvailable &&
      other.navigationAvailable == navigationAvailable;

  @override
  int get hashCode => Object.hash(mapsAvailable, navigationAvailable);
}

class NavigationAvailabilityCubit extends Cubit<NavigationAvailabilityState> {
  final TilesRepository _tilesRepository;
  final MDBRepository _mdbRepository;
  Timer? _retryTimer;

  static const Duration _retryInterval = Duration(seconds: 30);

  NavigationAvailabilityCubit({
    required TilesRepository tilesRepository,
    required MDBRepository mdbRepository,
  })  : _tilesRepository = tilesRepository,
        _mdbRepository = mdbRepository,
        super(const NavigationAvailabilityState()) {
    _checkAndPublish();
  }

  static NavigationAvailabilityCubit create(BuildContext context) =>
      NavigationAvailabilityCubit(
        tilesRepository: context.read<TilesRepository>(),
        mdbRepository: RepositoryProvider.of<MDBRepository>(context),
      );

  static NavigationAvailabilityState watch(BuildContext context) =>
      context.watch<NavigationAvailabilityCubit>().state;

  Future<void> _checkAndPublish() async {
    final mapsAvailable = await _checkMapsAvailable();
    final navigationAvailable = mapsAvailable && await _checkValhallaAvailable();

    try {
      await _mdbRepository.set(
          AppConfig.redisSettingsCluster, 'maps-available', mapsAvailable ? 'true' : 'false');
      await _mdbRepository.set(
          AppConfig.redisSettingsCluster, 'navigation-available', navigationAvailable ? 'true' : 'false');
    } catch (_) {
      // Redis not yet available — will retry
    }

    final newState = NavigationAvailabilityState(
      mapsAvailable: mapsAvailable,
      navigationAvailable: navigationAvailable,
    );

    if (newState != state) emit(newState);

    // Keep retrying until both are available
    if (!navigationAvailable) {
      _retryTimer?.cancel();
      _retryTimer = Timer(_retryInterval, _checkAndPublish);
    }
  }

  Future<bool> _checkMapsAvailable() async {
    try {
      final tiles = await _tilesRepository.getMbTiles();
      return tiles is Success;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _checkValhallaAvailable() async {
    try {
      final uri = Uri.parse('${AppConfig.valhallaEndpoint}status');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _retryTimer?.cancel();
    return super.close();
  }
}
