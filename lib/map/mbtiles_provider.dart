import 'dart:async';
import 'dart:typed_data';

import 'package:mbtiles/mbtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../services/map_service.dart';

/// A [VectorTileProvider] that delegates tile fetching to the [MapService].
///
/// This provider acts as a thin wrapper, adapting the [MapService] to the
/// interface required by the `vector_map_tiles` package.
class AsyncMbTilesProvider implements VectorTileProvider {
  final MapService _mapService;
  final MbTilesMetadata _metadata;

  AsyncMbTilesProvider(this._mapService, this._metadata);

  @override
  int get maximumZoom => _metadata.maxZoom?.toInt() ?? 20;

  @override
  int get minimumZoom => _metadata.minZoom?.toInt() ?? 0;

  @override
  Future<Uint8List> provide(TileIdentity tile) {
    // The MapService handles the complexity of fetching the tile, including
    // potential queuing during updates.
    return _mapService.getTile(tile);
  }

  @override
  TileProviderType get type => TileProviderType.vector;

  /// Since this is a thin wrapper, there are no resources to dispose of here.
  /// The lifecycle of the underlying [MapService] is managed elsewhere.
  void dispose() {
    // No-op
  }
}
