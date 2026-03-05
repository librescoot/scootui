import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../repositories/mdb_repository.dart';
import '../repositories/tiles_repository.dart';
import '../state/internet.dart';
import '../state/settings.dart';
import 'mdb_cubits.dart';

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
  late final StreamSubscription<InternetData> _internetSub;
  late final StreamSubscription<SettingsData> _settingsSub;

  bool _checking = false;
  ModemState _lastModemState = ModemState.off;
  String? _lastValhallaUrl;

  NavigationAvailabilityCubit({
    required TilesRepository tilesRepository,
    required MDBRepository mdbRepository,
    required InternetSync internetSync,
    required SettingsSync settingsSync,
  })  : _tilesRepository = tilesRepository,
        _mdbRepository = mdbRepository,
        super(const NavigationAvailabilityState()) {
    _checkAndPublish();
    _internetSub = internetSync.stream.listen(_onInternetChanged);
    _settingsSub = settingsSync.stream.listen(_onSettingsChanged);
  }

  void _onInternetChanged(InternetData data) {
    if (data.modemState != _lastModemState) {
      _lastModemState = data.modemState;
      _checkAndPublish();
    }
  }

  void _onSettingsChanged(SettingsData data) {
    if (data.valhallaUrl != _lastValhallaUrl) {
      _lastValhallaUrl = data.valhallaUrl;
      _checkAndPublish();
    }
  }

  @override
  Future<void> close() {
    _internetSub.cancel();
    _settingsSub.cancel();
    return super.close();
  }

  static NavigationAvailabilityCubit create(BuildContext context) =>
      NavigationAvailabilityCubit(
        tilesRepository: context.read<TilesRepository>(),
        mdbRepository: RepositoryProvider.of<MDBRepository>(context),
        internetSync: context.read<InternetSync>(),
        settingsSync: context.read<SettingsSync>(),
      );

  static NavigationAvailabilityState watch(BuildContext context) =>
      context.watch<NavigationAvailabilityCubit>().state;

  Future<void> recheck() => _checkAndPublish();

  Future<void> _checkAndPublish() async {
    if (_checking) return;
    _checking = true;
    try {
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
    } finally {
      _checking = false;
    }
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
