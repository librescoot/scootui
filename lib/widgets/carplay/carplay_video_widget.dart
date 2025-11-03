import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/carplay_cubit.dart';
import 'mjpeg_stream_widget.dart';

class CarPlayVideoWidget extends StatelessWidget {
  const CarPlayVideoWidget({
    super.key,
  });

  // CarPlay resolution constants
  static const double carPlayWidth = 800.0;
  static const double carPlayHeight = 480.0;
  static const double aspectRatio = carPlayWidth / carPlayHeight;

  // Touch action constants
  static const int touchDown = 14;
  static const int touchMove = 15;
  static const int touchUp = 16;

  @override
  Widget build(BuildContext context) {
    final streamUrl = context.read<CarPlayCubit>().streamUrl;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => _handleTouchDown(context, details.localPosition, constraints),
          onTapUp: (details) => _handleTouchUp(context, details.localPosition, constraints),
          onPanStart: (details) => _handleTouchDown(context, details.localPosition, constraints),
          onPanUpdate: (details) => _handleTouchMove(context, details.localPosition, constraints),
          onPanEnd: (details) => _handleTouchUpFromPan(context, constraints),
          child: Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: RepaintBoundary(
                  child: MjpegStreamWidget(streamUrl: streamUrl),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTouchDown(BuildContext context, Offset localPosition, BoxConstraints constraints) {
    final carplayCoords = _convertToCarPlayCoordinates(localPosition, constraints);
    if (carplayCoords != null) {
      context.read<CarPlayCubit>().sendTouchEvent(
            carplayCoords.dx,
            carplayCoords.dy,
            touchDown,
          );
    }
  }

  void _handleTouchMove(BuildContext context, Offset localPosition, BoxConstraints constraints) {
    final carplayCoords = _convertToCarPlayCoordinates(localPosition, constraints);
    if (carplayCoords != null) {
      context.read<CarPlayCubit>().sendTouchEvent(
            carplayCoords.dx,
            carplayCoords.dy,
            touchMove,
          );
    }
  }

  void _handleTouchUp(BuildContext context, Offset localPosition, BoxConstraints constraints) {
    final carplayCoords = _convertToCarPlayCoordinates(localPosition, constraints);
    if (carplayCoords != null) {
      context.read<CarPlayCubit>().sendTouchEvent(
            carplayCoords.dx,
            carplayCoords.dy,
            touchUp,
          );
    }
  }

  void _handleTouchUpFromPan(BuildContext context, BoxConstraints constraints) {
    // For pan end, we don't have a position, so send center or last known position
    // In practice, the backend might not care about the exact coordinates for touch up
    context.read<CarPlayCubit>().sendTouchEvent(
          carPlayWidth / 2,
          carPlayHeight / 2,
          touchUp,
        );
  }

  /// Convert local touch coordinates to CarPlay coordinate space (0-800, 0-480)
  Offset? _convertToCarPlayCoordinates(Offset localPosition, BoxConstraints constraints) {
    // Calculate the actual size of the video widget
    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;

    // Calculate the actual video display size (respecting aspect ratio)
    double videoWidth, videoHeight, offsetX, offsetY;

    final containerAspectRatio = containerWidth / containerHeight;

    if (containerAspectRatio > aspectRatio) {
      // Container is wider than video - video is limited by height
      videoHeight = containerHeight;
      videoWidth = videoHeight * aspectRatio;
      offsetX = (containerWidth - videoWidth) / 2;
      offsetY = 0;
    } else {
      // Container is taller than video - video is limited by width
      videoWidth = containerWidth;
      videoHeight = videoWidth / aspectRatio;
      offsetX = 0;
      offsetY = (containerHeight - videoHeight) / 2;
    }

    // Check if touch is within the video bounds
    final relativeX = localPosition.dx - offsetX;
    final relativeY = localPosition.dy - offsetY;

    if (relativeX < 0 || relativeX > videoWidth || relativeY < 0 || relativeY > videoHeight) {
      // Touch is outside the video area
      return null;
    }

    // Convert to CarPlay coordinates
    final carplayX = (relativeX / videoWidth) * carPlayWidth;
    final carplayY = (relativeY / videoHeight) * carPlayHeight;

    return Offset(carplayX, carplayY);
  }
}
