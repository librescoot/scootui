import 'package:flutter/material.dart';

import 'poc_tile_data.dart';

/// A widget that renders a static, pre-processed map tile using a CustomPainter.
class PocMapRenderer extends StatelessWidget {
  final bool isDarkTheme;

  const PocMapRenderer({super.key, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    // The CustomPaint widget is the core of our renderer. It's highly efficient.
    return CustomPaint(
      painter: _MapTilePainter(
        isDarkTheme: isDarkTheme,
        commands: PocTileData.commands,
      ),
      // We use a SizedBox to give our painter a specific size.
      child: const SizedBox.expand(),
    );
  }
}

/// The actual painter class that draws our pre-processed tile data onto the canvas.
class _MapTilePainter extends CustomPainter {
  final bool isDarkTheme;
  final List<PocDrawCommand> commands;

  /// In a real implementation, these palettes would be generated from the
  /// theme JSON files by the offline tool and could be more complex.
  static final Map<int, Paint> _lightThemePaints = {
    PocTileData.greenSpaceStyleId: Paint()..color = const Color(0xFFE0F0E0),
    PocTileData.waterStyleId: Paint()..color = const Color(0xFFA0C0F0),
    PocTileData.houseStyleId: Paint()..color = const Color(0xFFD0B0A0),
    PocTileData.primaryRoadStyleId: Paint()..color = const Color(0xFFFFFFFF),
    PocTileData.secondaryRoadStyleId: Paint()..color = const Color(0xFFF0F0F0),
  };

  static final Map<int, Paint> _darkThemePaints = {
    PocTileData.greenSpaceStyleId: Paint()..color = const Color(0xFF2C382C),
    PocTileData.waterStyleId: Paint()..color = const Color(0xFF1A2D4A),
    PocTileData.houseStyleId: Paint()..color = const Color(0xFF4A3C32),
    PocTileData.primaryRoadStyleId: Paint()..color = const Color(0xFF3D3D3D),
    PocTileData.secondaryRoadStyleId: Paint()..color = const Color(0xFF2E2E2E),
  };

  _MapTilePainter({required this.isDarkTheme, required this.commands});

  @override
  void paint(Canvas canvas, Size size) {
    // Select the correct theme palette.
    final theme = isDarkTheme ? _darkThemePaints : _lightThemePaints;

    // Scale the canvas to fit our 256x256 tile into the available space.
    final scale = size.width / 256.0;
    canvas.scale(scale);

    // This is the core rendering loop. It's designed to be as fast as possible.
    for (final command in commands) {
      // 1. Fast lookup to get the correct paint style.
      final paint = theme[command.styleId];
      if (paint == null) continue;

      // 2. Set stroke width if applicable.
      if (command.strokeWidth != null) {
        paint.strokeWidth = command.strokeWidth!;
        paint.style = PaintingStyle.stroke;
      } else {
        paint.style = PaintingStyle.fill;
      }

      // 3. Draw the primitive.
      final path = Path();
      path.addPolygon(command.points, command.type == PocDrawingType.polygon);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_MapTilePainter oldDelegate) {
    // We only need to repaint if the theme changes.
    return oldDelegate.isDarkTheme != isDarkTheme;
  }
}
