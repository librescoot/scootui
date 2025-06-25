import 'package:latlong2/latlong.dart';
import 'package:scooter_cluster/repositories/tiles_repository.dart';
import 'package:sqlite3/sqlite3.dart';

class TileAddressRepository {
  final TilesRepository tilesRepository;
  Database? db;

  TileAddressRepository(this.tilesRepository);

  Future<LatLng?> getLocation(String code) async {
    if (db == null) {
      return null;
    }

    final result = db?.select(
        "SELECT lat, lng FROM addresses WHERE id = ?", [code]).firstOrNull;

    if (result == null) {
      return null;
    } else {
      final lat = result['lat'] as double;
      final lng = result['lng'] as double;
      return LatLng(lat, lng);
    }
  }

  Future<void> init() async {
    final dbPath =
        await tilesRepository.getMapFilename() ?? 'sqlite:in-memory:';
    db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
  }
}
