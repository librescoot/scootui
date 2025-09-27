import 'package:flutter/foundation.dart';
import '../config.dart';
import '../models/saved_location.dart';
import '../repositories/mdb_repository.dart';

/// Service for managing saved locations in Redis
class SavedLocationsService {
  final MDBRepository _mdbRepository;
  static const int maxSavedLocations = 10;

  SavedLocationsService(this._mdbRepository);

  /// Load all saved locations from Redis
  Future<List<SavedLocation>> loadSavedLocations() async {
    try {
      debugPrint('📍 SavedLocationsService: Loading saved locations');
      
      final locations = <SavedLocation>[];
      
      // Try to load up to maxSavedLocations
      for (int i = 0; i < maxSavedLocations; i++) {
        final locationData = await _loadLocationData(i);
        if (locationData != null) {
          locations.add(SavedLocation.fromRedisData(i, locationData));
        }
      }
      
      // Sort by last used date (most recent first)
      locations.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
      
      debugPrint('📍 SavedLocationsService: Loaded ${locations.length} saved locations');
      return locations;
    } catch (e) {
      debugPrint('📍 SavedLocationsService: Error loading saved locations: $e');
      return [];
    }
  }

  /// Save a new location
  Future<bool> saveLocation(SavedLocation location) async {
    try {
      debugPrint('📍 SavedLocationsService: Saving location: ${location.label}');
      
      // Find next available slot or reuse existing ID
      int targetId = location.id;
      if (targetId < 0) {
        targetId = await _findNextAvailableId();
        if (targetId < 0) {
          debugPrint('📍 SavedLocationsService: No available slots');
          return false;
        }
      }
      
      final locationToSave = location.copyWith(id: targetId);
      await _saveLocationData(targetId, locationToSave.toRedisData());
      
      debugPrint('📍 SavedLocationsService: Saved location with ID $targetId');
      return true;
    } catch (e) {
      debugPrint('📍 SavedLocationsService: Error saving location: $e');
      return false;
    }
  }

  /// Delete a saved location
  Future<bool> deleteLocation(int id) async {
    try {
      debugPrint('📍 SavedLocationsService: Deleting location with ID $id');
      
      final fields = ['latitude', 'longitude', 'label', 'created-at', 'last-used-at'];
      for (final field in fields) {
        final key = '${AppConfig.savedLocationsPrefix}.$id.$field';
        await _mdbRepository.hdel(AppConfig.redisSettingsPersistentCluster, key);
      }
      
      debugPrint('📍 SavedLocationsService: Deleted location with ID $id');
      return true;
    } catch (e) {
      debugPrint('📍 SavedLocationsService: Error deleting location: $e');
      return false;
    }
  }

  /// Update last used time for a location
  Future<bool> updateLastUsed(int id) async {
    try {
      final key = '${AppConfig.savedLocationsPrefix}.$id.last-used-at';
      await _mdbRepository.set(
        AppConfig.redisSettingsPersistentCluster, 
        key, 
        DateTime.now().toIso8601String()
      );
      return true;
    } catch (e) {
      debugPrint('📍 SavedLocationsService: Error updating last used: $e');
      return false;
    }
  }

  /// Load location data for a specific ID
  Future<Map<String, String>?> _loadLocationData(int id) async {
    final fields = ['latitude', 'longitude', 'label', 'created-at', 'last-used-at'];
    final data = <String, String>{};
    
    for (final field in fields) {
      final key = '${AppConfig.savedLocationsPrefix}.$id.$field';
      final value = await _mdbRepository.get(AppConfig.redisSettingsPersistentCluster, key);
      if (value != null) {
        data[field] = value;
      }
    }
    
    // Return null if no data found (empty location slot)
    return data.isEmpty ? null : data;
  }

  /// Save location data for a specific ID
  Future<void> _saveLocationData(int id, Map<String, String> data) async {
    for (final entry in data.entries) {
      final key = '${AppConfig.savedLocationsPrefix}.$id.${entry.key}';
      await _mdbRepository.set(AppConfig.redisSettingsPersistentCluster, key, entry.value);
    }
  }

  /// Find the next available ID slot
  Future<int> _findNextAvailableId() async {
    for (int i = 0; i < maxSavedLocations; i++) {
      final locationData = await _loadLocationData(i);
      if (locationData == null) {
        return i;
      }
    }
    return -1; // No available slots
  }
}
