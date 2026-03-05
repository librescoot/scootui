import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MapDownloadStatus { idle, locating, downloading, installing, done, error }

class MapDownloadState {
  final MapDownloadStatus status;
  final double progress;
  final String? regionName;
  final String? errorMessage;

  const MapDownloadState({
    this.status = MapDownloadStatus.idle,
    this.progress = 0.0,
    this.regionName,
    this.errorMessage,
  });

  MapDownloadState copyWith({
    MapDownloadStatus? status,
    double? progress,
    String? regionName,
    String? errorMessage,
  }) =>
      MapDownloadState(
        status: status ?? this.status,
        progress: progress ?? this.progress,
        regionName: regionName ?? this.regionName,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class MapDownloadCubit extends Cubit<MapDownloadState> {
  final _dio = Dio();
  CancelToken? _cancelToken;

  MapDownloadCubit() : super(const MapDownloadState());

  Future<void> startDownload({
    required double latitude,
    required double longitude,
    required bool needsDisplayMaps,
    required bool needsRoutingMaps,
  }) async {
    if (state.status != MapDownloadStatus.idle && state.status != MapDownloadStatus.error) return;

    _cancelToken = CancelToken();

    try {
      emit(const MapDownloadState(status: MapDownloadStatus.locating));

      final slug = await _resolveSlug(latitude, longitude);
      if (slug == null) {
        emit(const MapDownloadState(status: MapDownloadStatus.error, errorMessage: 'unsupported'));
        return;
      }

      final regionName = _slugToDisplayName[slug] ?? slug;
      double displayProgress = 0;
      double routingProgress = 0;

      void updateProgress() {
        double total;
        if (needsDisplayMaps && needsRoutingMaps) {
          total = (displayProgress + routingProgress) / 2;
        } else if (needsDisplayMaps) {
          total = displayProgress;
        } else {
          total = routingProgress;
        }
        emit(MapDownloadState(
          status: MapDownloadStatus.downloading,
          progress: total,
          regionName: regionName,
        ));
      }

      if (needsDisplayMaps) {
        final url = 'https://github.com/librescoot/osm-tiles/releases/download/latest/tiles_$slug.mbtiles';
        await _downloadFile(
          url: url,
          dest: '/tmp/scootui_map.mbtiles',
          onProgress: (p) {
            displayProgress = p;
            updateProgress();
          },
        );
      }

      if (needsRoutingMaps) {
        final url = 'https://github.com/librescoot/valhalla-tiles/releases/download/latest/valhalla_tiles_$slug.tar';
        await _downloadFile(
          url: url,
          dest: '/tmp/scootui_valhalla_tiles.tar',
          onProgress: (p) {
            routingProgress = p;
            updateProgress();
          },
        );
      }

      emit(MapDownloadState(status: MapDownloadStatus.installing, regionName: regionName));

      if (needsDisplayMaps) {
        await Directory('/data/maps').create(recursive: true);
        await File('/tmp/scootui_map.mbtiles').rename('/data/maps/map.mbtiles');
      }

      if (needsRoutingMaps) {
        await Directory('/data/valhalla').create(recursive: true);
        final result = await Process.run('tar', ['-xf', '/tmp/scootui_valhalla_tiles.tar', '-C', '/data/valhalla/']);
        await File('/tmp/scootui_valhalla_tiles.tar').delete();
        if (result.exitCode != 0) {
          throw Exception('tar: ${result.stderr}');
        }
      }

      if (needsDisplayMaps) {
        await Process.run('systemctl', ['restart', 'librescoot-mbtileserver']);
      }
      if (needsRoutingMaps) {
        await Process.run('systemctl', ['restart', 'librescoot-valhalla']);
      }

      emit(MapDownloadState(status: MapDownloadStatus.done, regionName: regionName));
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        emit(const MapDownloadState(status: MapDownloadStatus.idle));
      } else {
        emit(MapDownloadState(
          status: MapDownloadStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void cancel() {
    _cancelToken?.cancel();
    _cancelToken = null;
  }

  void reset() {
    cancel();
    emit(const MapDownloadState(status: MapDownloadStatus.idle));
  }

  @override
  Future<void> close() {
    cancel();
    return super.close();
  }

  Future<String?> _resolveSlug(double latitude, double longitude) async {
    final response = await _dio.get(
      'https://nominatim.openstreetmap.org/reverse',
      queryParameters: {'lat': latitude, 'lon': longitude, 'format': 'json', 'zoom': 5},
      options: Options(headers: {'User-Agent': 'LibreScoot/1.0 (navigation setup)'}),
    );
    final state = response.data?['address']?['state'] as String?;
    if (state == null) return null;
    return _stateToSlug[state];
  }

  Future<void> _downloadFile({
    required String url,
    required String dest,
    required void Function(double) onProgress,
  }) async {
    await _dio.download(
      url,
      dest,
      cancelToken: _cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );
  }

  static const _stateToSlug = <String, String>{
    'Baden-Württemberg': 'baden-wuerttemberg',
    'Bayern': 'bayern',
    'Berlin': 'berlin_brandenburg',
    'Brandenburg': 'berlin_brandenburg',
    'Bremen': 'bremen',
    'Hamburg': 'hamburg',
    'Hessen': 'hessen',
    'Mecklenburg-Vorpommern': 'mecklenburg-vorpommern',
    'Niedersachsen': 'niedersachsen',
    'Nordrhein-Westfalen': 'nordrhein-westfalen',
    'Rheinland-Pfalz': 'rheinland-pfalz',
    'Saarland': 'saarland',
    'Sachsen': 'sachsen',
    'Sachsen-Anhalt': 'sachsen-anhalt',
    'Schleswig-Holstein': 'schleswig-holstein',
    'Thüringen': 'thueringen',
  };

  static const _slugToDisplayName = <String, String>{
    'berlin_brandenburg': 'Berlin/Brandenburg',
  };
}
