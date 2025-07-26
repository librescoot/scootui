import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../repositories/address_repository.dart';

part 'map_service.freezed.dart';

/// Exception thrown when the map data is not available or fails to load.
class MapUnavailableException implements Exception {
  final String message;
  MapUnavailableException(this.message);
  @override
  String toString() => 'MapUnavailableException: $message';
}

class MapService {
  late final Isolate _isolate;
  late final SendPort _sendPort;
  final _receivePort = ReceivePort();

  final _pendingTileRequests = <String, Completer<Uint8List>>{};
  final _pendingAddressRequests = <String, Completer<Address?>>{};
  final _pendingUpdateRequests = <String, Completer<void>>{};
  final _initCompleter = Completer<MbTilesMetadata>();
  int _nextRequestId = 0;

  MapService();

  /// Initializes the map service and starts the background isolate.
  /// This should be called once at startup.
  Future<void> init() async {
    _receivePort.listen(_handleResponse);
    final token = RootIsolateToken.instance;
    if (token == null) {
      throw Exception('RootIsolateToken is not available');
    }
    _isolate = await Isolate.spawn(
      _startRemoteIsolate,
      _IsolateInit(
        sendPort: _receivePort.sendPort,
        token: token,
      ),
    );
  }

  /// Returns the map metadata. Throws [MapUnavailableException] if initialization fails.
  Future<MbTilesMetadata> getMetadata() => _initCompleter.future;

  Future<Directory> getMapsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(appDir.path, 'maps'));
  }

  Future<void> updateMap(String newMapPath) {
    final requestId = (_nextRequestId++).toString();
    final completer = Completer<void>();
    _pendingUpdateRequests[requestId] = completer;
    _sendPort.send(Request.reloadMap(requestId, newMapPath));
    return completer.future;
  }

  Future<Uint8List> getTile(TileIdentity tile) {
    final requestId = '${tile.z}/${tile.x}/${tile.y}';
    final completer = Completer<Uint8List>();
    _pendingTileRequests[requestId] = completer;
    _sendPort.send(Request.getTile(requestId, tile));
    return completer.future;
  }

  Future<Address?> findAddress(String id) {
    final completer = Completer<Address?>();
    _pendingAddressRequests[id] = completer;
    _sendPort.send(Request.findAddress(id));
    return completer.future;
  }

  void _handleResponse(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _sendPort.send(const Request.init());
    } else if (message is Response) {
      switch (message) {
        case _InitResponse(:final metadata):
          _initCompleter.complete(metadata);
        case _ErrorResponse(:final message):
          _initCompleter.completeError(MapUnavailableException(message));
        case _TileResponse(:final requestId, :final tile):
          _pendingTileRequests.remove(requestId)?.complete(tile);
        case _TileErrorResponse(:final requestId, :final message):
          _pendingTileRequests
              .remove(requestId)
              ?.completeError(Exception(message));
        case _AddressResponse(:final requestId, :final address):
          _pendingAddressRequests.remove(requestId)?.complete(address);
        case _UpdateSuccessResponse(:final requestId):
          _pendingUpdateRequests.remove(requestId)?.complete();
        case _UpdateErrorResponse(:final requestId, :final message):
          _pendingUpdateRequests
              .remove(requestId)
              ?.completeError(MapUnavailableException(message));
      }
    }
  }

  void dispose() {
    _sendPort.send(const Request.dispose());
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
    for (final request in _pendingTileRequests.values) {
      request.completeError('Isolate disposed');
    }
    for (final request in _pendingAddressRequests.values) {
      request.completeError('Isolate disposed');
    }
    for (final request in _pendingUpdateRequests.values) {
      request.completeError('Isolate disposed');
    }
  }
}

// --- Isolate Code ---

void _startRemoteIsolate(_IsolateInit init) {
  BackgroundIsolateBinaryMessenger.ensureInitialized(init.token);
  final receivePort = ReceivePort();
  init.sendPort.send(receivePort.sendPort);
  final isolateHandler = _MapServiceIsolateHandler(init.sendPort);

  receivePort.listen((message) {
    isolateHandler.handle(message);
  });
}

class _MapServiceIsolateHandler {
  final SendPort _sendPort;
  MbTiles? _mbTiles;
  sqlite.Database? _db;

  _MapServiceIsolateHandler(this._sendPort);

  Future<String> _getMapFilename() async {
    final appDir = await getApplicationDocumentsDirectory();
    final mapsDir = Directory(p.join(appDir.path, 'maps'));
    if (!await mapsDir.exists()) {
      await mapsDir.create(recursive: true);
    }

    // Migrate old map file if it exists
    final oldMapFile = File(p.join(mapsDir.path, 'map.mbtiles'));
    if (await oldMapFile.exists()) {
      try {
        final timestamp = DateFormat('yyyyMMdd_HHmmss')
            .format(await oldMapFile.lastModified());
        final newPath = p.join(mapsDir.path, 'map_$timestamp.mbtiles');
        await oldMapFile.rename(newPath);
        print('Migrated existing map to $newPath');
      } catch (e) {
        print('Failed to migrate old map file: $e');
      }
    }

    final mapFiles = (await mapsDir.list().toList())
        .whereType<File>()
        .where((f) => p.basename(f.path).startsWith('map_'))
        .where((f) => p.basename(f.path).endsWith('.mbtiles'))
        .toList();

    if (mapFiles.isEmpty) {
      throw MapUnavailableException('No map files found in ${mapsDir.path}');
    }

    // Sort by timestamp (newest first)
    mapFiles.sort((a, b) => b.path.compareTo(a.path));

    return mapFiles.first.path;
  }

