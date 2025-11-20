import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_tile/vector_tile.dart';

import 'tiles_repository.dart' as tiles;

part 'address_repository.freezed.dart';
part 'address_repository.g.dart';

@freezed
abstract class Address with _$Address {
  const factory Address({
    required String id,
    required LatLng coordinates,
    required double x,
    required double y,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}

class AddressDatabase {
  final String mapHash;
  final List<LatLng> addresses;
  final int version;

  const AddressDatabase({
    required this.mapHash,
    required this.addresses,
    this.version = _currentDatabaseVersion,
  });

  static int _fromBase32(String code) {
    const chars = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
    var result = 0;
    for (var i = 0; i < code.length; i++) {
      result = result * 32 + chars.indexOf(code[i]);
    }
    return result;
  }

  factory AddressDatabase.fromJson(Map<String, dynamic> json) {
    // Detect format by checking if 'version' field exists
    final hasVersionField = json.containsKey('version');
    final addressesJson = json['addresses'];

    List<LatLng> addresses;

    if (!hasVersionField && addressesJson is Map) {
      // Old format v1: map with base32 keys {"0": {...}, "A": {...}, "GA1F": ...}
      final addressMap = addressesJson as Map<String, dynamic>;

      // Find max ID by decoding base32 keys
      final maxId = addressMap.keys.map((k) => _fromBase32(k)).reduce((a, b) => a > b ? a : b);
      final addressList = List<LatLng?>.filled(maxId + 1, null);

      // Convert map to list
      for (final entry in addressMap.entries) {
        final id = _fromBase32(entry.key);
        final addrObj = entry.value as Map<String, dynamic>;
        final coordsObj = addrObj['coordinates'] as Map<String, dynamic>;
        final coords = coordsObj['coordinates'] as List<dynamic>;
        // Old format had coordinates in wrong order: [lon, lat] instead of [lat, lon]
        // Swap them during migration
        addressList[id] = LatLng(coords[1] as double, coords[0] as double);
      }

      // Filter out nulls (shouldn't be any, but just in case)
      addresses = addressList.whereType<LatLng>().toList();
    } else if (addressesJson is List) {
      // New format v2: array of [lat, lon]
      addresses = (addressesJson as List<dynamic>).map((coords) {
        final c = coords as List<dynamic>;
        return LatLng(c[0] as double, c[1] as double);
      }).toList();
    } else {
      throw Exception('Unknown address database format');
    }

    return AddressDatabase(
      mapHash: json['mapHash'] as String,
      addresses: addresses,
      version: _currentDatabaseVersion,
    );
  }

  Map<String, dynamic> toJson() {
    final addressesJson = addresses.map((addr) => [addr.latitude, addr.longitude]).toList();

    return {
      'version': version,
      'mapHash': mapHash,
      'addresses': addressesJson,
    };
  }
}

@freezed
sealed class Addresses with _$Addresses {
  const factory Addresses.success(AddressDatabase database) = Success;
  const factory Addresses.notFound() = NotFound;
  const factory Addresses.error(String message) = Error;
}

const _addressDatabaseFilename = 'address_database.json';
const _currentDatabaseVersion = 2;

class AddressRepository {
  static AddressRepository create(BuildContext context) => AddressRepository();

  Future<Addresses> loadDatabase() async {
    final token = RootIsolateToken.instance;

    developer.log('Loading address database from disk', name: 'AddressRepository');

    return await Isolate.run(() async {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token!);

      final file = await _getFile();
      if (file == null) {
        developer.log('Failed to get database file path', name: 'AddressRepository');
        return const Addresses.error('File not found');
      }

      if (!await file.exists()) {
        developer.log('Address database file does not exist, will need to build', name: 'AddressRepository');
        return const Addresses.notFound();
      }

      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final oldVersion = json['version'] as int? ?? 1;

      final database = AddressDatabase.fromJson(json);
      developer.log('Loaded address database with ${database.addresses.length} addresses', name: 'AddressRepository');

      // If old version, re-save in new format
      if (oldVersion != _currentDatabaseVersion) {
        print('[AddressRepository] Migrating database from version $oldVersion to $_currentDatabaseVersion');
        await _saveDatabase(database);
        print('[AddressRepository] Migration complete');
      }

      return Addresses.success(database);
    });
  }

  Future<Addresses> buildDatabase(tiles.TilesRepository tilesRepository) async {
    final token = RootIsolateToken.instance;

    developer.log('Building address database from map tiles', name: 'AddressRepository');

    return await Isolate.run(() async {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token!);

      final addresses = await _processTiles(tilesRepository);

      Future<Addresses> saveAndReturnDatabase(AddressDatabase database) async {
        print('[AddressRepository] Saving address database to disk');
        await _saveDatabase(database);
        print('[AddressRepository] Address database saved successfully');
        return Addresses.success(database);
      }

      return switch (addresses) {
        Success(:final database) => await saveAndReturnDatabase(database),
        NotFound() => const Addresses.error('Map hash not found'),
        Error(:final message) => Addresses.error(message),
      };
    });
  }

