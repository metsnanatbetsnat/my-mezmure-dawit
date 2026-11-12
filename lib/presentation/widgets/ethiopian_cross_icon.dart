import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A custom painted Ethiopian Orthodox Cross (መስቀል) icon
/// adhering to the Lalibela and Gondar geometric manuscript traditions.
class EthiopianCrossIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const EthiopianCrossIcon({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.goldMuted
            : AppColors.navyPrimary);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EthiopianCrossPainter(color: effectiveColor),
      ),
    );
  }
}

class _EthiopianCrossPainter extends CustomPainter {
  final Color color;

  _EthiopianCrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;

    // Central cross body
    final double barWidth = w * 0.16;
    final double armLength = w * 0.42;

    // Vertical shaft
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: barWidth, height: armLength * 2),
        const Radius.circular(2),
      ),
      paint,
    );

    // Horizontal beam
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: armLength * 2, height: barWidth),
        const Radius.circular(2),
      ),
      paint,
    );

    // 4 Traditional flared finials / diamond trefoils on each cross extremity
    final finials = [
      Offset(center.dx, center.dy - armLength), // top
      Offset(center.dx, center.dy + armLength), // bottom
      Offset(center.dx - armLength, center.dy), // left
      Offset(center.dx + armLength, center.dy), // right
    ];

    for (final pt in finials) {
      canvas.drawCircle(pt, barWidth * 0.8, paint);
    }

    // Traditional Gondar manuscript diamond center window
    final diamond = Path()
      ..moveTo(center.dx, center.dy - barWidth * 0.7)
      ..lineTo(center.dx + barWidth * 0.7, center.dy)
      ..lineTo(center.dx, center.dy + barWidth * 0.7)
      ..lineTo(center.dx - barWidth * 0.7, center.dy)
      ..close();

    canvas.drawPath(
      diamond,
      Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(diamond, outline);
  }

  @override
  bool shouldRepaint(covariant _EthiopianCrossPainter oldDelegate) =>
      oldDelegate.color != color;
}