  Future<MbTiles> _getMbTiles(String mapPath) async {
    if (!File(mapPath).existsSync()) {
      throw MapUnavailableException('Map file not found at $mapPath');
    }
    return MbTiles(mbtilesPath: mapPath);
  }

  Future<void> _cleanupOldMaps(String currentMapPath) async {
    final mapsDir = File(currentMapPath).parent;
    final currentFileName = p.basename(currentMapPath);

    final oldMaps = (await mapsDir.list().toList())
        .whereType<File>()
        .where((f) =>
            p.basename(f.path).startsWith('map_') &&
            p.basename(f.path).endsWith('.mbtiles') &&
            p.basename(f.path) != currentFileName)
        .toList();

    for (final oldMap in oldMaps) {
      try {
        await oldMap.delete();
        print('Deleted old map: ${oldMap.path}');
      } catch (e) {
        print('Failed to delete old map ${oldMap.path}: $e');
      }
    }
  }

  Future<void> handle(dynamic message) async {
    if (message is! Request) return;

    switch (message) {
      case _InitRequest():
        try {
          final mapPath = await _getMapFilename();
          _mbTiles = await _getMbTiles(mapPath);
          _db = sqlite.sqlite3.open(mapPath, mode: sqlite.OpenMode.readOnly);
          _sendPort.send(Response.init(_mbTiles!.getMetadata()));

          // Cleanup old maps after successful load
          await _cleanupOldMaps(mapPath);
        } catch (e) {
          _sendPort.send(Response.error(e.toString()));
        }

      case _GetTileRequest(:final requestId, :final tile):
        if (_mbTiles == null) {
          _sendPort
              .send(Response.tileError(requestId, 'MBTiles not initialized'));
          return;
        }
        // The TMS Y coordinate needs to be flipped for mbtiles
        final tmsY = ((1 << tile.z) - 1) - tile.y;
        final tileData = _mbTiles!.getTile(x: tile.x, y: tmsY, z: tile.z);
        if (tileData != null) {
          _sendPort.send(Response.tile(requestId, tileData));
        } else {
          _sendPort.send(Response.tileError(requestId, 'Tile not found'));
        }

      case _FindAddressRequest(:final id):
        if (_db == null) {
          _sendPort.send(Response.address(id, null));
          return;
        }
        try {
          final result = _db!.select(
              "SELECT lat, lng, id, x, y FROM addresses WHERE id = ?",
              [id]).firstOrNull;

          if (result == null) {
            _sendPort.send(Response.address(id, null));
          } else {
            final lat = result['lat'] as double;
            final lng = result['lng'] as double;
            final address = Address(
              id: result['id'] as String,
              coordinates: LatLng(lat, lng),
              x: (result['x'] as int).toDouble(),
              y: (result['y'] as int).toDouble(),
            );
            _sendPort.send(Response.address(id, address));
          }
        } catch (e) {
          // In case of SQL error, etc.
          _sendPort.send(Response.address(id, null));
        }

      case _ReloadMapRequest(:final requestId, :final newMapPath):
        try {
          print('Unloading current databases');
          _mbTiles?.dispose();
          _mbTiles = null;
          _db?.dispose();
          _db = null;

          // Load new map directly
          _mbTiles = await _getMbTiles(newMapPath);
          _db = sqlite.sqlite3.open(newMapPath, mode: sqlite.OpenMode.readOnly);

          // Success: notify caller and clean up old maps
          _sendPort.send(Response.updateSuccess(requestId));
          await _cleanupOldMaps(newMapPath);
        } catch (e) {
          // Failure: Send error back
          // No need to rollback, the old map is still there. The new one will be cleaned up on next startup.
          _sendPort.send(Response.updateError(requestId, e.toString()));
        }

      case _DisposeRequest():
        _mbTiles?.dispose();
        _db?.dispose();
        Isolate.exit();
    }
  }
}

class _IsolateInit {
  final SendPort sendPort;
  final RootIsolateToken token;

  _IsolateInit({
    required this.sendPort,
    required this.token,
  });
}

@freezed
sealed class Request with _$Request {
  const factory Request.init() = _InitRequest;
  const factory Request.getTile(String requestId, TileIdentity tile) =
      _GetTileRequest;
  const factory Request.findAddress(String id) = _FindAddressRequest;
  const factory Request.reloadMap(String requestId, String newMapPath) =
      _ReloadMapRequest;
  const factory Request.dispose() = _DisposeRequest;
}

@freezed
sealed class Response with _$Response {
  const factory Response.init(MbTilesMetadata metadata) = _InitResponse;
  const factory Response.error(String message) = _ErrorResponse;
  const factory Response.tile(String requestId, Uint8List tile) = _TileResponse;
  const factory Response.tileError(String requestId, String message) =
      _TileErrorResponse;
  const factory Response.address(String requestId, Address? address) =
      _AddressResponse;
  const factory Response.updateSuccess(String requestId) =
      _UpdateSuccessResponse;
  const factory Response.updateError(String requestId, String message) =
      _UpdateErrorResponse;
}
