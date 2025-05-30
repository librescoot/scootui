import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import 'models.dart';

class RouteHelpers {
  static const double _coordinateMatchTolerance = 0.00001; // About 1 meter
  static const double _offRouteTolerance = 50.0; // Meters

  /// Finds the closest point on a line segment to a given point
  static LatLng findClosestPointOnSegment(
    LatLng point,
    LatLng segmentStart,
    LatLng segmentEnd,
  ) {
    // Convert to radians for calculations
    final lat1 = segmentStart.latitude * (math.pi / 180);
    final lon1 = segmentStart.longitude * (math.pi / 180);
    final lat2 = segmentEnd.latitude * (math.pi / 180);
    final lon2 = segmentEnd.longitude * (math.pi / 180);
    final lat3 = point.latitude * (math.pi / 180);
    final lon3 = point.longitude * (math.pi / 180);

    // Calculate vectors
    final dx = lon2 - lon1;
    final dy = lat2 - lat1;
    final len2 = dx * dx + dy * dy;

    if (len2 == 0) return segmentStart;

    // Calculate projection
    var t = ((lon3 - lon1) * dx + (lat3 - lat1) * dy) / len2;
    t = math.max(0, math.min(1, t));

    // Calculate the closest point
    final projLon = lon1 + t * dx;
    final projLat = lat1 + t * dy;

    // Convert back to degrees
    return LatLng(
      projLat * (180 / math.pi),
      projLon * (180 / math.pi),
    );
  }

  /// Finds the closest point on a route polyline to a given point
  static (LatLng, int, double) findClosestPointOnRoute(
    LatLng point,
    List<LatLng> polyline,
  ) {
    if (polyline.isEmpty) {
      throw ArgumentError('Polyline cannot be empty');
    }

    var closestPoint = LatLng(polyline.first.latitude, polyline.first.longitude);
    var closestDistance = double.infinity;
    var closestSegmentIndex = 0;

    for (var i = 0; i < polyline.length - 1; i++) {
      final segmentStart = LatLng(polyline[i].latitude, polyline[i].longitude);
      final segmentEnd = LatLng(polyline[i + 1].latitude, polyline[i + 1].longitude);

      final pointOnSegment = findClosestPointOnSegment(
        point,
        segmentStart,
        segmentEnd,
      );

      final distance = const Distance().as(
        LengthUnit.Meter,
        point,
        pointOnSegment,
      );

      if (distance < closestDistance) {
        closestDistance = distance;
        closestPoint = pointOnSegment;
        closestSegmentIndex = i;
      }
    }

    return (closestPoint, closestSegmentIndex, closestDistance);
  }

  /// Finds the next instruction based on the current position and route
  static RouteInstruction? findNextInstruction(
    LatLng currentPosition,
    Route route,
  ) {
    if (route.waypoints.isEmpty) {
      return null;
    }

    // Find the closest point on the route
    final (closestPoint, segmentIndex, distanceFromRoute) = findClosestPointOnRoute(
      currentPosition,
      route.waypoints,
    );

    // If we're too far from the route, don't show instructions
    if (distanceFromRoute > _offRouteTolerance) {
      return null;
    }

    // Find the next instruction after the current segment
    var nextInstruction = _findNextInstructionAfterSegment(
      route.instructions,
      route.waypoints,
      segmentIndex,
      closestPoint,
    );

    // If we didn't find a next instruction, we might be very close to or past the last one
    if (nextInstruction == null && segmentIndex > 0) {
      // Try looking from the previous segment
      nextInstruction = _findNextInstructionAfterSegment(
        route.instructions,
        route.waypoints,
        segmentIndex - 1,
        closestPoint,
      );
    }

    return nextInstruction;
  }

  /// Helper to find the next instruction after a given segment
  static RouteInstruction? _findNextInstructionAfterSegment(
    List<RouteInstruction> instructions,
    List<LatLng> polyline, // polyline is still needed for distance calculation if instructionPoint is not enough
    int segmentIndexToCompareAgainst, // Renamed for clarity from 'segmentIndex'
    LatLng fromPoint,
  ) {
    for (final instruction in instructions) {
      // Use the stored originalShapeIndex directly
      final int instructionShapeIndex = instruction.originalShapeIndex;

      // Ensure originalShapeIndex is valid before using (e.g. not -1 if we used that for null beginShapeIndex)
      // Assuming current implementation results in non-negative originalShapeIndex from Valhalla.
      if (instructionShapeIndex < 0) {
        // Or any other sentinel for invalid/unmapped index
        continue; // Skip instructions that couldn't be properly mapped to the shape
      }

      if (instructionShapeIndex > segmentIndexToCompareAgainst) {
        // instructionPoint is still needed to calculate the distance to it
        final instructionPoint = instruction.location;

        // Calculate distance to the instruction's starting point
        final distanceToManeuverStart = const Distance().as(
          LengthUnit.Meter,
          fromPoint,
          instructionPoint,
        );

        return instruction.copyWith(distance: distanceToManeuverStart);
      }
    }

    return null;
  }
}
