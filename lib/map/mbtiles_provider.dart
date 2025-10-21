import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../repositories/tiles_repository.dart';
import '../services/tile_preload_queue.dart';

part 'mbtiles_provider.freezed.dart';

@freezed
sealed class _Request with _$Request {
  const factory _Request.getTile(String requestId, TileIdentity tile) = _GetTileRequest;
  const factory _Request.dispose() = _DisposeRequest;
  const factory _Request.init(TilesRepository tilesRepository) = _InitRequest;
}

@freezed
sealed class _Response with _$Response {
  const factory _Response.tile(String requestId, Uint8List tile) = _TileResponse;
  const factory _Response.error(String requestId, String message) = _ErrorResponse;
  const factory _Response.init(InitResult result) = _InitResponse;
}

@freezed
sealed class InitResult with _$InitResult {
  const factory InitResult.success(MbTilesMetadata metadata) = InitSuccess;
  const factory InitResult.error(String message) = InitError;
}

class AsyncMbTilesProvider implements VectorTileProvider {
  late final ReceivePort _receivePort;
  late final SendPort _sendPort;
  final Map<String, Completer<Uint8List>> _pendingRequests = {};
  final TilesRepository tilesRepository;
  final TilePreloadQueue _preloadQueue = TilePreloadQueue();

  Completer<InitResult>? _initCompleter;
  MbTilesMetadata? _metadata;

  AsyncMbTilesProvider(this.tilesRepository) {
    _receivePort = ReceivePort();
  }

  Future<InitResult> init() async {
    _receivePort.listen(_handleResponse);

    final token = RootIsolateToken.instance;
    if (token == null) {
      throw Exception('RootIsolateToken is not available');
    }
    await Isolate.spawn(_startRemoteIsolate, (_receivePort.sendPort, token));

    final completer = Completer<InitResult>();
    _initCompleter = completer;

    final result = await completer.future;

    // Initialize the preload queue's fetch callback after successful init
    if (result is InitSuccess) {
      _preloadQueue.setFetchCallback(_fetchTileFromIsolate);
    }

    return result;
  }

  void _handleResponse(dynamic message) {
    if (message is _Response) {
      switch (message) {
        case _InitResponse(:final result):
          _initCompleter?.complete(result);
          _initCompleter = null;
          if (result is InitSuccess) {
            _metadata = result.metadata;
          }
        case _TileResponse(:final requestId, :final tile):
          _pendingRequests[requestId]?.complete(tile);
          _pendingRequests.remove(requestId);
        case _ErrorResponse(:final requestId, :final message):
          _pendingRequests[requestId]?.completeError(message);
          _pendingRequests.remove(requestId);
      }
    } else if (message is SendPort) {
      _sendPort = message;
      _sendPort.send(_Request.init(tilesRepository));
    }
  }

  @override
  int get maximumZoom => _metadata?.maxZoom?.toInt() ?? 20;

  @override
  int get minimumZoom => _metadata?.minZoom?.toInt() ?? 0;

  @override
  Future<Uint8List> provide(TileIdentity tile) {
    // Urgent request from visible map - push to front of queue
    _preloadQueue.pushFront(tile);
    return _fetchTileFromIsolate(tile);
  }

  /// Internal method to fetch a tile from the isolate
  Future<Uint8List> _fetchTileFromIsolate(TileIdentity tile) {
    final requestId = '${tile.z}/${tile.x}/${tile.y}';
    final completer = Completer<Uint8List>();
    _pendingRequests[requestId] = completer;

    _sendPort.send(_Request.getTile(requestId, tile));
    return completer.future;
  }

  /// Check if a tile is within the bounds of the mbtiles file
  bool _isTileInBounds(TileIdentity tile) {
    final bounds = _metadata?.bounds;
    if (bounds == null) {
      print('AsyncMbTilesProvider: No bounds metadata available, allowing all tiles');
      return true; // If no bounds, assume all tiles are valid
    }

    // Convert tile coordinates to lat/lng center point for simple check
    final n = 1 << tile.z;
    final lon = ((tile.x + 0.5) / n) * 360.0 - 180.0;

    // Use sinh approximation for Web Mercator: sinh(x) ≈ (e^x - e^-x) / 2
    final y = tile.y + 0.5;
    final latRad = math.atan(_sinh(math.pi * (1 - 2 * y / n)));
    final lat = latRad * 180.0 / math.pi;

    // Check if tile center is within map bounds (with small margin for edge tiles)
    final margin = 0.1; // degrees
    final inBounds = lon >= (bounds.left - margin) &&
                     lon <= (bounds.right + margin) &&
                     lat >= (bounds.bottom - margin) &&
                     lat <= (bounds.top + margin);

    return inBounds;
  }

