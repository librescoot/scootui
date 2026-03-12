import 'dart:developer' as developer;
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../models/map_metadata.dart';

enum MapDownloadStatus {
  idle,
  checkingUpdates,
  locating,
  downloading,
  installing,
  done,
  error,
}

class MapDownloadState {
  final MapDownloadStatus status;
  final double progress;
  final String? regionName;
  final String? errorMessage;
  final bool updateAvailable;
  final MapMetadata? installedMeta;
  final int downloadedBytes;
  final int totalBytes;
  final bool hasPartialDownload;

  const MapDownloadState({
    this.status = MapDownloadStatus.idle,
    this.progress = 0.0,
    this.regionName,
    this.errorMessage,
    this.updateAvailable = false,
    this.installedMeta,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.hasPartialDownload = false,
  });

  MapDownloadState copyWith({
    MapDownloadStatus? status,
    double? progress,
    String? regionName,
    String? errorMessage,
    bool? updateAvailable,
    MapMetadata? installedMeta,
    int? downloadedBytes,
    int? totalBytes,
    bool? hasPartialDownload,
  }) =>
      MapDownloadState(
        status: status ?? this.status,
        progress: progress ?? this.progress,
        regionName: regionName ?? this.regionName,
        errorMessage: errorMessage ?? this.errorMessage,
        updateAvailable: updateAvailable ?? this.updateAvailable,
        installedMeta: installedMeta ?? this.installedMeta,
        downloadedBytes: downloadedBytes ?? this.downloadedBytes,
        totalBytes: totalBytes ?? this.totalBytes,
        hasPartialDownload: hasPartialDownload ?? this.hasPartialDownload,
      );
}

class MapDownloadCubit extends Cubit<MapDownloadState> {
  final _dio = Dio();
  CancelToken? _cancelToken;

  MapDownloadCubit() : super(const MapDownloadState()) {
    _init();
  }

  Future<void> _init() async {
    final meta = await MapMetadata.load();
    if (meta != null) {
      emit(state.copyWith(installedMeta: meta, regionName: _displayName(meta.region)));
      checkForUpdates();
    }
    await _checkPartialDownload();
  }

  Future<void> _checkPartialDownload() async {
    try {
      final downloadDir = await _downloadDir();
      final regionFile = File('${downloadDir.path}/region');
      if (await regionFile.exists()) {
        final region = await regionFile.readAsString();
        final hasPartial = await _hasPartialFiles(downloadDir);
        if (hasPartial) {
          emit(state.copyWith(
            hasPartialDownload: true,
            regionName: _displayName(region.trim()),
          ));
        }
      }
    } catch (_) {}
  }

  Future<bool> _hasPartialFiles(Directory downloadDir) async {
    if (!await downloadDir.exists()) return false;
    return await downloadDir
        .list()
        .any((f) => f.path.endsWith('.part'));
  }

  Future<void> checkForUpdates() async {
    final meta = state.installedMeta ?? await MapMetadata.load();
    if (meta == null) return;

    emit(state.copyWith(status: MapDownloadStatus.checkingUpdates));

    try {
      bool updateAvailable = false;

      if (meta.displayTiles != null) {
        final release = await _fetchReleaseInfo('librescoot/osm-tiles');
        final asset = _findAsset(release, 'tiles_${meta.region}.mbtiles');
        if (asset != null) {
          final remoteDigest = asset['digest'] as String?;
          if (remoteDigest != null && remoteDigest != meta.displayTiles!.digest) {
            updateAvailable = true;
          }
        }
      }

      if (!updateAvailable && meta.valhallaTiles != null) {
        final release = await _fetchReleaseInfo('librescoot/valhalla-tiles');
        final asset = _findAsset(release, 'valhalla_tiles_${meta.region}.tar');
        if (asset != null) {
          final remoteDigest = asset['digest'] as String?;
          if (remoteDigest != null && remoteDigest != meta.valhallaTiles!.digest) {
            updateAvailable = true;
          }
        }
      }

      if (!isClosed) {
        emit(state.copyWith(
          status: MapDownloadStatus.idle,
          updateAvailable: updateAvailable,
        ));
      }
    } catch (e) {
      developer.log('Update check failed: $e', name: 'MapDownload');
      if (!isClosed) {
        emit(state.copyWith(status: MapDownloadStatus.idle));
      }
    }
  }

