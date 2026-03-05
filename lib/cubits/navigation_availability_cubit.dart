import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../repositories/mdb_repository.dart';
import '../repositories/tiles_repository.dart';

class NavigationAvailabilityState {
  /// Whether local offline display map tiles are present (map.mbtiles).
  /// Independent of routing availability — online tiles work without this.
  final bool localDisplayMapsAvailable;

  /// Whether the Valhalla routing engine responds (local or remote endpoint).
  /// This is what's needed for turn-by-turn navigation.
  final bool routingAvailable;

  const NavigationAvailabilityState({
    this.localDisplayMapsAvailable = false,
    this.routingAvailable = false,
  });

  @override
  bool operator ==(Object other) =>
      other is NavigationAvailabilityState &&
      other.localDisplayMapsAvailable == localDisplayMapsAvailable &&
      other.routingAvailable == routingAvailable;

  @override
  int get hashCode => Object.hash(localDisplayMapsAvailable, routingAvailable);
}

class NavigationAvailabilityCubit extends Cubit<NavigationAvailabilityState> {
  final TilesRepository _tilesRepository;
  final MDBRepository _mdbRepository;

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

  Future<void> recheck() => _checkAndPublish();

  Future<void> _checkAndPublish() async {
    final localDisplayMapsAvailable = await _checkLocalDisplayMapsAvailable();
    final routingAvailable = await _checkValhallaAvailable();

    try {
      await _mdbRepository.set(
          AppConfig.redisSettingsCluster, 'maps-available', localDisplayMapsAvailable ? 'true' : 'false');
      await _mdbRepository.set(
          AppConfig.redisSettingsCluster, 'navigation-available', routingAvailable ? 'true' : 'false');
    } catch (_) {
      // Redis not yet available
    }

    emit(NavigationAvailabilityState(
      localDisplayMapsAvailable: localDisplayMapsAvailable,
      routingAvailable: routingAvailable,
    ));
  }

  Future<bool> _checkLocalDisplayMapsAvailable() async {
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
}