  /// Hyperbolic sine approximation
  double _sinh(double x) {
    return (math.exp(x) - math.exp(-x)) / 2;
  }

  /// Preload tiles along a route at the specified zoom level
  /// Automatically clamps zoom to available range and filters by bounds
  void preloadTilesAtZoom(List<TileIdentity> tiles, int requestedZoom) {
    if (tiles.isEmpty) return;

    final bounds = _metadata?.bounds;
    final minZoom = _metadata?.minZoom?.toInt() ?? 0;
    final maxZoom = _metadata?.maxZoom?.toInt() ?? 20;

    // Clamp requested zoom to available range
    final actualZoom = requestedZoom.clamp(minZoom, maxZoom);

    print('AsyncMbTilesProvider: Map zoom range: $minZoom-$maxZoom');
    print('AsyncMbTilesProvider: Requested zoom $requestedZoom, using zoom $actualZoom');

    // If zoom was clamped, we need to recalculate tile coordinates
    if (actualZoom != tiles.first.z) {
      print('AsyncMbTilesProvider: Zoom adjusted - tiles need to be recalculated at correct zoom level');
      return; // Caller needs to recalculate with correct zoom
    }

    // Filter tiles to only those within bounds
    final validTiles = tiles.where(_isTileInBounds).toList();

    final filteredCount = tiles.length - validTiles.length;
    if (filteredCount > 0) {
      print('AsyncMbTilesProvider: Filtered out $filteredCount/${tiles.length} tiles outside map bounds');
    }

    if (validTiles.isEmpty) {
      print('AsyncMbTilesProvider: WARNING - No valid tiles to preload! Route may be outside map coverage.');
      return;
    }

    print('AsyncMbTilesProvider: Preloading ${validTiles.length} tiles at zoom $actualZoom');
    _preloadQueue.pushBackBatch(validTiles);
  }

  /// Preload tiles along a route (pushes to back of queue)
  /// Deprecated - use preloadTilesAtZoom instead
  void preloadTiles(List<TileIdentity> tiles) {
    if (tiles.isEmpty) return;
    preloadTilesAtZoom(tiles, tiles.first.z);
  }

  /// Clear preload queue (useful when route changes)
  void clearPreload() {
    _preloadQueue.clearPreload();
  }

  @override
  TileProviderType get type => TileProviderType.vector;

  void dispose() {
    _preloadQueue.dispose();
    _sendPort.send(const _Request.dispose());
    _receivePort.close();
  }
}

void _startRemoteIsolate((SendPort, RootIsolateToken) init) {
  final receivePort = ReceivePort();
  final (initPort, token) = init;
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  initPort.send(receivePort.sendPort);

  MbTiles? _mbTiles;

  receivePort.listen((message) async {
    if (message is _Request) {
      switch (message) {
        case _InitRequest(:final tilesRepository):
          final tiles = await tilesRepository.getMbTiles();
          switch (tiles) {
            case Success(:final mbTiles):
              _mbTiles = mbTiles;

              final meta = mbTiles.getMetadata();
              initPort.send(_Response.init(InitResult.success(meta)));
            case NotFound():
              initPort.send(_Response.init(InitResult.error('Map file not found')));
            case Error(:final message):
              initPort.send(_Response.init(InitResult.error(message)));
          }
        case _GetTileRequest(:final requestId, :final tile):
          if (_mbTiles == null) {
            initPort.send(_Response.error(requestId, 'MBTiles not initialized'));
            return;
          }
          final tmsY = ((1 << tile.z) - 1) - tile.y;
          final tileData = _mbTiles!.getTile(x: tile.x, y: tmsY, z: tile.z);
          if (tileData == null) {
            initPort.send(_Response.error(requestId, 'Tile not found'));
            return;
          }
          initPort.send(_Response.tile(requestId, tileData));
        case _DisposeRequest():
          _mbTiles?.dispose();
          receivePort.close();
          Isolate.exit();
      }
    }
  });
}
