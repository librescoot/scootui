import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:vector_tile/vector_tile.dart';

import '../config.dart';
import '../repositories/tiles_repository.dart';
import '../routing/models.dart';
import '../routing/route_helpers.dart';
import '../routing/valhalla.dart';
import '../services/toast_service.dart';
import '../state/gps.dart';
import '../state/navigation.dart';
import '../state/vehicle.dart';
import 'mdb_cubits.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  late final StreamSubscription<GpsData> _gpsSub;
  late final StreamSubscription<NavigationData> _navigationSub;
  late final StreamSubscription<VehicleData> _vehicleSub;
  final NavigationSync _navigationSync;
  final TilesRepository _tilesRepository;
  VehicleData _vehicleData;
  MbTiles? _mbTiles;

  static const double _arrivalProximityMeters = 50.0;
  static const double _shutdownProximityMeters = 250.0;
  static const double _offRouteTolerance = 40.0; // meters
  DateTime? _lastReroute;
  DateTime? _lastStreetLog;
  LatLng? _currentPosition;

  final distanceCalculator = Distance();

  NavigationCubit({
    required Stream<GpsData> gpsStream,
    required NavigationSync navigationSync,
    required Stream<VehicleData> vehicleStream,
    required TilesRepository tilesRepository,
  })  : _navigationSync = navigationSync,
        _tilesRepository = tilesRepository,
        _vehicleData = VehicleData(), // Initialize with a default or initial value
        super(const NavigationState()) {
    _gpsSub = gpsStream.listen(_onGpsData);
    _navigationSub = _navigationSync.stream.listen(_onNavigationData);
    _vehicleSub = vehicleStream.listen(_onVehicleData);

    // Process initial navigation data if available
    _processInitialNavigationData();

    // Load MBTiles for street property logging
    _loadMbTiles();
  }

  void _onVehicleData(VehicleData data) {
    _vehicleData = data;
  }

  Future<void> _loadMbTiles() async {
    final tiles = await _tilesRepository.getMbTiles();
    if (tiles is Success) {
      _mbTiles = tiles.mbTiles;
    }
  }

  @override
  Future<void> close() async {
    // Clear navigation destination if we've arrived
    if (state.status == NavigationStatus.arrived) {
      print("NavigationCubit: Clearing destination on shutdown since we've arrived.");
      await clearNavigation();
    }
    // If the scooter shuts down and the current location is within 250m of the GPS destination,
    // then CLEAR THE GPS navigation destination.
    else if (_vehicleData.state == ScooterState.shuttingDown &&
        state.destination != null &&
        _currentPosition != null &&
        distanceCalculator.as(LengthUnit.Meter, _currentPosition!, state.destination!) < _shutdownProximityMeters) {
      print("NavigationCubit: Clearing destination due to shutdown within ${_shutdownProximityMeters}m of destination.");
      await clearNavigation();
    }

    _mbTiles?.dispose();
    _gpsSub.cancel();
    _navigationSub.cancel();
    _vehicleSub.cancel();
    return super.close();
  }

  void _processInitialNavigationData() {
    final initialData = _navigationSync.state;
    if (initialData.destination.isNotEmpty) {
      _onNavigationData(initialData);
    }
  }

  Future<void> _calculateRoute(LatLng destination) async {
    emit(state.copyWith(
      destination: destination,
      status: NavigationStatus.calculating,
      error: null,
    ));

    try {
      final position = _currentPosition;
      if (position == null) {
        const errorMsg = 'Current position not available';
        ToastService.showError(errorMsg);
        emit(state.copyWith(
          status: NavigationStatus.error,
          error: errorMsg,
        ));
        return;
      }

      final valhallaService = ValhallaService(serverURL: AppConfig.valhallaEndpoint);
      final route = await valhallaService.getRoute(position, destination);

      if (route.waypoints.isEmpty) {
        const errorMsg = 'Could not calculate route';
        ToastService.showError(errorMsg);
        emit(state.copyWith(
          status: NavigationStatus.error,
          error: errorMsg,
        ));
        return;
      }

      final upcomingInstructions = RouteHelpers.findUpcomingInstructions(position, route);
      final distanceToDestination = distanceCalculator.as(
        LengthUnit.Meter,
        position,
        destination,
      );

      emit(state.copyWith(
        route: route,
        upcomingInstructions: upcomingInstructions,
        status: NavigationStatus.navigating,
        distanceToDestination: distanceToDestination,
        error: null,
      ));
    } catch (e) {
      final errorMsg = 'Failed to calculate route: $e';
      ToastService.showError(errorMsg);
      emit(state.copyWith(
        status: NavigationStatus.error,
        error: errorMsg,
      ));
    }
  }

  Future<void> clearNavigation() async {
    emit(const NavigationState());
    await _navigationSync.clearDestination();
  }

  void _onNavigationData(NavigationData data) {
    print("NavigationCubit: Received NavigationData: ${data.destination}");
    try {
      if (data.destination.isEmpty) {
        print("NavigationCubit: Destination is empty, clearing navigation state.");
        // Clear navigation if destination is empty
        emit(const NavigationState());
        return;
      }

      final coordinates = data.destination.split(",").map(double.parse).toList();
      final destination = LatLng(coordinates[0], coordinates[1]);
      print("NavigationCubit: Parsed destination: $destination");

      if (_currentPosition == null) {
        print("NavigationCubit: Current position is null, cannot calculate route yet.");
        // Store pending destination and show conditions that need to be met
        emit(state.copyWith(
            destination: destination,
            status: NavigationStatus.idle,
            error: "Waiting for recent GPS fix to calculate route.",
            pendingConditions: ["Waiting for GPS fix"]));
        return;
      }

      // If we are already actively navigating, rerouting, or calculating for the *same* destination, do nothing.
      if (state.destination == destination &&
          (state.status == NavigationStatus.navigating ||
              state.status == NavigationStatus.rerouting ||
              state.status == NavigationStatus.calculating)) {
        print("NavigationCubit: Destination is the same and already actively navigating/processing.");
        return;
      }

      // If we have a current position, and the conditions above are not met (i.e., it's a new destination,
      // or it's the same destination but we are not actively navigating/processing it, e.g., status is idle, arrived, or error),
      // then calculate the route.
      if (_currentPosition != null) {
        print(
            "NavigationCubit: Conditions met to calculate route. CurrentPos: $_currentPosition, NewDest: $destination, OldDest: ${state.destination}, Status: ${state.status}");
        ToastService.showInfo('New navigation destination received. Calculating route...');
        // Clear pending conditions since we can now calculate route
        emit(state.copyWith(pendingConditions: []));
        _calculateRoute(destination);
      } else {
        // This case should be covered by the earlier _currentPosition == null check,
        // but kept for clarity if logic changes.
        print(
            "NavigationCubit: Current position is null, cannot calculate route yet (should have been handled earlier). Dest: $destination");
        // State was already set if _currentPosition was null earlier.
      }
    } catch (e) {
      print("NavigationCubit: Error processing navigation data: $e");
      final errorMsg = 'Error processing navigation data: $e';
      ToastService.showError(errorMsg);
      emit(state.copyWith(
        status: NavigationStatus.error,
        error: errorMsg,
      ));
    }
  }

  void _onGpsData(GpsData data) {
    // Only update position if GPS fix is recent (within 10 seconds)
    if (data.hasRecentFix) {
      final position = LatLng(data.latitude, data.longitude);
      _currentPosition = position;

      // Log nearest street properties
      _logNearestStreetProperties(position);
    } else {
      _currentPosition = null;
    }

    final currentState = state;

    // If we have a destination but no route (which happens on startup with a pending destination),
    // and we just received a GPS position, it's time to calculate the route.
    if (currentState.destination != null && currentState.route == null && _currentPosition != null) {
      // We check for idle or error status to ensure we only trigger this
      // if we're not already in the middle of a calculation or navigation.
      if (currentState.status == NavigationStatus.idle || currentState.status == NavigationStatus.error) {
        // Before calculating route, check if we're already at the destination
        final distanceToDestination = distanceCalculator.as(
          LengthUnit.Meter,
          _currentPosition!,
          currentState.destination!,
        );

        if (distanceToDestination < _arrivalProximityMeters) {
          print("NavigationCubit (_onGpsData): Already at destination (${distanceToDestination.toStringAsFixed(1)}m), clearing navigation instead of calculating route.");
          clearNavigation();
          return;
        }

        print("NavigationCubit (_onGpsData): Destination is pending and GPS is now available. Calculating route.");
        _calculateRoute(currentState.destination!);
        return; // Exit because _calculateRoute will emit the next state.
      }
    }

    // If we're not actively navigating (or arrived) and have no route, do nothing further.
    // We need to process GPS updates when arrived so we can detect leaving the arrival zone.
    if ((currentState.status != NavigationStatus.navigating &&
         currentState.status != NavigationStatus.arrived) ||
        currentState.route == null) {
      return;
    }

    // Update navigation state based on current position if available
    if (_currentPosition != null) {
      _updateNavigationState(_currentPosition!);
    }
  }

  void _updateNavigationState(LatLng position) {
    final route = state.route;
    final destination = state.destination;

    if (route == null || destination == null) {
      return;
    }

    // Calculate distance to destination
    final distanceToDestination = distanceCalculator.as(
      LengthUnit.Meter,
      position,
      destination,
    );


    // Check if we were arrived but now moved away and scooter is not shutting down
    if (state.status == NavigationStatus.arrived &&
        distanceToDestination >= _arrivalProximityMeters &&
        _vehicleData.state != ScooterState.shuttingDown) {
      print("NavigationCubit: Resuming navigation after moving away from destination.");
      ToastService.showInfo('Resuming navigation.');
      emit(state.copyWith(
        status: NavigationStatus.navigating,
        distanceToDestination: distanceToDestination,
      ));
      // Continue to recalculate instructions and check for off-route
    }

    // Check if we've arrived
    if (distanceToDestination < _arrivalProximityMeters) {
      ToastService.showSuccess('You have arrived at your destination!');
      emit(state.copyWith(
        status: NavigationStatus.arrived,
        distanceToDestination: distanceToDestination,
      ));
      return;
    }

    // Find closest point on route and check for deviation
    final (closestPoint, segmentIndex, distanceFromRoute) = RouteHelpers.findClosestPointOnRoute(
      position,
      route.waypoints,
    );


    // Check if we're off route
    final isOffRoute = distanceFromRoute > _offRouteTolerance;

    // Calculate snapped position - use closest point on route when on-route, original position when off-route
    final snappedPosition = isOffRoute ? position : closestPoint;

    // Find upcoming instructions
    var upcomingInstructions = RouteHelpers.findUpcomingInstructions(position, route);

    // If off-route, insert a "return to route" instruction at the beginning
    if (isOffRoute) {
      final returnInstruction = RouteInstruction.other(
        distance: distanceFromRoute,
        duration: Duration.zero,
        location: closestPoint,
        originalShapeIndex: 0,
        instructionText: "Return to the route",
      );
      upcomingInstructions = [returnInstruction, ...upcomingInstructions];
    }

    emit(state.copyWith(
      upcomingInstructions: upcomingInstructions,
      distanceToDestination: distanceToDestination,
      distanceFromRoute: distanceFromRoute,
      isOffRoute: isOffRoute,
      snappedPosition: snappedPosition,
    ));

    // Check if we need to reroute
    if (isOffRoute && (_lastReroute == null || DateTime.now().difference(_lastReroute!) > const Duration(seconds: 5))) {
      ToastService.showWarning('Off route. Attempting to reroute...');
      _reroute(position, destination);
    }
  }

  Future<void> _reroute(LatLng position, LatLng destination) async {
    _lastReroute = DateTime.now();

    emit(state.copyWith(status: NavigationStatus.rerouting));

    try {
      final valhallaService = ValhallaService(serverURL: AppConfig.valhallaEndpoint);
      final route = await valhallaService.getRoute(position, destination);

      if (route.waypoints.isEmpty) {
        const errorMsg = 'Could not calculate new route';
        ToastService.showError(errorMsg);
        emit(state.copyWith(
          status: NavigationStatus.error,
          error: errorMsg,
        ));
        return;
      }

      emit(state.copyWith(
        route: route,
        status: NavigationStatus.navigating,
        error: null,
      ));

      // Recalculate navigation state with the new route
      _updateNavigationState(position);
    } catch (e) {
      final errorMsg = 'Failed to reroute: $e';
      ToastService.showError(errorMsg);
      emit(state.copyWith(
        status: NavigationStatus.error,
        error: errorMsg,
      ));
    }
  }

  void _logNearestStreetProperties(LatLng position) {
    // Throttle logging to every 3 seconds
    if (_lastStreetLog != null && DateTime.now().difference(_lastStreetLog!) < const Duration(seconds: 3)) {
      return;
    }

    if (_mbTiles == null) {
      return;
    }

    _lastStreetLog = DateTime.now();

    // If we're navigating and on-route, use the snapped position (more accurate)
    final queryPosition = (state.route != null && state.snappedPosition != null && !(state.isOffRoute ?? false))
        ? state.snappedPosition!
        : position;

    try {
      // Convert position to tile coordinates (use zoom 14 for detailed street data)
      const zoom = 14;
      final tileX = _lonToTileX(queryPosition.longitude, zoom);
      final tileY = _latToTileYTMS(queryPosition.latitude, zoom);

      // Get the tile
      final tileData = _mbTiles!.getTile(x: tileX, y: tileY, z: zoom);
      if (tileData == null) {
        return;
      }

      // Parse vector tile
      final vectorTile = VectorTile.fromBytes(bytes: tileData);
      final streetsLayer = vectorTile.layers.firstWhere(
        (layer) => layer.name == 'streets',
        orElse: () => throw StateError('No streets layer'),
      );

      if (streetsLayer.features.isEmpty) {
        return;
      }

      // Street types that are actual roads (not pedestrian ways)
      const roadTypes = {
        'motorway', 'trunk', 'primary', 'secondary', 'tertiary',
        'unclassified', 'residential', 'living_street', 'service'
      };

      // Find nearest actual road (not footway/path/etc)
      double minDistance = double.infinity;
      VectorTileFeature? nearestFeature;

      for (var feature in streetsLayer.features) {
        // Decode geometry (which also decodes properties)
        final geometry = feature.decodeGeometry();

        // Check if this is an actual road (not footway/path/cycleway/etc)
        if (feature.properties != null) {
          final kind = feature.properties!['kind']?.value.toString();
          if (kind == null || !roadTypes.contains(kind)) {
            continue; // Skip pedestrian ways
          }
        }

        if (geometry is GeometryLineString) {
          final coords = geometry.coordinates;

          // Convert all tile coordinates to geographic coordinates
          final points = <LatLng>[];
          for (var point in coords) {
            // Vector tiles use XYZ (Y=0 at top), but MBTiles uses TMS (Y=0 at bottom)
            // So we need to flip the Y coordinate within the tile
            final n = math.pow(2.0, zoom).toDouble();
            final extent = streetsLayer.extent;
            final lon = (tileX + point[0] / extent) / n * 360.0 - 180.0;
            final y = 1 - (tileY + 1 - point[1] / extent) / n;  // Flip Y within tile for TMS
            final z = math.pi * (1 - 2 * y);
            final latRad = math.atan((math.exp(z) - math.exp(-z)) / 2);
            final lat = latRad * 180.0 / math.pi;
            points.add(LatLng(lat, lon));
          }

          // Check distance to each line segment
          for (var i = 0; i < points.length - 1; i++) {
            final segmentStart = points[i];
            final segmentEnd = points[i + 1];

            final distance = _distanceToSegment(queryPosition, segmentStart, segmentEnd);

            if (distance < minDistance) {
              minDistance = distance;
              nearestFeature = feature;
            }
          }
        }
      }

      if (nearestFeature != null && nearestFeature.properties != null) {
        final props = nearestFeature.properties!;
        final name = props['name']?.value.toString();
        final kind = props['kind']?.value.toString();
        final maxspeed = props['maxspeed']?.value.toString();

        final displayName = name ?? '';
        final displayKind = kind ?? '';
        final displaySpeed = maxspeed ?? '';

        // Update state with current street data
        emit(state.copyWith(
          currentStreetName: displayName.isEmpty ? null : displayName,
          currentRoadType: displayKind.isEmpty ? null : displayKind,
          currentSpeedLimit: displaySpeed.isEmpty ? null : displaySpeed,
        ));
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  int _lonToTileX(double lon, int zoom) {
    return ((lon + 180) / 360 * (1 << zoom)).floor();
  }

  int _latToTileYTMS(double lat, int zoom) {
    final latRad = lat * (math.pi / 180);
    final n = math.pow(2.0, zoom).toDouble();
    final y = (1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * n;
    final tmsY = (n - 1 - y).floor();
    return tmsY + 1;  // MBTiles uses 1-indexed TMS
  }

  /// Calculate distance from point to line segment
  double _distanceToSegment(LatLng point, LatLng segmentStart, LatLng segmentEnd) {
    // If the segment is actually just a point
    if (segmentStart.latitude == segmentEnd.latitude &&
        segmentStart.longitude == segmentEnd.longitude) {
      return distanceCalculator.as(LengthUnit.Meter, point, segmentStart);
    }

    // Vector from segment start to end
    final dx = segmentEnd.longitude - segmentStart.longitude;
    final dy = segmentEnd.latitude - segmentStart.latitude;

    // Vector from segment start to point
    final px = point.longitude - segmentStart.longitude;
    final py = point.latitude - segmentStart.latitude;

    // Project point onto line (parameter t)
    final t = (px * dx + py * dy) / (dx * dx + dy * dy);

    // Clamp t to [0, 1] to stay on segment
    final tClamped = t.clamp(0.0, 1.0);

    // Find closest point on segment
    final closestLat = segmentStart.latitude + tClamped * dy;
    final closestLon = segmentStart.longitude + tClamped * dx;
    final closestPoint = LatLng(closestLat, closestLon);

    return distanceCalculator.as(LengthUnit.Meter, point, closestPoint);
  }
}
