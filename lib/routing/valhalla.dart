import 'package:dio/dio.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';

import 'models.dart';
import 'valhalla_models.dart';

class ValhallaService {
  static const String _routeEndpoint = '/route';
  static const String _motorScooterCosting = 'motor_scooter';
  static const String _units = 'kilometers';
  static const String _language = 'en-US';
  static const int _connectTimeoutSeconds = 5;
  static const int _receiveTimeoutSeconds = 5;

  // Valhalla maneuver types that map to our instruction types
  static final Map<int, RouteInstruction Function(double, LatLng, int, String?, String?)> _maneuverMap = {
    2: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.right,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    3: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.left,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    5: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.right,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    6: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.left,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    7: (distance, location, index, streetName, instructionText) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    8: (distance, location, index, streetName, instructionText) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    9: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.slightRight,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    10: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.right,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    11: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.sharpRight,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    12: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.rightUTurn,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    13: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.uTurn,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    14: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.sharpLeft,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    15: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.left,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    16: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.slightLeft,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    17: (distance, location, index, streetName, instructionText) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    18: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.right,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    19: (distance, location, index, streetName, instructionText) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.left,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    20: (distance, location, index, streetName, instructionText) => RouteInstruction.exit(
          distance: distance,
          side: ExitSide.right,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    21: (distance, location, index, streetName, instructionText) => RouteInstruction.exit(
          distance: distance,
          side: ExitSide.left,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    22: (distance, location, index, streetName, instructionText) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    23: (distance, location, index, streetName, instructionText) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.right,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    24: (distance, location, index, streetName, instructionText) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.left,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
    // Note: Valhalla maneuver type 26 (RoundaboutEnter) has roundabout_exit_count.
    // Our RouteInstruction.roundabout expects exitNumber.
    // Type 25 is RoundaboutExit in OSRM, Valhalla uses type 27 for ExitRoundabout.
    // The example route.json has type 26 with roundabout_exit_count.
    // This mapping might need adjustment based on how exitNumber is derived for Valhalla.
    // For now, passing maneuver.beginShapeIndex as originalShapeIndex.
    // The example JSON for type 26 does not have an explicit exit number, but `roundabout_exit_count`.
    // This might be a slight mismatch or requires interpretation.
    // For type 26, Valhalla docs say "The number of exits to take from the roundabout."
    // The example JSON has "roundabout_exit_count": 2 for type 26. This should be the exit number.
    26: (distance, location, index, streetName, instructionText) => RouteInstruction.roundabout(
          distance: distance,
          side: RoundaboutSide.right, // Assuming right-hand traffic default for roundabout side
          exitNumber: 1, // Placeholder - this needs to come from maneuver.roundabout_exit_count if available
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
        ),
  };

  final Dio _dio;
  final String serverURL;

  ValhallaService({required this.serverURL})
      : _dio = Dio(BaseOptions(
          baseUrl: serverURL,
          connectTimeout: Duration(seconds: _connectTimeoutSeconds),
          receiveTimeout: Duration(seconds: _receiveTimeoutSeconds),
        ));

  Future<Route> getRoute(LatLng start, LatLng end) async {
    final requestData = {
      'locations': [
        {'lat': start.latitude, 'lon': start.longitude},
        {'lat': end.latitude, 'lon': end.longitude}
      ],
      'costing': _motorScooterCosting,
      'units': _units,
      'language': _language,
      'directions_options': {
        'units': _units,
        'language': _language,
      }
    };

    // print('ValhallaService: Request to $serverURL$_routeEndpoint');
    // print('ValhallaService: Request data: $requestData');

    try {
      final response = await _dio.post(
        _routeEndpoint,
        data: requestData,
      );

      // print('ValhallaService: Response status: ${response.statusCode}');
      // print('ValhallaService: Response data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Failed to get route from Valhalla');
      }

      final valhallaResponse = ValhallaResponse.fromJson(response.data);
      final leg = valhallaResponse.trip.legs.first;

    final List<LatLng> waypoints = [];
    final List<RouteInstruction> instructions = [];

    // Extract waypoints from shape
    final points =
        decodePolyline(leg.shape, accuracyExponent: 6).map((e) => LatLng(e[0].toDouble(), e[1].toDouble())).toList();
    waypoints.addAll(points);

    // Extract instructions
    for (final maneuver in leg.maneuvers) {
      final location = LatLng(
        points[maneuver.beginShapeIndex].latitude,
        points[maneuver.beginShapeIndex].longitude,
      );

      final distance = maneuver.length * 1000; // Convert to meters

      // Special handling for roundabout exit number if needed
      int exitCountForRoundabout = maneuver.roundaboutExitCount ?? 1; // Default to 1 if null

      // Extract street name and instruction text from maneuver
      final streetName = _extractStreetName(maneuver);
      final instructionText = _extractInstructionText(maneuver);

      final instruction = _createInstruction(maneuver, distance, location, exitCountForRoundabout);
      if (instruction != null) {
        instructions.add(instruction);
      }
    }

    return Route(
      distance: leg.summary.length * 1000, // Convert to meters
      duration: Duration(seconds: leg.summary.time),
      waypoints: waypoints,
      instructions: instructions,
    );
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception('Connection to routing server timed out. Please try again.');
        case DioExceptionType.receiveTimeout:
          throw Exception('Routing server took too long to respond. Please try again.');
        case DioExceptionType.connectionError:
          throw Exception('Cannot connect to routing server. Check your connection.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 400) {
            throw Exception('Invalid route request. Destination may be unreachable.');
          } else if (statusCode == 429) {
            throw Exception('Too many routing requests. Please wait a moment.');
          } else if (statusCode != null && statusCode >= 500) {
            throw Exception('Routing server error. Please try again later.');
          }
          throw Exception('Routing request failed: ${e.response?.statusMessage ?? "Unknown error"}');
        case DioExceptionType.cancel:
          throw Exception('Routing request was cancelled.');
        default:
          throw Exception('Routing failed: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Failed to calculate route: $e');
    }
  }

  RouteInstruction? _createInstruction(Maneuver maneuver, double distance, LatLng location, int roundaboutExitCount) {
    final type = maneuver.type;
    final streetName = _extractStreetName(maneuver);
    final instructionText = _extractInstructionText(maneuver);
    final postInstructionText = maneuver.verbalPostTransitionInstruction;

    final instructionCreator = _maneuverMap[type];
    if (instructionCreator != null) {
      if (type == 26) {
        // ManeuverType.kRoundaboutEnter
        return RouteInstruction.roundabout(
          distance: distance,
          side: RoundaboutSide.right, // Default, Valhalla might not specify side for enter
          exitNumber: roundaboutExitCount,
          location: location,
          originalShapeIndex: maneuver.beginShapeIndex,
          streetName: streetName,
          instructionText: instructionText,
          postInstructionText: postInstructionText,
          bearingBefore: maneuver.bearingBefore,
          bearingAfter: maneuver.bearingAfter,
        );
      }
      // For other types, we need to adapt the creator to include postInstructionText
      // A better approach is to pass the whole maneuver object to the creators.
      // For now, let's just add it to the 'other' type as a proof of concept.
      return instructionCreator(distance, location, maneuver.beginShapeIndex, streetName, instructionText);
    }
    return RouteInstruction.other(
      distance: distance,
      location: location,
      originalShapeIndex: maneuver.beginShapeIndex,
      streetName: streetName,
      instructionText: instructionText,
      postInstructionText: postInstructionText,
    );
  }

  String? _extractStreetName(Maneuver maneuver) {
    // Try to get street name from streetNames first, fallback to beginStreetNames
    if (maneuver.streetNames?.isNotEmpty == true) {
      return maneuver.streetNames!.first;
    }
    if (maneuver.beginStreetNames?.isNotEmpty == true) {
      return maneuver.beginStreetNames!.first;
    }
    return null;
  }

  String? _extractInstructionText(Maneuver maneuver) {
    // Use verbal pre-transition instruction for turn-by-turn display, fallback to other options
    return maneuver.verbalPreTransitionInstruction ??
        maneuver.verbalTransitionAlertInstruction ?? // Added alert as a secondary fallback
        maneuver.instruction;
  }
}
