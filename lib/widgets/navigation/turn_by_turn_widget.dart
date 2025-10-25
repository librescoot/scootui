import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/navigation_cubit.dart';
import '../../cubits/navigation_state.dart';
import '../../routing/models.dart';
import 'roundabout_icon_painter.dart';

class TurnByTurnWidget extends StatelessWidget {
  final bool compact;
  final EdgeInsets? padding;

  const TurnByTurnWidget({
    super.key,
    this.compact = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        // Only show if we have instructions and navigation is active
        if (!state.hasInstructions || state.status != NavigationStatus.navigating) {
          return const SizedBox.shrink();
        }

        // Return the two-box layout directly, no wrapper
        return compact ? _buildCompactView(state, isDark) : _buildFullView(state, isDark);
      },
    );
  }

  Widget _buildDestinationAddressBar(NavigationState state, bool isDark) {
    final route = state.route;
    if (route == null || state.upcomingInstructions.isEmpty) return const SizedBox.shrink();

    final upcomingInstructions = state.upcomingInstructions;
    final firstUpcomingIndex = route.instructions.indexWhere(
      (inst) => inst.originalShapeIndex == upcomingInstructions.first.originalShapeIndex,
    );

    double remainingDistance = 0.0;
    Duration timeRemaining = Duration.zero;

    if (firstUpcomingIndex >= 0) {
      final firstUpcoming = upcomingInstructions.first;
      final firstOriginal = route.instructions[firstUpcomingIndex];

      remainingDistance = firstUpcoming.distance;
      remainingDistance += firstOriginal.distance;

      for (int i = firstUpcomingIndex + 1; i < route.instructions.length; i++) {
        remainingDistance += route.instructions[i].distance;
        timeRemaining += route.instructions[i].duration;
      }

      if (firstOriginal.distance > 0) {
        final speedInSegment = firstOriginal.distance > 0
            ? firstOriginal.duration.inSeconds / firstOriginal.distance
            : 0.0;
        final timeToFirstManeuver = Duration(seconds: (firstUpcoming.distance * speedInSegment).round());
        timeRemaining = timeToFirstManeuver + firstOriginal.duration + timeRemaining;
      } else {
        timeRemaining += firstOriginal.duration;
      }
    }

    final now = DateTime.now();
    final eta = now.add(timeRemaining);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.place,
            size: 14,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _AutoScrollText(
              text: state.destinationAddress!,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildTimeInfoItem(
            icon: Icons.straighten,
            label: 'Distance',
            value: _formatDistanceKm(remainingDistance),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildTimeInfoItem(
            icon: Icons.timer,
            label: 'Remaining',
            value: _formatDuration(timeRemaining),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildTimeInfoItem(
            icon: Icons.flag,
            label: 'ETA',
            value: _formatTime(eta),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTimeInfoBar(NavigationState state, bool isDark) {
    final route = state.route;
    if (route == null || state.upcomingInstructions.isEmpty) return const SizedBox.shrink();

    final upcomingInstructions = state.upcomingInstructions;
    final firstUpcomingIndex = route.instructions.indexWhere(
      (inst) => inst.originalShapeIndex == upcomingInstructions.first.originalShapeIndex,
    );

    double remainingDistance = 0.0;
    Duration timeRemaining = Duration.zero;

    if (firstUpcomingIndex >= 0) {
      final firstUpcoming = upcomingInstructions.first;
      final firstOriginal = route.instructions[firstUpcomingIndex];

      remainingDistance = firstUpcoming.distance;
      remainingDistance += firstOriginal.distance;

      for (int i = firstUpcomingIndex + 1; i < route.instructions.length; i++) {
        remainingDistance += route.instructions[i].distance;
        timeRemaining += route.instructions[i].duration;
      }

      if (firstOriginal.distance > 0) {
        final speedInSegment = firstOriginal.distance > 0
            ? firstOriginal.duration.inSeconds / firstOriginal.distance
            : 0.0;
        final timeToFirstManeuver = Duration(seconds: (firstUpcoming.distance * speedInSegment).round());
        timeRemaining = timeToFirstManeuver + firstOriginal.duration + timeRemaining;
      } else {
        timeRemaining += firstOriginal.duration;
      }
    }

    final now = DateTime.now();
    final eta = now.add(timeRemaining);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.95) : Colors.white.withOpacity(0.98),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1.0,
          ),
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeInfoItem(
            icon: Icons.straighten,
            label: 'Distance',
            value: _formatDistanceKm(remainingDistance),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildTimeInfoItem(
            icon: Icons.timer,
            label: 'Remaining',
            value: _formatDuration(timeRemaining),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildTimeInfoItem(
            icon: Icons.flag,
            label: 'ETA',
            value: _formatTime(eta),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfoBar(NavigationState state, bool isDark) {
    final route = state.route;
    if (route == null || state.upcomingInstructions.isEmpty) return const SizedBox.shrink();

    final upcomingInstructions = state.upcomingInstructions;
    final firstUpcomingIndex = route.instructions.indexWhere(
      (inst) => inst.originalShapeIndex == upcomingInstructions.first.originalShapeIndex,
    );

    double remainingDistance = 0.0;
    Duration timeRemaining = Duration.zero;

    if (firstUpcomingIndex >= 0) {
      final firstUpcoming = upcomingInstructions.first;
      final firstOriginal = route.instructions[firstUpcomingIndex];

      // Start with distance to the first instruction's maneuver point
      remainingDistance = firstUpcoming.distance;

      // Add the segment starting at that maneuver point
      remainingDistance += firstOriginal.distance;

      // Add all subsequent segments
      for (int i = firstUpcomingIndex + 1; i < route.instructions.length; i++) {
        remainingDistance += route.instructions[i].distance;
        timeRemaining += route.instructions[i].duration;
      }

      // Calculate time remaining: adjust first instruction's time based on progress
      if (firstOriginal.distance > 0) {
        // Estimate time to first maneuver (assume same speed as first segment)
        final speedInSegment = firstOriginal.distance > 0
            ? firstOriginal.duration.inSeconds / firstOriginal.distance
            : 0.0;
        final timeToFirstManeuver = Duration(seconds: (firstUpcoming.distance * speedInSegment).round());

        // Total time = time to first maneuver + duration of first segment + subsequent segments
        timeRemaining = timeToFirstManeuver + firstOriginal.duration + timeRemaining;
      } else {
        timeRemaining += firstOriginal.duration;
      }
    }

    // Calculate ETA
    final now = DateTime.now();
    final eta = now.add(timeRemaining);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withOpacity(0.95) : Colors.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Destination address (if available)
            if (state.destinationAddress != null && state.destinationAddress!.isNotEmpty) ...[
              Icon(
                Icons.place,
                size: 14,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: _AutoScrollText(
                  text: state.destinationAddress!,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            _buildTimeInfoItem(
              icon: Icons.straighten,
              label: 'Distance',
              value: _formatDistanceKm(remainingDistance),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildTimeInfoItem(
              icon: Icons.timer,
              label: 'Remaining',
              value: _formatDuration(timeRemaining),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildTimeInfoItem(
              icon: Icons.flag,
              label: 'ETA',
              value: _formatTime(eta),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  /// Determines which instruction to use for icon display, handling special cases like roundabout exits
  /// If the instruction is an Exit that's far from the exit point and there's a preceding Roundabout,
  /// returns the Roundabout instruction to keep showing the roundabout icon until close to the exit
  RouteInstruction _getInstructionForIcon(List<RouteInstruction> instructions) {
    if (instructions.isEmpty) return instructions.first;

    final first = instructions.first;

    // Special handling for Exit instructions (primarily roundabout exits)
    if (first is Exit && first.distance > 50.0) {
      // Look for a preceding Roundabout instruction in the list
      for (final inst in instructions) {
        if (inst is Roundabout) {
          // Found a roundabout - keep showing its icon until we're close to the exit
          return inst.copyWith(distance: first.distance);
        }
      }
    }

    return first;
  }

  Widget _buildCompactView(NavigationState state, bool isDark) {
    final instructions = state.upcomingInstructions;
    if (instructions.isEmpty) return const SizedBox.shrink();
    final instruction = instructions.first;
    final iconInstruction = _getInstructionForIcon(instructions);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact: icon above, distance below
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInstructionIcon(iconInstruction, size: 24, isDark: isDark),
            const SizedBox(height: 2),
            Text(
              _formatDistance(instruction.distance),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFullView(NavigationState state, bool isDark) {
    final instructions = state.upcomingInstructions;
    if (instructions.isEmpty) return const SizedBox.shrink();
    final instruction = instructions.first;
    final iconInstruction = _getInstructionForIcon(instructions);

    // Find next instruction that's not an exit (roundabout exits are confusing in preview)
    RouteInstruction? nextInstruction;
    if (instructions.length > 1) {
      try {
        nextInstruction = instructions.skip(1).firstWhere((inst) => inst is! Exit);
      } catch (e) {
        // All remaining instructions are exits, don't show preview
        nextInstruction = null;
      }
    }

    final hasAddress = state.destinationAddress != null && state.destinationAddress!.isNotEmpty;

    return Column(
      children: [
        // Full-width destination address bar (disabled for now)
        if (false && hasAddress) _buildDestinationAddressBar(state, isDark),

        // Turn-by-turn instruction box
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.95),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black12,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon box (shrink-wrapped)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.95) : Colors.white.withOpacity(0.98),
                    ),
                    child: _buildInstructionIcon(iconInstruction, size: 64, isDark: isDark),
                  ),
                  // Instruction text (expands to fill remaining space)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Distance indicator
                          Text(
                            _formatDistance(instruction.distance),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 15,
                              height: 1.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Main instruction text
                          Text(
                            _getInstructionText(instruction, null),
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 18,
                              fontWeight: isDark ? FontWeight.normal : FontWeight.w500,
                              height: 1.2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                            softWrap: true,
                          ),
                          // Next instruction preview
                          if (nextInstruction != null &&
                              nextInstruction.distance < 300 &&
                              !_hasMultiCueHint(instruction)) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Then ${_getShortInstructionText(nextInstruction)}',
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black45,
                                fontSize: 14,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Compact time info bar (always show in corner)
            Positioned(
              right: 0,
              top: 0,
              child: _buildCompactTimeInfoBar(state, isDark),
            ),
          ],
        ),
      ],
    );
  }

  /// Determines the distance threshold (in meters) at which to show the actual maneuver icon
  /// Different maneuver types have different thresholds based on their complexity and importance
  /// Below these thresholds, the actual maneuver icon is shown; above them, a straight arrow
  double _getIconDisplayThreshold(RouteInstruction instruction) {
    return switch (instruction) {
      Turn(direction: TurnDirection.uTurn180) ||
      Turn(direction: TurnDirection.uTurn) ||
      Turn(direction: TurnDirection.rightUTurn) => 600.0,
      Turn(direction: TurnDirection.sharpLeft) ||
      Turn(direction: TurnDirection.sharpRight) ||
      Roundabout() => 500.0,
      Turn(direction: TurnDirection.left) ||
      Turn(direction: TurnDirection.right) ||
      Exit() => 400.0,
      Turn(direction: TurnDirection.slightLeft) ||
      Turn(direction: TurnDirection.slightRight) ||
      Merge() => 300.0,
      Keep() => 150.0,
      Other() => 1000.0,
    };
  }

  Widget _buildInstructionIcon(RouteInstruction instruction, {required double size, required bool isDark}) {
    IconData iconData;
    Color iconColor = isDark ? Colors.white : Colors.black87;

    // Check if we should show the maneuver icon based on distance and instruction type
    final threshold = _getIconDisplayThreshold(instruction);
    if (instruction.distance > threshold) {
      iconData = Icons.straight;
    } else {
      switch (instruction) {
        case Keep(direction: final direction):
          iconData = switch (direction) {
            KeepDirection.straight => Icons.straight,
            KeepDirection.left => Icons.turn_slight_left,
            KeepDirection.right => Icons.turn_slight_right,
          };
          break;
        case Turn(direction: final direction):
          iconData = switch (direction) {
            TurnDirection.left => Icons.turn_left,
            TurnDirection.right => Icons.turn_right,
            TurnDirection.slightLeft => Icons.turn_slight_left,
            TurnDirection.slightRight => Icons.turn_slight_right,
            TurnDirection.sharpLeft => Icons.turn_sharp_left,
            TurnDirection.sharpRight => Icons.turn_sharp_right,
            TurnDirection.uTurn180 || TurnDirection.uTurn => Icons.u_turn_left,
            TurnDirection.rightUTurn => Icons.u_turn_right,
          };
          break;
        case Roundabout(side: final side, exitNumber: final exitNumber, bearingBefore: final bearingBefore):
          // Handle roundabout with custom widget below
          return _buildRoundaboutIcon(side, exitNumber, bearingBefore, size, isDark);
        case Exit(side: final side):
          // Use turn icons for exits (primarily roundabout exits)
          iconData = side == ExitSide.left ? Icons.turn_slight_left : Icons.turn_slight_right;
          break;
        case Merge(direction: final direction):
          // Use merge icon, can rotate for directional merge if needed
          iconData = switch (direction) {
            MergeDirection.straight => Icons.merge,
            MergeDirection.left => Icons.merge, // Could add rotation if needed
            MergeDirection.right => Icons.merge,
          };
          break;
        case Other():
          iconData = Icons.navigation;
          break;
      }
    }

    return Icon(
      iconData,
      color: iconColor,
      size: size,
    );
  }

  String _formatDistance(double distance) {
    if (distance > 500) {
      return '${((((distance + 99) ~/ 100) * 100) / 1000).toStringAsFixed(1)} km';
    } else if (distance > 100) {
      return '${(((distance + 99) ~/ 100) * 100)} m';
    } else if (distance > 10) {
      return '${(((distance + 9) ~/ 10) * 10)} m';
    } else {
      return '${distance.toInt()} m';
    }
  }

  String _formatDistanceKm(double distance) {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    } else {
      return '${distance.toInt()} m';
    }
  }

  /// Checks if the instruction has the verbalMultiCue flag set
  /// When true, Valhalla's succinct instruction already includes the next maneuver
  bool _hasMultiCueHint(RouteInstruction instruction) {
    return switch (instruction) {
      Keep(verbalMultiCue: final multiCue) => multiCue,
      Turn(verbalMultiCue: final multiCue) => multiCue,
      Exit(verbalMultiCue: final multiCue) => multiCue,
      Merge(verbalMultiCue: final multiCue) => multiCue,
      Roundabout(verbalMultiCue: final multiCue) => multiCue,
      Other(verbalMultiCue: final multiCue) => multiCue,
    };
  }

  String _getInstructionText(RouteInstruction instruction, [RouteInstruction? nextInstruction]) {
    // For very long distances (>=1km), show "Continue for X.X km" message
    // Use same rounding as _formatDistance to ensure consistency
    if (instruction.distance >= 1000) {
      final roundedDistance = (((instruction.distance + 99) ~/ 100) * 100) / 1000;
      final distanceKm = roundedDistance.toStringAsFixed(1);
      return 'Continue for $distanceKm km';
    }

    String baseText = '';

    // Select verbal instruction based on distance according to Valhalla best practices:
    // - Alert (> 300m): "Turn right onto Anna-Louisa-Karsch-Straße" - prepares for upcoming maneuver
    // - Pre (50-300m): "Turn right onto Anna-Louisa-Karsch-Straße" - immediately prior to maneuver
    // - Succinct (< 50m): "Turn right" - abbreviated for immediate action
    // Note: Distance is already shown separately in the icon box, so we don't repeat it in text
    if (instruction.distance > 300) {
      // Use alert instruction - prepares user for upcoming maneuver
      baseText = switch (instruction) {
        Keep(verbalAlertInstruction: final alert) => alert ?? '',
        Turn(verbalAlertInstruction: final alert) => alert ?? '',
        Exit(verbalAlertInstruction: final alert) => alert ?? '',
        Merge(verbalAlertInstruction: final alert) => alert ?? '',
        Roundabout(verbalAlertInstruction: final alert) => alert ?? '',
        Other(verbalAlertInstruction: final alert) => alert ?? '',
      };
    } else if (instruction.distance >= 50) {
      // Use pre-transition instruction - immediately prior to maneuver
      baseText = switch (instruction) {
        Keep(verbalInstruction: final verbal) => verbal ?? '',
        Turn(verbalInstruction: final verbal) => verbal ?? '',
        Exit(verbalInstruction: final verbal) => verbal ?? '',
        Merge(verbalInstruction: final verbal) => verbal ?? '',
        Roundabout(verbalInstruction: final verbal) => verbal ?? '',
        Other(verbalInstruction: final verbal) => verbal ?? '',
      };
    } else {
      // Use succinct instruction - abbreviated for immediate action
      baseText = switch (instruction) {
        Keep(verbalSuccinctInstruction: final succinct) => succinct ?? '',
        Turn(verbalSuccinctInstruction: final succinct) => succinct ?? '',
        Exit(verbalSuccinctInstruction: final succinct) => succinct ?? '',
        Merge(verbalSuccinctInstruction: final succinct) => succinct ?? '',
        Roundabout(verbalSuccinctInstruction: final succinct) => succinct ?? '',
        Other(verbalSuccinctInstruction: final succinct) => succinct ?? '',
      };
    }

    // Fall back to pre-transition if succinct not available (for < 50m case)
    if (baseText.isEmpty && instruction.distance < 50) {
      baseText = switch (instruction) {
        Keep(verbalInstruction: final verbal) => verbal ?? '',
        Turn(verbalInstruction: final verbal) => verbal ?? '',
        Exit(verbalInstruction: final verbal) => verbal ?? '',
        Merge(verbalInstruction: final verbal) => verbal ?? '',
        Roundabout(verbalInstruction: final verbal) => verbal ?? '',
        Other(verbalInstruction: final verbal) => verbal ?? '',
      };
    }

    // Fall back to regular instruction text if verbal instructions aren't available
    if (baseText.isEmpty) {
      baseText = instruction.instructionText ?? '';
    }

    // If still empty, generate a fallback
    if (baseText.isEmpty) {
      baseText = switch (instruction) {
        Keep(direction: final direction, streetName: final streetName) =>
          streetName != null ? 'Keep ${direction.name} on $streetName' : 'Keep ${direction.name}',
        Turn(direction: final direction, streetName: final streetName) =>
          streetName != null ? 'Turn ${direction.name} onto $streetName' : 'Turn ${direction.name}',
        Roundabout(exitNumber: final exitNumber, streetName: final streetName) =>
          streetName != null ? 'Take exit $exitNumber onto $streetName' : 'Take exit $exitNumber',
        Exit(side: final side, streetName: final streetName) =>
          streetName != null ? 'Take the ${side.name} exit to $streetName' : 'Take the ${side.name} exit',
        Merge(direction: final direction, streetName: final streetName) =>
          streetName != null ? 'Merge ${direction.name} onto $streetName' : 'Merge ${direction.name}',
        Other(streetName: final streetName) => streetName != null ? 'Continue on $streetName' : 'Continue',
      };
    }

    return baseText;
  }

  String _getShortInstructionText(RouteInstruction instruction) {
    // Generate short instruction text for "then" clauses
    return switch (instruction) {
      Keep(direction: final direction) => switch (direction) {
          KeepDirection.straight => 'continue straight',
          _ => 'keep ${direction.name}',
        },
      Turn(direction: final direction) => switch (direction) {
          TurnDirection.left => 'turn left',
          TurnDirection.right => 'turn right',
          TurnDirection.slightLeft => 'turn slightly left',
          TurnDirection.slightRight => 'turn slightly right',
          TurnDirection.sharpLeft => 'turn sharply left',
          TurnDirection.sharpRight => 'turn sharply right',
          TurnDirection.uTurn180 => 'make a U-turn',
          TurnDirection.rightUTurn => 'make a right U-turn',
          TurnDirection.uTurn => 'make a U-turn',
        },
      Roundabout(exitNumber: final exitNumber) => _getOrdinalExitText(exitNumber),
      Merge(direction: final direction) => switch (direction) {
          MergeDirection.straight => 'merge',
          MergeDirection.left => 'merge left',
          MergeDirection.right => 'merge right',
        },
      Other() => 'continue',
      Exit(side: final side) => 'take the ${side.name} exit',
    };
  }

  String _getOrdinalExitText(int exitNumber) {
    // Handle ordinal suffixes for any exit number
    final suffix = switch (exitNumber % 10) {
      1 when exitNumber % 100 != 11 => 'st',
      2 when exitNumber % 100 != 12 => 'nd',
      3 when exitNumber % 100 != 13 => 'rd',
      _ => 'th',
    };
    return 'take the $exitNumber$suffix exit';
  }

  Widget _buildRoundaboutIcon(RoundaboutSide side, int exitNumber, double? bearingBefore, double size, bool isDark) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RoundaboutIconPainter(
          exitNumber: exitNumber,
          bearingBefore: bearingBefore,
          isDark: isDark,
          size: size,
        ),
      ),
    );
  }
}

class _AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _AutoScrollText({
    required this.text,
    required this.style,
  });

  @override
  State<_AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<_AutoScrollText> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  @override
  void didUpdateWidget(_AutoScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _scrollController.jumpTo(0);
      _isScrolling = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
    }
  }

  void _startAutoScroll() async {
    if (!mounted || _isScrolling) return;

    // Wait a bit to ensure the text is rendered
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Check if text overflows
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    if (maxScrollExtent <= 0) return;

    _isScrolling = true;

    while (mounted && _isScrolling) {
      // Pause at start
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_isScrolling) break;

      // Scroll to end
      await _scrollController.animateTo(
        maxScrollExtent,
        duration: Duration(milliseconds: (maxScrollExtent * 20).toInt()),
        curve: Curves.linear,
      );
      if (!mounted || !_isScrolling) break;

      // Pause at end
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_isScrolling) break;

      // Scroll back to start
      await _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: (maxScrollExtent * 20).toInt()),
        curve: Curves.linear,
      );
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
      ),
    );
  }
}
