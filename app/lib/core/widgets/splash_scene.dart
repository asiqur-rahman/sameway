import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sameway/core/constants/app_brand.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';

/// Wireframe v2 splash — 390×844 artboard scaled to screen.
class SplashScene extends StatelessWidget {
  const SplashScene({super.key});

  static const _artboardW = 390.0;
  static const _artboardH = 844.0;
  static const _bg = Color(0xFF040C07);
  static const _green = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        double sx(double x) => x / _artboardW * w;
        double sy(double y) => y / _artboardH * h;

        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: _bg),
            // Sky gradient — 175deg
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.12, -1),
                  end: Alignment(0.12, 1),
                  colors: [
                    Color(0xFF040C07),
                    Color(0xFF071510),
                    Color(0xFF0A1F14),
                    Color(0xFF0D2B1A),
                    Color(0xFF091A10),
                    Color(0xFF040C07),
                  ],
                  stops: [0.0, 0.2, 0.42, 0.58, 0.8, 1.0],
                ),
              ),
            ),
            // Dawn glow at 46%
            Positioned(
              left: -w * 0.1,
              right: -w * 0.1,
              top: h * 0.46,
              height: sy(180),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.85,
                    colors: [
                      _green.withValues(alpha: 0.094),
                      _green.withValues(alpha: 0.024),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 0.75],
                  ),
                ),
              ),
            ),
            // Stars + map illustration
            CustomPaint(
              size: Size(w, h),
              painter: _SplashIllustrationPainter(w: w, h: h),
            ),
            // Wordmark — top: 62
            Positioned(
              top: sy(62),
              left: 0,
              right: 0,
              child: _SplashWordmark(sx: sx, sy: sy),
            ),
          ],
        );
      },
    );
  }
}

class _SplashWordmark extends StatelessWidget {
  const _SplashWordmark({required this.sx, required this.sy});

  final double Function(double) sx;
  final double Function(double) sy;

  @override
  Widget build(BuildContext context) {
    const g = SplashScene._green;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo mark 58×58, radius 18
        Container(
          width: sx(58),
          height: sx(58),
          decoration: BoxDecoration(
            color: g,
            borderRadius: BorderRadius.circular(sx(18)),
            boxShadow: [
              BoxShadow(color: g.withValues(alpha: 0.094), spreadRadius: sx(6)),
              BoxShadow(color: g.withValues(alpha: 0.031), spreadRadius: sx(14)),
              BoxShadow(
                color: g.withValues(alpha: 0.33),
                blurRadius: sx(48),
                offset: Offset(0, sy(16)),
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: sx(32),
              height: sx(32),
              child: CustomPaint(painter: _SplashLogoPainter()),
            ),
          ),
        ),
        SizedBox(height: sy(16)),
        Text(
          kAppName,
          style: GoogleFonts.inter(
            fontSize: sx(46),
            fontWeight: FontWeight.w800,
            letterSpacing: sx(-1.5),
            height: 1,
            color: Colors.white,
            shadows: [
              Shadow(
                color: g.withValues(alpha: 0.25),
                blurRadius: sx(60),
              ),
            ],
          ),
        ),
        SizedBox(height: sy(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: sx(28), height: 1, color: g.withValues(alpha: 0.376)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sx(10)),
              child: Text(
                'YOUR COMMUTE, SHARED',
                style: GoogleFonts.inter(
                  fontSize: sx(12),
                  fontWeight: FontWeight.w600,
                  letterSpacing: sx(2.5),
                  color: g.withValues(alpha: 0.8),
                ),
              ),
            ),
            Container(width: sx(28), height: 1, color: g.withValues(alpha: 0.376)),
          ],
        ),
      ],
    );
  }
}

