import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for roundabout exit icons
/// Draws a roundabout with entry/exit stubs, route arc, and directional arrow
/// Oriented based on the bearing before entering the roundabout
class RoundaboutIconPainter extends CustomPainter {
  final int exitNumber;
  final double? bearingBefore; // Degrees: 0=North, 90=East, 180=South, 270=West
  final bool isDark;
  final double size;

  RoundaboutIconPainter({
    required this.exitNumber,
    this.bearingBefore,
    required this.isDark,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = size.width * 0.27; // Slightly bigger circle
    final ringWidth = size.width * 0.08; // Thicker arc
    final stubLength = size.width * 0.15; // Short stubs for subdued exits
    final entryStubLength = size.width * 0.28; // Entry stub
    final exitStubLength = size.width * 0.34; // Exit stub (longer to compensate for arrow)
    final stubWidth = size.width * 0.1; // Slightly narrower stub body

    // Colors
    final subduedColor = isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3);
    final activeColor = isDark ? Colors.white : Colors.black87;

    // Since the map rotates in the direction of travel, the icon should always
    // show entry from the bottom (you're always traveling "up" on a rotating map)
    final entryAngle = math.pi / 2; // Always bottom (90° in canvas coords)

    // Calculate exit angle and sweep
    final (exitAngle, sweepAngle) = _calculateExitGeometry(exitNumber, entryAngle);

    // Draw subdued roundabout ring
    final subduedPaint = Paint()
      ..color = subduedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;

    canvas.drawCircle(center, ringRadius, subduedPaint);

    // Draw all exit stubs in subdued color
    for (int i = 1; i <= 4; i++) {
      final angle = entryAngle - (i * math.pi / 2);
      _drawStub(canvas, center, angle, ringRadius, stubLength, stubWidth, subduedColor);
    }

    // Draw active entry stub
    _drawStub(canvas, center, entryAngle, ringRadius, entryStubLength, stubWidth, activeColor);

    // Draw active route arc (from entry to exit around the roundabout)
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: ringRadius);
    canvas.drawArc(rect, entryAngle, sweepAngle, false, activePaint);

