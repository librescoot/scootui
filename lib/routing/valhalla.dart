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

  // Valhalla maneuver type constants
  static const int _kStart = 1;
  static const int _kStartRight = 2;
  static const int _kStartLeft = 3;
  static const int _kDestination = 4;
  static const int _kDestinationRight = 5;
  static const int _kDestinationLeft = 6;
  static const int _kContinue = 7;
  static const int _kBecomes = 8;
  static const int _kSlightRight = 9;
  static const int _kRight = 10;
  static const int _kSharpRight = 11;
  static const int _kUturnRight = 12;
  static const int _kUturn = 13;
  static const int _kSharpLeft = 14;
  static const int _kLeft = 15;
  static const int _kSlightLeft = 16;
  static const int _kRampStraight = 17;
  static const int _kRampRight = 18;
  static const int _kRampLeft = 19;
  static const int _kExitRight = 20;
  static const int _kExitLeft = 21;
  static const int _kStayStraight = 22;
  static const int _kStayRight = 23;
  static const int _kStayLeft = 24;
  static const int _kMerge = 25;
  static const int _kRoundaboutEnter = 26;
  static const int _kRoundaboutExit = 27;
  static const int _kFerryEnter = 28;
  static const int _kFerryExit = 29;
  static const int _kMergeRight = 37;
  static const int _kMergeLeft = 38;

  // Valhalla maneuver types that map to our instruction types
  static final Map<int, RouteInstruction Function(double, Duration, LatLng, int, String?, String?, String?, String?, String?, bool)> _maneuverMap = {
    // Start/Destination types (0-6) - map to Other
    0: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    1: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    2: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    3: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    4: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    5: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    6: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    7: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    8: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    9: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.slightRight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    10: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.right,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    11: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.sharpRight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    12: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.rightUTurn,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    13: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.uTurn,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    14: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.sharpLeft,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    15: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.left,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    16: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.slightLeft,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    17: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    18: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.right,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    19: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.left,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    20: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.exit(
          distance: distance,
          side: ExitSide.right,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    21: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.exit(
          distance: distance,
          side: ExitSide.left,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    22: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    23: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.right,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    24: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.left,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    // Merge types (25, 37, 38)
    25: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.merge(
          distance: distance,
          direction: MergeDirection.straight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    // Roundabout types (26, 27) - Type 26 handled specially in _createInstruction
    26: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.roundabout(
          distance: distance,
          side: RoundaboutSide.right,
          exitNumber: 1, // Placeholder - overridden in _createInstruction
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    27: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.exit(
          distance: distance,
          side: ExitSide.right, // Placeholder - will be determined from bearings
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    // Ferry types (28, 29)
    28: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    29: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    // Merge directional types (37, 38)
    37: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.merge(
          distance: distance,
          direction: MergeDirection.right,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
        ),
    38: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal, succinct, multiCue) => RouteInstruction.merge(
          distance: distance,
          direction: MergeDirection.left,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
          verbalSuccinctInstruction: succinct,
          verbalMultiCue: multiCue,
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
      final duration = Duration(seconds: maneuver.time.toInt()); // Convert to Duration

      // Special handling for roundabout exit number if needed
      int exitCountForRoundabout = maneuver.roundaboutExitCount ?? 1; // Default to 1 if null

      final instruction = _createInstruction(maneuver, distance, duration, location, exitCountForRoundabout);
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

  RouteInstruction? _createInstruction(Maneuver maneuver, double distance, Duration duration, LatLng location, int roundaboutExitCount) {
    final type = maneuver.type;
    final streetName = _extractStreetName(maneuver);
    final instructionText = maneuver.instruction;
    final postInstructionText = maneuver.verbalPostTransitionInstruction;
    final verbalAlertInstruction = maneuver.verbalTransitionAlertInstruction;
    final verbalInstruction = maneuver.verbalPreTransitionInstruction;
    final verbalSuccinctInstruction = maneuver.verbalSuccinctTransitionInstruction;
    final verbalMultiCue = maneuver.verbalMultiCue;

    final instructionCreator = _maneuverMap[type];
    if (instructionCreator != null) {
      if (type == _kRoundaboutEnter) {
        // kRoundaboutEnter - use special roundabout icon with exit number
        return RouteInstruction.roundabout(
          distance: distance,
          side: RoundaboutSide.right, // Default, Valhalla might not specify side for enter
          exitNumber: roundaboutExitCount,
          duration: duration,
          location: location,
          originalShapeIndex: maneuver.beginShapeIndex,
          streetName: streetName,
          instructionText: instructionText,
          postInstructionText: postInstructionText,
          bearingBefore: maneuver.bearingBefore,
          bearingAfter: maneuver.bearingAfter,
          verbalAlertInstruction: verbalAlertInstruction,
          verbalInstruction: verbalInstruction,
          verbalSuccinctInstruction: verbalSuccinctInstruction,
          verbalMultiCue: verbalMultiCue,
        );
      }
      if (type == _kRoundaboutExit) {
        // kRoundaboutExit - use simple exit icon
        // Determine exit side from bearing change if available
        ExitSide exitSide = ExitSide.right; // Default
        if (maneuver.bearingBefore != null && maneuver.bearingAfter != null) {
          final bearingChange = maneuver.bearingAfter! - maneuver.bearingBefore!;
          // Normalize to -180 to 180
          final normalized = (bearingChange + 180) % 360 - 180;
          exitSide = normalized < 0 ? ExitSide.left : ExitSide.right;
        }
        return RouteInstruction.exit(
          distance: distance,
          side: exitSide,
          duration: duration,
          location: location,
          originalShapeIndex: maneuver.beginShapeIndex,
          streetName: streetName,
          instructionText: instructionText,
          postInstructionText: postInstructionText,
          verbalAlertInstruction: verbalAlertInstruction,
          verbalInstruction: verbalInstruction,
          verbalSuccinctInstruction: verbalSuccinctInstruction,
          verbalMultiCue: verbalMultiCue,
        );
      }
      // Pass all the extracted instruction fields to the creator
      return instructionCreator(distance, duration, location, maneuver.beginShapeIndex, streetName, instructionText, verbalAlertInstruction, verbalInstruction, verbalSuccinctInstruction, verbalMultiCue);
    }
    return RouteInstruction.other(
      distance: distance,
      duration: duration,
      location: location,
      originalShapeIndex: maneuver.beginShapeIndex,
      streetName: streetName,
      instructionText: instructionText,
      postInstructionText: postInstructionText,
      verbalAlertInstruction: verbalAlertInstruction,
      verbalInstruction: verbalInstruction,
      verbalSuccinctInstruction: verbalSuccinctInstruction,
      verbalMultiCue: verbalMultiCue,
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

}