/// Bottom frosted CTA panel — wireframe exact styling.
class SplashBottomPanel extends StatelessWidget {
  const SplashBottomPanel({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    const g = SplashScene._green;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 40 + bottom),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xB3050F08),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _StatColumn(value: 'Verified', label: 'Colleagues only'),
                      SizedBox(width: 24),
                      _StatColumn(value: 'Smart', label: 'Route matching'),
                      SizedBox(width: 24),
                      _StatColumn(value: '৳0', label: 'App fees'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(height: 1, color: Color(0x12FFFFFF)),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: onGetStarted,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: g,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: g.withValues(alpha: 0.33),
                            blurRadius: 28,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Get Started →',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onSignIn,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Text(
                        'I already have an account',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _SplashIllustrationPainter extends CustomPainter {
  _SplashIllustrationPainter({required this.w, required this.h});

  final double w;
  final double h;
  static const _aw = 390.0;
  static const _ah = 844.0;
  static const _g = SplashScene._green;

  double _x(double v) => v / _aw * w;
  double _y(double v) => v / _ah * h;

  Offset _p(double x, double y) => Offset(_x(x), _y(y));

  @override
  void paint(Canvas canvas, Size size) {
    _paintStars(canvas);
    _paintMap(canvas);
  }

  void _paintStars(Canvas canvas) {
    const stars = <(double, double)>[
      (38, 72), (72, 44), (120, 28), (180, 18), (240, 32), (310, 52), (356, 80),
      (22, 140), (340, 120), (60, 190), (320, 170), (15, 260), (370, 240),
      (44, 320), (355, 300), (18, 390), (372, 370),
    ];
    for (var i = 0; i < stars.length; i++) {
      final (x, y) = stars[i];
      final r = i % 3 == 0 ? 1.5 : 1.0;
      final opacity = 0.15 + (i % 4) * 0.07;
      canvas.drawCircle(
        _p(x, y),
        _x(r),
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }
  }

  void _paintMap(Canvas canvas) {
    const cx = 195.0;
    const cy = 420.0;

    // Ripple rings
    for (final (r, sw, op) in [
      (160.0, 0.8, 0.06),
      (110.0, 0.8, 0.09),
      (65.0, 1.0, 0.13),
      (30.0, 1.2, 0.2),
    ]) {
      canvas.drawCircle(
        _p(cx, cy),
        _x(r),
        Paint()
          ..color = _g.withValues(alpha: op)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _x(sw),
      );
    }

    // Dashed routes
    _dashPath(canvas, 'M20 80 C60 140, 100 220, 195 420', 1.5, const [5, 5], 0.45);
    _dashPath(canvas, 'M195 20 C195 100, 195 220, 195 420', 1.5, const [5, 5], 0.35);
    _dashPath(canvas, 'M370 95 C330 170, 280 260, 195 420', 1.5, const [5, 5], 0.45);
    _dashPath(canvas, 'M10 340 C60 350, 120 380, 195 420', 1.2, const [4, 5], 0.3);
    _dashPath(canvas, 'M380 350 C320 370, 260 390, 195 420', 1.2, const [4, 5], 0.3);
    _dashPath(canvas, 'M30 560 C80 510, 130 470, 195 420', 1.0, const [3, 5], 0.22);
    _dashPath(canvas, 'M360 540 C310 500, 260 460, 195 420', 1.0, const [3, 5], 0.22);

    // Travelers
    _traveler(canvas, 107, 222, 4.5, 0.9);
    _traveler(canvas, 285, 258, 4.5, 0.9);
    _traveler(canvas, 195, 190, 4.0, 0.7);
    _traveler(canvas, 95, 375, 3.5, 0.6);
    _traveler(canvas, 295, 385, 3.5, 0.6);

    // Origin homes
    for (final (x, y, r, op) in [
      (20.0, 80.0, 5.0, 0.5),
      (195.0, 20.0, 5.0, 0.4),
      (370.0, 95.0, 5.0, 0.5),
      (10.0, 340.0, 4.0, 0.35),
      (380.0, 350.0, 4.0, 0.35),
    ]) {
      canvas.drawCircle(_p(x, y), _x(r), Paint()..color = _g.withValues(alpha: op));
    }

    // Convergence glow
    for (final (r, op) in [(44.0, 0.06), (26.0, 0.12), (14.0, 0.3), (7.0, 0.9)]) {
      canvas.drawCircle(_p(cx, cy), _x(r), Paint()..color = _g.withValues(alpha: op));
    }
    canvas.drawCircle(_p(cx, cy), _x(3), Paint()..color = Colors.white);

    // Matched! badge
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(_x(212), _y(408), _x(68), _y(20)),
      Radius.circular(_x(10)),
    );
    canvas.drawRRect(badgeRect, Paint()..color = _g.withValues(alpha: 0.95));
    _drawText(canvas, 'Matched!', _p(246, 422), _x(10), FontWeight.w700, Colors.white);

    // Buildings (before road line so the spine draws on top)
    const buildings = <(double, double, double, double)>[
      (0, 680, 55, 164),
      (60, 700, 40, 144),
      (105, 715, 30, 129),
      (140, 695, 45, 149),
      (190, 670, 50, 174),
      (245, 685, 45, 159),
      (295, 710, 35, 134),
      (335, 695, 40, 149),
      (380, 705, 40, 139),
    ];
    for (final (x, y, bw, bh) in buildings) {
      canvas.drawRect(
        Rect.fromLTWH(_x(x), _y(y), _x(bw), _y(bh)),
        Paint()..color = const Color(0xFF050E09),
      );
    }

    // City glow
    final glowRect = Rect.fromLTWH(0, _y(670), w, h - _y(670));
    canvas.saveLayer(glowRect, Paint()..color = Colors.white.withValues(alpha: 0.4));
    canvas.drawRect(
      glowRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_g.withValues(alpha: 0.15), _g.withValues(alpha: 0)],
        ).createShader(glowRect),
    );
    canvas.restore();

    // Solid spine: convergence → office pin → skyline (the line Figma shows)
    _paintRoadSpine(canvas);

    // Office pin on top of spine
    final pin = Path()
      ..moveTo(_x(195), _y(608))
      ..cubicTo(_x(195), _y(608), _x(183), _y(620), _x(195), _y(633))
      ..cubicTo(_x(207), _y(620), _x(195), _y(608), _x(195), _y(608));
    canvas.drawPath(pin, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(_p(195, 618), _x(4), Paint()..color = const Color(0xFF040C07));
  }

  /// Bright vertical route from match point through office into the city.
  void _paintRoadSpine(Canvas canvas) {
    const x = 195.0;
    final start = _p(x, 420);
    final end = _p(x, 690);

    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = _g.withValues(alpha: 0.12)
        ..strokeWidth = _x(10)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = _g.withValues(alpha: 0.6)
        ..strokeWidth = _x(3)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = _x(1)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _traveler(Canvas canvas, double x, double y, double r, double op) {
    final center = _p(x, y);
    canvas.drawCircle(center, _x(r * 2), Paint()..color = _g.withValues(alpha: 0.15));
    canvas.drawCircle(center, _x(r), Paint()..color = _g.withValues(alpha: op));
  }

  void _dashPath(
    Canvas canvas,
    String svgPath,
    double strokeW,
    List<double> dash,
    double opacity,
  ) {
    final path = _parseSvgPath(svgPath);
    final paint = Paint()
      ..color = _g.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _x(strokeW)
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var dashIndex = 0;
      while (distance < metric.length) {
        final len = dash[dashIndex % dash.length];
        final end = distance + len;
        if (dashIndex % 2 == 0) {
          canvas.drawPath(metric.extractPath(distance, end.clamp(0, metric.length)), paint);
        }
        distance = end;
        dashIndex++;
      }
    }
  }

  Path _parseSvgPath(String d) {
    // Minimal parser for M/C paths used in wireframe
    final path = Path();
    final tokens = d.replaceAll(',', ' ').split(RegExp(r'\s+'));
    var i = 0;
    while (i < tokens.length) {
      final cmd = tokens[i++];
      if (cmd == 'M' && i + 1 < tokens.length) {
        path.moveTo(_x(double.parse(tokens[i])), _y(double.parse(tokens[i + 1])));
        i += 2;
      } else if (cmd == 'C' && i + 5 < tokens.length) {
        path.cubicTo(
          _x(double.parse(tokens[i])),
          _y(double.parse(tokens[i + 1])),
          _x(double.parse(tokens[i + 2])),
          _y(double.parse(tokens[i + 3])),
          _x(double.parse(tokens[i + 4])),
          _y(double.parse(tokens[i + 5])),
        );
        i += 6;
      } else if (cmd == 'L' && i + 1 < tokens.length) {
        path.lineTo(_x(double.parse(tokens[i])), _y(double.parse(tokens[i + 1])));
        i += 2;
      }
    }
    return path;
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset anchor,
    double fontSize,
    FontWeight weight,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          fontFamily: 'Inter',
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(anchor.dx - painter.width / 2, anchor.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _SplashIllustrationPainter old) =>
      old.w != w || old.h != h;
}

class _SplashLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32, size.height / 32);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(3, 24)
      ..quadraticBezierTo(8, 17, 11, 14)
      ..quadraticBezierTo(14, 11, 18, 12)
      ..quadraticBezierTo(22, 13, 23, 18);
    canvas.drawPath(path, paint);

    canvas.drawCircle(const Offset(5.5, 25), 3.5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(23, 18), 3.5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(17, 8), 3, paint..style = PaintingStyle.stroke);
    // Person body line (small vertical tick under head ring)
    canvas.drawLine(const Offset(17, 11), const Offset(16, 14), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
