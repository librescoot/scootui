import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/saved_location.dart';
import '../repositories/mdb_repository.dart';
import '../services/l10n_service.dart';
import '../services/saved_locations_service.dart';
import '../services/reverse_geocoding_service.dart';
import '../state/enums.dart';
import '../state/gps.dart';
import '../state/internet.dart';

part 'saved_locations_cubit.freezed.dart';

@freezed
class SavedLocationsState with _$SavedLocationsState {
  const factory SavedLocationsState.loading() = _Loading;
  const factory SavedLocationsState.loaded(List<SavedLocation> locations) = _Loaded;
  const factory SavedLocationsState.error(String message) = _Error;
}

class SavedLocationsCubit extends Cubit<SavedLocationsState> {
  final SavedLocationsService _savedLocationsService;
  final ReverseGeocodingService _reverseGeocodingService;

  SavedLocationsCubit(
    this._savedLocationsService,
    this._reverseGeocodingService,
  ) : super(const SavedLocationsState.loading());

  static SavedLocationsCubit create(BuildContext context) {
    final mdbRepository = context.read<MDBRepository>();
    final savedLocationsService = SavedLocationsService(mdbRepository);
    final reverseGeocodingService = ReverseGeocodingService();

    final cubit = SavedLocationsCubit(savedLocationsService, reverseGeocodingService);
    cubit.loadSavedLocations(); // Load initial data
    return cubit;
  }

  /// Load saved locations from storage
  Future<void> loadSavedLocations() async {
    try {
      emit(const SavedLocationsState.loading());
      final locations = await _savedLocationsService.loadSavedLocations();
      emit(SavedLocationsState.loaded(locations));
    } catch (e) {
      debugPrint('SavedLocationsCubit: Error loading locations: $e');
      emit(SavedLocationsState.error(L10nService.current.savedLocationsFailed));
    }
  }

  /// Save current GPS location with validation
  Future<bool> saveCurrentLocation(GpsData gpsData, InternetData internetData) async {
    try {
      debugPrint('SavedLocationsCubit: Attempting to save current location');

      // Validate GPS fix and coordinates
      if (!gpsData.hasRecentFix) {
        debugPrint('SavedLocationsCubit: No recent GPS fix available');
        return false;
      }

      if (gpsData.latitude == 0.0 && gpsData.longitude == 0.0) {
        debugPrint('SavedLocationsCubit: Invalid coordinates (0.0, 0.0)');
        return false;
      }

      debugPrint('SavedLocationsCubit: GPS validation passed, saving location');

      // Generate label based on internet connectivity
      String label;
      if (internetData.status == ConnectionStatus.connected) {
        // Try to get address via reverse geocoding
        final address = await _reverseGeocodingService.getAddress(gpsData.latitude, gpsData.longitude);
        label = address ?? '${gpsData.latitude.toStringAsFixed(6)}, ${gpsData.longitude.toStringAsFixed(6)}';
      } else {
        // Use coordinates as label when offline
        label = '${gpsData.latitude.toStringAsFixed(6)}, ${gpsData.longitude.toStringAsFixed(6)}';
      }

      final now = DateTime.now();
      final location = SavedLocation(
        id: -1, // Will be assigned by service
        latitude: gpsData.latitude,
        longitude: gpsData.longitude,
        label: label,
        createdAt: now,
        lastUsedAt: now,
      );

      final success = await _savedLocationsService.saveLocation(location);
      if (success) {
        // Reload locations to get updated list
        await loadSavedLocations();
        debugPrint('SavedLocationsCubit: Location saved successfully');
        return true;
      } else {
        debugPrint('SavedLocationsCubit: Failed to save location - storage full');
        return false;
      }
    } catch (e) {
      debugPrint('SavedLocationsCubit: Error saving location: $e');
      return false;
    }
  }

  /// Delete a saved location
  Future<bool> deleteLocation(int id) async {
    try {
      debugPrint('SavedLocationsCubit: Deleting location with ID $id');

      final success = await _savedLocationsService.deleteLocation(id);
      if (success) {
        // Reload locations to get updated list
        await loadSavedLocations();
        debugPrint('SavedLocationsCubit: Location deleted successfully');
        return true;
      } else {
        debugPrint('SavedLocationsCubit: Failed to delete location');
        return false;
      }
    } catch (e) {
      debugPrint('SavedLocationsCubit: Error deleting location: $e');
      return false;
    }
  }

  /// Update last used time for a location (when navigating to it)
  Future<void> updateLastUsed(int id) async {
    try {
      await _savedLocationsService.updateLastUsed(id);
      // Reload to get updated order
      await loadSavedLocations();
    } catch (e) {
      debugPrint('SavedLocationsCubit: Error updating last used: $e');
    }
  }

  /// Get current locations list (if loaded)
  List<SavedLocation> get currentLocations {
    final currentState = state;
    return currentState is _Loaded ? currentState.locations : [];
  }
}