  Future<File?> _getFile() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      return File('${appDir.path}/scootui/$_addressDatabaseFilename');
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveDatabase(AddressDatabase database) async {
    final file = await _getFile();
    if (file == null) {
      // TODO: actually handle this
      return;
    }

    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(database.toJson()));
  }
}

String _toBase32(int number) {
  const chars = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  if (number == 0) return '0';
  var result = '';
  while (number > 0) {
    result = chars[number % 32] + result;
    number = number ~/ 32;
  }
  return result;
}

Future<Addresses> _processTiles(tiles.TilesRepository tilesRepository) async {
  final mapHash = await tilesRepository.getMapHash();
  if (mapHash == null) {
    return const Addresses.error('Map hash not found');
  }

  final mbTiles = await tilesRepository.getMbTiles();
  switch (mbTiles) {
    case tiles.Success(:final mbTiles):
      final addresses = _extractAddresses(mbTiles);
      mbTiles.dispose();
      return Addresses.success(
          AddressDatabase(mapHash: mapHash, addresses: addresses));
    case tiles.NotFound():
      return const Addresses.error('Map not found');
    case tiles.Error(:final message):
      return Addresses.error(message);
  }
}

List<LatLng> _extractAddresses(MbTiles mbTiles) {
  final addresses = <LatLng>[];
  final coordinates = _getTileCoordinatesForBounds(mbTiles, 14);

  final totalTiles = coordinates.length;
  print('[AddressRepository] Building address database from $totalTiles tiles');

  var processedTiles = 0;
  var tilesWithAddresses = 0;

  for (var coordinate in coordinates) {
    processedTiles++;
    final tile = mbTiles.getTile(x: coordinate.x, y: coordinate.y, z: 14);
    if (tile == null) {
      continue;
    }

    final vectorTile = VectorTile.fromBytes(bytes: tile);
    try {
      final addressesLayer =
          vectorTile.layers.firstWhere((layer) => layer.name == 'addresses');
      final features = addressesLayer.features;
      final extent = addressesLayer.extent;

      if (features.isNotEmpty) {
        tilesWithAddresses++;
      }

      for (var feature in features) {
        final geometry = feature.decodeGeometry();
        if (geometry is GeometryPoint) {
          final coordinates = geometry.coordinates;
          // Convert from tile coordinates to geographic coordinates
          final n = math.pow(2.0, 14).toDouble();
          final lon =
              (coordinate.x + coordinates[0] / extent) / n * 360.0 - 180.0;
          final y = 1 -
              (coordinate.y + coordinates[1] / extent) / n;
          final z = math.pi * (1 - 2 * y);
          final latRad = math.atan((math.exp(z) - math.exp(-z)) / 2);
          final lat = latRad * 180.0 / math.pi;

          addresses.add(LatLng(lat, lon));
        }
      }
    } on StateError {
      continue;
    }

    // Log progress every 10% of tiles
    if (processedTiles % (totalTiles ~/ 10).clamp(1, totalTiles) == 0 || processedTiles == totalTiles) {
      final progress = (processedTiles / totalTiles * 100).toStringAsFixed(1);
      print('[AddressRepository] Progress: $progress% ($processedTiles/$totalTiles tiles, ${addresses.length} addresses found)');
    }
  }

  print('[AddressRepository] Address database build complete: ${addresses.length} addresses from $tilesWithAddresses tiles with address data');

  return addresses;
}

List<math.Point<int>> _getTileCoordinatesForBounds(MbTiles tiles, int zoom) {
  final meta = tiles.getMetadata();
  final bounds = meta.bounds;
  if (bounds == null) {
    throw Exception('No bounds found in MBTiles metadata');
  }

  final minTileX = _lonToTileX(bounds.left, zoom);
  final maxTileX = _lonToTileX(bounds.right, zoom);
  final minTileY = _latToTileYTMS(bounds.top, zoom);
  final maxTileY = _latToTileYTMS(bounds.bottom, zoom);
  final coordinates = <math.Point<int>>[];

  for (var x = minTileX; x <= maxTileX; x++) {
    final startY = math.min(minTileY, maxTileY);
    final endY = math.max(minTileY, maxTileY);

    for (var y = startY; y <= endY; y++) {
      coordinates.add(math.Point(x, y));
    }
  }

  return coordinates;
}

int _lonToTileX(double lon, int zoom) {
  final x = ((lon + 180) / 360 * (1 << zoom)).floor();
  return x;
}

int _latToTileYTMS(double lat, int zoom) {
  final latRad = lat * (math.pi / 180);
  final n = math.pow(2.0, zoom).toDouble();
  final y =
      (1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
          2.0 *
          n;
  final tmsY = (n - 1 - y).floor();
  return tmsY + 1;
}
