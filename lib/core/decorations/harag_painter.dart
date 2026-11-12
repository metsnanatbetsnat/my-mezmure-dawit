import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A custom painter that draws traditional Ethiopian manuscript Harag (ሐረግ)
/// interlaced cross and ribbon patterns used in Orthodox manuscripts.
class HaragPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final bool showCentralCross;

  HaragPainter({
    this.primaryColor = AppColors.goldMuted,
    this.secondaryColor = AppColors.manuscriptCrimson,
    this.showCentralCross = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final crimsonPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final goldFillPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final double midY = size.height / 2;
    final double midX = size.width / 2;

    // Draw top and bottom thin ornamental framing lines
    canvas.drawLine(Offset(10, midY - 6), Offset(size.width - 10, midY - 6), goldPaint..strokeWidth = 1.0);
    canvas.drawLine(Offset(10, midY + 6), Offset(size.width - 10, midY + 6), goldPaint..strokeWidth = 1.0);

    // Draw Ethiopian manuscript repeating interlace knot diamonds
    const double step = 24.0;
    final int count = ((size.width - 60) / step).floor();
    final double startX = (size.width - (count * step)) / 2;

    for (int i = 0; i < count; i++) {
      final double x = startX + (i * step);
      // Skip center if cross is shown
      if (showCentralCross && (x - midX).abs() < 18) continue;

      final Path diamond = Path()
        ..moveTo(x, midY - 6)
        ..lineTo(x + 6, midY)
        ..lineTo(x, midY + 6)
        ..lineTo(x - 6, midY)
        ..close();

      if (i % 2 == 0) {
        canvas.drawPath(diamond, crimsonPaint);
      } else {
        canvas.drawPath(diamond, goldFillPaint);
      }
    }

    // Draw central Ethiopian Cross knot if enabled
    if (showCentralCross) {
      _drawEthiopianCrossKnot(canvas, Offset(midX, midY), primaryColor, secondaryColor);
    }

    // Left and right finials
    _drawFinial(canvas, Offset(10, midY), true, primaryColor, secondaryColor);
    _drawFinial(canvas, Offset(size.width - 10, midY), false, primaryColor, secondaryColor);
  }

  void _drawEthiopianCrossKnot(Canvas canvas, Offset center, Color gold, Color crimson) {
    final crossPaint = Paint()
      ..color = crimson
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double r = 7.0;

    // Center square
    final Rect centerRect = Rect.fromCenter(center: center, width: r * 1.5, height: r * 1.5);
    canvas.drawRect(centerRect, crossPaint);
    canvas.drawRect(centerRect, outlinePaint);

    // 4 Cross arms
    final List<Offset> points = [
      Offset(center.dx, center.dy - r * 1.5),
      Offset(center.dx + r * 1.5, center.dy),
      Offset(center.dx, center.dy + r * 1.5),
      Offset(center.dx - r * 1.5, center.dy),
    ];

    for (final pt in points) {
      canvas.drawCircle(pt, 2.5, Paint()..color = gold);
    }
  }

  void _drawFinial(Canvas canvas, Offset pt, bool isLeft, Color gold, Color crimson) {
    final paint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;

    final dir = isLeft ? -1 : 1;
    final Path path = Path()
      ..moveTo(pt.dx, pt.dy - 5)
      ..lineTo(pt.dx + (dir * 8), pt.dy)
      ..lineTo(pt.dx, pt.dy + 5)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A ready-to-use widget for placing Ethiopian manuscript Harag ornamental dividers
class HaragDivider extends StatelessWidget {
  final double height;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool showCentralCross;

  const HaragDivider({
    super.key,
    this.height = 24.0,
    this.primaryColor,
    this.secondaryColor,
    this.showCentralCross = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = primaryColor ?? (isDark ? AppColors.goldMuted : AppColors.goldDark);
    final crimson = secondaryColor ?? (isDark ? AppColors.goldLight : AppColors.manuscriptCrimson);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: HaragPainter(
          primaryColor: gold,
          secondaryColor: crimson,
          showCentralCross: showCentralCross,
        ),
      ),
    );
  }
}
