import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';

class RouteMatchIllustration extends StatelessWidget {
  const RouteMatchIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: CustomPaint(
        painter: _RouteMatchPainter(),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '92% match',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteMatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = AppColors.surfaceMuted
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    final linePaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * 0.08, size.height * 0.82);
    final end = Offset(size.width * 0.92, size.height * 0.18);

    canvas.drawLine(start, end, trackPaint);
    canvas.drawLine(start, end, linePaint);

    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(start, 6, dotPaint);

    final endCap = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(end.dx, end.dy - 8),
      Offset(end.dx, end.dy + 8),
      endCap,
    );

    final carCenter = Offset(size.width * 0.28, size.height * 0.62);
    _drawCar(canvas, carCenter);

    final bikeCenter = Offset(size.width * 0.72, size.height * 0.34);
    _drawBike(canvas, bikeCenter);
  }

  void _drawCar(Canvas canvas, Offset center) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 34, height: 18),
      const Radius.circular(8),
    );
    canvas.drawRRect(body, Paint()..color = AppColors.primary);
    canvas.drawCircle(
      Offset(center.dx - 8, center.dy + 10),
      4,
      Paint()..color = AppColors.textPrimary,
    );
    canvas.drawCircle(
      Offset(center.dx + 8, center.dy + 10),
      4,
      Paint()..color = AppColors.textPrimary,
    );
  }

  void _drawBike(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = AppColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(center.dx - 8, center.dy + 6), 6, paint);
    canvas.drawCircle(Offset(center.dx + 8, center.dy + 6), 6, paint);
    canvas.drawLine(
      Offset(center.dx - 8, center.dy + 6),
      Offset(center.dx, center.dy - 6),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 6),
      Offset(center.dx + 8, center.dy + 6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
