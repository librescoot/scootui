import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../cubits/navigation_cubit.dart';

class SpeedLimitIndicator extends StatelessWidget {
  final double iconSize;
  final Color? iconColor;

  const SpeedLimitIndicator({
    super.key,
    this.iconSize = 36,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final speedLimit = context.select((NavigationCubit c) => c.state.currentSpeedLimit);

    // Don't show anything if there's no speed limit data
    if (speedLimit == null || speedLimit.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use the blank template with custom text overlay
    return Stack(
      alignment: Alignment.center,
      children: [
        // Base icon
        SvgPicture.asset(
          'assets/icons/speedlimit_blank.svg',
          width: iconSize,
          height: iconSize,
          colorFilter: iconColor != null ? ColorFilter.mode(iconColor!, BlendMode.srcIn) : null,
        ),

        // Text overlay
        // Scale font size proportionally to the icon size (64pt at 144px)
        Text(
          speedLimit,
          style: GoogleFonts.robotoCondensed(
            fontWeight: FontWeight.bold,
            fontSize: iconSize * (64 / 144), // Scale proportionally
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class RoadNameDisplay extends StatelessWidget {
  final TextStyle? textStyle;

  const RoadNameDisplay({
    super.key,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final roadName = context.select((NavigationCubit c) => c.state.currentStreetName);
    final roadType = context.select((NavigationCubit c) => c.state.currentRoadType);

    // Don't show anything if there's no road name
    if (roadName == null || roadName.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get styling based on German road sign standards for different road types
    final (Color bgColor, Color textColor, BoxBorder? border) = _getRoadSignStyle(roadType ?? '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: border,
      ),
      child: Text(
        roadName,
        style: (textStyle ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  /// Returns styling based on German road sign standards
  (Color, Color, BoxBorder?) _getRoadSignStyle(String roadType) {
    switch (roadType.toLowerCase()) {
      case 'motorway':
      case 'trunk':
        // Autobahn - Blue with white text
        return (Colors.blue.shade800, Colors.white, null);

      case 'primary':
        // Federal roads (Bundesstraße) - Yellow with black text
        return (Colors.amber.shade600, Colors.black, null);

      case 'secondary':
        // State roads (Landstraße) - White with black text and thin border
        return (Colors.white, Colors.black, Border.all(color: Colors.black54, width: 1));

      case 'tertiary':
        // County roads (Kreisstraße) - White with black text
        return (Colors.white, Colors.black, Border.all(color: Colors.black38, width: 0.5));

      case 'residential':
      case 'living_street':
        // Residential - Light gray with black text
        return (Colors.grey.shade200, Colors.black87, null);

      default:
        // Default style for other road types
        return (Colors.grey.shade100, Colors.black87, Border.all(color: Colors.grey.shade400, width: 0.5));
    }
  }
}