  Future<void> startDownload({
    required double latitude,
    required double longitude,
    required bool needsDisplayMaps,
    required bool needsRoutingMaps,
  }) async {
    if (state.status != MapDownloadStatus.idle &&
        state.status != MapDownloadStatus.error) {
      return;
    }

    _cancelToken = CancelToken();

    try {
      emit(state.copyWith(status: MapDownloadStatus.locating));

      final slug = await _resolveSlug(latitude, longitude);
      if (slug == null) {
        emit(state.copyWith(
          status: MapDownloadStatus.error,
          errorMessage: 'unsupported',
        ));
        return;
      }

      final regionName = _displayName(slug);
      final downloadDir = await _downloadDir();
      await downloadDir.create(recursive: true);

      // If region changed from a partial download, clean up old files
      await _cleanPartialIfRegionChanged(downloadDir, slug);
      await File('${downloadDir.path}/region').writeAsString(slug);

      // Fetch release metadata (used for disk space check, integrity, and metadata)
      final appDir = await getApplicationDocumentsDirectory();
      Map<String, dynamic>? displayRelease;
      Map<String, dynamic>? valhallaRelease;
      Map<String, dynamic>? displayAsset;
      Map<String, dynamic>? valhallaAsset;

      if (needsDisplayMaps) {
        displayRelease = await _fetchReleaseInfo('librescoot/osm-tiles');
        displayAsset = _findAsset(displayRelease, 'tiles_$slug.mbtiles');
      }
      if (needsRoutingMaps) {
        valhallaRelease = await _fetchReleaseInfo('librescoot/valhalla-tiles');
        valhallaAsset = _findAsset(valhallaRelease, 'valhalla_tiles_$slug.tar');
      }

      // Check disk space
      final spaceCheck = await Process.run('df', ['-B1', '--output=avail', appDir.path]);
      if (spaceCheck.exitCode == 0) {
        final lines = (spaceCheck.stdout as String).trim().split('\n');
        if (lines.length >= 2) {
          final available = int.tryParse(lines.last.trim()) ?? 0;
          final neededBytes =
              ((displayAsset?['size'] as int?) ?? 0) +
              ((valhallaAsset?['size'] as int?) ?? 0);
          if (neededBytes > 0 && available < neededBytes * 1.1) {
            emit(state.copyWith(
              status: MapDownloadStatus.error,
              errorMessage: 'insufficient_space',
              regionName: regionName,
            ));
            return;
          }
        }
      }

      // Calculate total download size for byte-weighted progress
      final displaySize = (displayAsset?['size'] as int?) ?? 0;
      final valhallaSize = (valhallaAsset?['size'] as int?) ?? 0;
      final totalSize = (needsDisplayMaps ? displaySize : 0) +
          (needsRoutingMaps ? valhallaSize : 0);

      int displayReceived = 0;
      int valhallaReceived = 0;

      void updateProgress() {
        final received = displayReceived + valhallaReceived;
        if (!isClosed) {
          emit(state.copyWith(
            status: MapDownloadStatus.downloading,
            progress: totalSize > 0 ? received / totalSize : 0,
            regionName: regionName,
            downloadedBytes: received,
            totalBytes: totalSize,
          ));
        }
      }

      // Download display tiles
      if (needsDisplayMaps) {
        final url =
            'https://github.com/librescoot/osm-tiles/releases/download/latest/tiles_$slug.mbtiles';
        final partPath = '${downloadDir.path}/tiles_$slug.mbtiles.part';
        final finalPath = '${appDir.path}/maps/map.mbtiles';

        await _downloadFileResumable(
          url: url,
          partialPath: partPath,
          onProgress: (received, total) {
            displayReceived = received;
            updateProgress();
          },
        );

        // Verify integrity
        final expectedDigest = displayAsset?['digest'] as String?;
        if (expectedDigest != null) {
          await _verifyDigest(partPath, expectedDigest);
        }

        // Atomic install
        await Directory('${appDir.path}/maps').create(recursive: true);
        await File(partPath).rename(finalPath);
      }

      // Download valhalla tiles
      if (needsRoutingMaps) {
        final url =
            'https://github.com/librescoot/valhalla-tiles/releases/download/latest/valhalla_tiles_$slug.tar';
        final partPath = '${downloadDir.path}/valhalla_tiles_$slug.tar.part';
        final finalPath = '${appDir.path}/valhalla/tiles.tar';

        await _downloadFileResumable(
          url: url,
          partialPath: partPath,
          onProgress: (received, total) {
            valhallaReceived = received;
            updateProgress();
          },
        );

        // Verify integrity
        final expectedDigest = valhallaAsset?['digest'] as String?;
        if (expectedDigest != null) {
          await _verifyDigest(partPath, expectedDigest);
        }

        // Atomic install
        await Directory('${appDir.path}/valhalla').create(recursive: true);
        await File(partPath).rename(finalPath);
      }

      // Restart services
      if (!isClosed) {
        emit(state.copyWith(
          status: MapDownloadStatus.installing,
          regionName: regionName,
        ));
      }

      if (needsRoutingMaps) {
        await Process.run('systemctl', ['restart', 'valhalla']);
      }

      // Save metadata
      final existingMeta = await MapMetadata.load();
      final meta = MapMetadata(
        region: slug,
        displayTiles: needsDisplayMaps
            ? MapTileInfo(
                digest: (displayAsset?['digest'] as String?) ?? '',
                publishedAt: (displayRelease?['published_at'] as String?) ?? '',
                size: displaySize,
              )
            : existingMeta?.displayTiles,
        valhallaTiles: needsRoutingMaps
            ? MapTileInfo(
                digest: (valhallaAsset?['digest'] as String?) ?? '',
                publishedAt: (valhallaRelease?['published_at'] as String?) ?? '',
                size: valhallaSize,
              )
            : existingMeta?.valhallaTiles,
      );
      await meta.save();

      // Clean up download dir
      await _cleanDownloadDir(downloadDir);

      if (!isClosed) {
        emit(MapDownloadState(
          status: MapDownloadStatus.done,
          regionName: regionName,
          installedMeta: meta,
          updateAvailable: false,
        ));
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        if (!isClosed) {
          emit(state.copyWith(
            status: MapDownloadStatus.idle,
            hasPartialDownload: true,
          ));
        }
      } else {
        developer.log('Download failed: $e', name: 'MapDownload');
        if (!isClosed) {
          emit(state.copyWith(
            status: MapDownloadStatus.error,
            errorMessage: e.toString(),
          ));
        }
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

  // --- Private helpers ---

  Future<Directory> _downloadDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/maps/.download');
  }

  Future<void> _cleanPartialIfRegionChanged(
      Directory downloadDir, String newSlug) async {
    final regionFile = File('${downloadDir.path}/region');
    if (await regionFile.exists()) {
      final oldSlug = (await regionFile.readAsString()).trim();
      if (oldSlug != newSlug) {
        developer.log('Region changed from $oldSlug to $newSlug, cleaning partial files',
            name: 'MapDownload');
        await _cleanDownloadDir(downloadDir);
        await downloadDir.create(recursive: true);
      }
    }
  }

  Future<void> _cleanDownloadDir(Directory dir) async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<void> _downloadFileResumable({
    required String url,
    required String partialPath,
    required void Function(int received, int total) onProgress,
  }) async {
    final partialFile = File(partialPath);
    int existingBytes = 0;

    if (await partialFile.exists()) {
      existingBytes = await partialFile.length();
      developer.log('Resuming download from $existingBytes bytes: $url',
          name: 'MapDownload');
    }

    final response = await _dio.get<ResponseBody>(
      url,
      options: Options(
        responseType: ResponseType.stream,
        followRedirects: true,
        headers: existingBytes > 0 ? {'Range': 'bytes=$existingBytes-'} : null,
      ),
      cancelToken: _cancelToken,
    );

    final isResume = response.statusCode == 206;
    final contentLength =
        int.tryParse(response.headers.value('content-length') ?? '') ?? 0;
    final totalBytes = isResume ? existingBytes + contentLength : contentLength;

    // If server doesn't support range (returned 200 instead of 206), start over
    if (existingBytes > 0 && !isResume) {
      existingBytes = 0;
      developer.log('Server does not support range requests, restarting download',
          name: 'MapDownload');
    }

    final sink = partialFile.openWrite(
        mode: isResume ? FileMode.append : FileMode.write);
    int received = existingBytes;

    try {
      await for (final chunk in response.data!.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress(received, totalBytes);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  }

  Future<void> _verifyDigest(String filePath, String expectedDigest) async {
    // expectedDigest format: "sha256:abcdef..."
    if (!expectedDigest.startsWith('sha256:')) return;
    final expectedHash = expectedDigest.substring(7);

    developer.log('Verifying SHA256 of $filePath', name: 'MapDownload');
    final file = File(filePath);
    final digest = await file
        .openRead()
        .transform(sha256)
        .map((d) => d.toString())
        .first;

    if (digest != expectedHash) {
      developer.log(
          'SHA256 mismatch: expected $expectedHash, got $digest',
          name: 'MapDownload');
      await file.delete();
      throw Exception('Download integrity check failed');
    }
    developer.log('SHA256 verified OK', name: 'MapDownload');
  }

  Future<Map<String, dynamic>> _fetchReleaseInfo(String repo) async {
    final response = await _dio.get(
      'https://api.github.com/repos/$repo/releases/tags/latest',
      options: Options(headers: {'User-Agent': 'LibreScoot/1.0'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Map<String, dynamic>? _findAsset(
      Map<String, dynamic> release, String filename) {
    final assets = release['assets'] as List<dynamic>?;
    if (assets == null) return null;
    for (final asset in assets) {
      if ((asset as Map<String, dynamic>)['name'] == filename) {
        return asset;
      }
    }
    return null;
  }

  Future<String?> _resolveSlug(double latitude, double longitude) async {
    final response = await _dio.get(
      'https://nominatim.openstreetmap.org/reverse',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'format': 'json',
        'zoom': 5,
      },
      options: Options(
          headers: {'User-Agent': 'LibreScoot/1.0 (navigation setup)'}),
      cancelToken: _cancelToken,
    );
    final state = response.data?['address']?['state'] as String?;
    if (state == null) return null;
    return _stateToSlug[state];
  }

  static String _displayName(String slug) =>
      _slugToDisplayName[slug] ?? slug.replaceAll('_', '/').replaceAll('-', ' ');

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
