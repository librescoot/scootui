import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../repositories/tiles_repository.dart';

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

    return completer.future;
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
          _pendingRequests[requestId]?.completeError(Exception(message));
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
    final requestId = '${tile.z}/${tile.x}/${tile.y}';
    final completer = Completer<Uint8List>();
    _pendingRequests[requestId] = completer;

    _sendPort.send(_Request.getTile(requestId, tile));
    return completer.future;
  }

  @override
  TileProviderType get type => TileProviderType.vector;

  void dispose() {
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
  int? _maxZoom;

  receivePort.listen((message) async {
    if (message is _Request) {
      switch (message) {
        case _InitRequest(:final tilesRepository):
          final tiles = await tilesRepository.getMbTiles();
          switch (tiles) {
            case Success(:final mbTiles):
              _mbTiles = mbTiles;

              final meta = mbTiles.getMetadata();
              _maxZoom = meta.maxZoom?.toInt();
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
          final clampedZ = (_maxZoom != null && tile.z > _maxZoom!) ? _maxZoom! : tile.z;
          final zDiff = tile.z - clampedZ;
          final clampedX = tile.x >> zDiff;
          final clampedY = tile.y >> zDiff;
          final tmsY = ((1 << clampedZ) - 1) - clampedY;
          final tileData = _mbTiles!.getTile(x: clampedX, y: tmsY, z: clampedZ);
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