    // Draw active exit stub with integrated arrow end (longer to compensate for arrow transition)
    _drawStubWithArrow(canvas, center, exitAngle, ringRadius, exitStubLength, stubWidth, activeColor);
  }

  /// Convert bearing (degrees, 0=North) to canvas radians
  /// Bearing 0°=North, 90°=East, 180°=South, 270°=West
  /// Canvas: 0°=East/Right, 90°=South/Down, 180°=West/Left, 270°=North/Up
  double _bearingToRadians(double bearingDegrees) {
    // Convert bearing to canvas coordinates:
    // Bearing 0° (North) -> Canvas -90° (270°)
    // Bearing 90° (East) -> Canvas 0°
    // Bearing 180° (South) -> Canvas 90°
    // Bearing 270° (West) -> Canvas 180°
    final canvasDegrees = bearingDegrees - 90;
    return canvasDegrees * math.pi / 180;
  }

  /// Calculate exit angle and sweep angle based on exit number
  /// In right-hand traffic, you keep right going clockwise around the roundabout
  /// But in canvas coords, this means going COUNTER-clockwise (negative sweep)
  /// Returns the actual exit angle (normalized) and sweep angle from entry
  (double exitAngle, double sweepAngle) _calculateExitGeometry(int exit, double entryAngle) {
    // Each exit is approximately 90° apart
    // In right-hand traffic going around the circle, we go counter-clockwise in canvas coords
    // Exit 1 = -90° from entry (to the right), Exit 2 = -180°, Exit 3 = -270°, Exit 4 = -360°
    final sweepAngle = -exit * (math.pi / 2);

    // Calculate actual exit angle (normalize to 0-2π)
    var exitAngle = (entryAngle + sweepAngle) % (2 * math.pi);
    if (exitAngle < 0) {
      exitAngle += 2 * math.pi;
    }

    return (exitAngle, sweepAngle);
  }

  /// Draw a road stub extending from the roundabout
  void _drawStub(Canvas canvas, Offset center, double angle, double ringRadius,
      double stubLength, double stubWidth, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calculate stub start and end points
    final startDistance = ringRadius;
    final endDistance = ringRadius + stubLength;

    final start = Offset(
      center.dx + startDistance * math.cos(angle),
      center.dy + startDistance * math.sin(angle),
    );
    final end = Offset(
      center.dx + endDistance * math.cos(angle),
      center.dy + endDistance * math.sin(angle),
    );

    // Draw rectangle for stub
    final perpAngle = angle + math.pi / 2;
    final halfWidth = stubWidth / 2;

    final p1 = Offset(
      start.dx + halfWidth * math.cos(perpAngle),
      start.dy + halfWidth * math.sin(perpAngle),
    );
    final p2 = Offset(
      start.dx - halfWidth * math.cos(perpAngle),
      start.dy - halfWidth * math.sin(perpAngle),
    );
    final p3 = Offset(
      end.dx - halfWidth * math.cos(perpAngle),
      end.dy - halfWidth * math.sin(perpAngle),
    );
    final p4 = Offset(
      end.dx + halfWidth * math.cos(perpAngle),
      end.dy + halfWidth * math.sin(perpAngle),
    );

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p4.dx, p4.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  /// Draw a stub with an integrated arrow end (Material Design style)
  void _drawStubWithArrow(Canvas canvas, Offset center, double angle, double ringRadius,
      double stubLength, double stubWidth, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calculate stub start (at roundabout edge) and arrow transition point
    final startDistance = ringRadius;
    final arrowStartDistance = ringRadius + stubLength * 0.5; // Arrow starts halfway
    final arrowTipDistance = ringRadius + stubLength; // Arrow tip at full length

    final start = Offset(
      center.dx + startDistance * math.cos(angle),
      center.dy + startDistance * math.sin(angle),
    );
    final arrowStart = Offset(
      center.dx + arrowStartDistance * math.cos(angle),
      center.dy + arrowStartDistance * math.sin(angle),
    );
    final arrowTip = Offset(
      center.dx + arrowTipDistance * math.cos(angle),
      center.dy + arrowTipDistance * math.sin(angle),
    );

    final perpAngle = angle + math.pi / 2;
    final halfStubWidth = stubWidth / 2;
    final halfArrowWidth = stubWidth * 1.3; // Prominent wings like Material Design

    // Build path: rectangle for stub body, then triangle for arrow
    final path = Path();

    // Stub left edge
    final stubLeft1 = Offset(
      start.dx + halfStubWidth * math.cos(perpAngle),
      start.dy + halfStubWidth * math.sin(perpAngle),
    );
    final stubLeft2 = Offset(
      arrowStart.dx + halfStubWidth * math.cos(perpAngle),
      arrowStart.dy + halfStubWidth * math.sin(perpAngle),
    );

    // Stub right edge
    final stubRight1 = Offset(
      start.dx - halfStubWidth * math.cos(perpAngle),
      start.dy - halfStubWidth * math.sin(perpAngle),
    );
    final stubRight2 = Offset(
      arrowStart.dx - halfStubWidth * math.cos(perpAngle),
      arrowStart.dy - halfStubWidth * math.sin(perpAngle),
    );

    // Arrow wings
    final arrowLeft = Offset(
      arrowStart.dx + halfArrowWidth * math.cos(perpAngle),
      arrowStart.dy + halfArrowWidth * math.sin(perpAngle),
    );
    final arrowRight = Offset(
      arrowStart.dx - halfArrowWidth * math.cos(perpAngle),
      arrowStart.dy - halfArrowWidth * math.sin(perpAngle),
    );

    // Draw combined stub + arrow shape
    path.moveTo(stubLeft1.dx, stubLeft1.dy);
    path.lineTo(stubLeft2.dx, stubLeft2.dy);
    path.lineTo(arrowLeft.dx, arrowLeft.dy);
    path.lineTo(arrowTip.dx, arrowTip.dy);
    path.lineTo(arrowRight.dx, arrowRight.dy);
    path.lineTo(stubRight2.dx, stubRight2.dy);
    path.lineTo(stubRight1.dx, stubRight1.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RoundaboutIconPainter oldDelegate) {
    return oldDelegate.exitNumber != exitNumber ||
        oldDelegate.bearingBefore != bearingBefore ||
        oldDelegate.isDark != isDark ||
        oldDelegate.size != size;
  }
}
