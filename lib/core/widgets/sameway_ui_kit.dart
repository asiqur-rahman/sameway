import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/navigation/sameway_navigation.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';

class SamewayLogo extends StatelessWidget {
  const SamewayLogo({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SamewayLogoPainter(),
      ),
    );
  }
}

class _SamewayLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width * 0.25;
    final bg = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    canvas.drawRRect(bg, Paint()..color = AppColors.primary);

    final carCenter = Offset(size.width * 0.5, size.height * 0.54);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: carCenter, width: size.width * 0.52, height: size.height * 0.28),
      Radius.circular(size.width * 0.08),
    );
    canvas.drawRRect(body, Paint()..color = Colors.white);

    final wheelPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(carCenter.dx - size.width * 0.14, carCenter.dy + size.height * 0.12), size.width * 0.06, wheelPaint);
    canvas.drawCircle(Offset(carCenter.dx + size.width * 0.14, carCenter.dy + size.height * 0.12), size.width * 0.06, wheelPaint);

    final roof = Path()
      ..moveTo(carCenter.dx - size.width * 0.12, carCenter.dy - size.height * 0.02)
      ..lineTo(carCenter.dx - size.width * 0.04, carCenter.dy - size.height * 0.16)
      ..lineTo(carCenter.dx + size.width * 0.1, carCenter.dy - size.height * 0.16)
      ..lineTo(carCenter.dx + size.width * 0.16, carCenter.dy - size.height * 0.02)
      ..close();
    canvas.drawPath(roof, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    this.height = 180,
    this.hint = 'Route map will appear after locations are set',
    this.showRoute = false,
    this.startLabel,
    this.endLabel,
    this.interactive = false,
    this.showZoomControls = false,
  });

  final double height;
  final String hint;
  final bool showRoute;
  final String? startLabel;
  final String? endLabel;
  final bool interactive;
  final bool showZoomControls;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EDF2),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _MapGridPainter(showRoute: showRoute),
            ),
            if (interactive)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary, size: 40),
                    Container(
                      width: 14,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            if (showRoute)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    'Route active',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (showZoomControls)
              Positioned(
                right: 12,
                bottom: 48,
                child: Column(
                  children: [
                    _ZoomButton(icon: Icons.add),
                    const SizedBox(height: 6),
                    _ZoomButton(icon: Icons.remove),
                  ],
                ),
              ),
            Positioned(
              left: 12,
              bottom: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  showRoute && startLabel != null && endLabel != null
                      ? '$startLabel → $endLabel'
                      : hint,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 16, color: AppColors.textSecondary),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter({required this.showRoute});

  final bool showRoute;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE8EDF2),
    );

    final blockPaint = Paint()..color = const Color(0xFFF5F7FA);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.05, size.height * 0.1, size.width * 0.35, size.height * 0.25), blockPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.55, size.height * 0.55, size.width * 0.38, size.height * 0.3), blockPaint);

    final waterPaint = Paint()..color = const Color(0xFFD6E4EE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.6, size.height * 0.08, size.width * 0.3, size.height * 0.18),
        const Radius.circular(12),
      ),
      waterPaint,
    );

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), roadPaint);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), roadPaint);

    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.35)
      ..strokeWidth = 0.5;
    for (var x = 0.0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (showRoute && size.width > 0) {
      final glow = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.2)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      final route = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final start = Offset(size.width * 0.18, size.height * 0.72);
      final end = Offset(size.width * 0.82, size.height * 0.28);
      canvas.drawLine(start, end, glow);
      canvas.drawLine(start, end, route);

      canvas.drawCircle(start, 7, Paint()..color = AppColors.primary);
      canvas.drawCircle(start, 3, Paint()..color = Colors.white);

      final endCap = Paint()
        ..color = AppColors.textPrimary
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(end.dx, end.dy - 7), Offset(end.dx, end.dy + 7), endCap);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.showRoute != showRoute;
}

class MobilePageHeader extends StatelessWidget {
  const MobilePageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.backFallback,
    this.trailing,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final String? backFallback;
  final Widget? trailing;
  final bool showBack;

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    SamewayNavigation.popOrGo(context, fallback: backFallback);
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = showBack && (onBack != null || backFallback != null || context.canPop());

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        8,
        AppSpacing.screenHorizontal,
        12,
      ),
      child: Row(
        children: [
          if (canGoBack)
            GestureDetector(
              onTap: () => _handleBack(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: SamewayDecorations.iconButton(radius: 10),
                child: const Icon(Icons.arrow_back_ios_new, size: 16),
              ),
            ),
          if (canGoBack) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.pageTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTypography.pageSubtitle),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTypography.sectionOverline);
  }
}

class SelectionCard extends StatelessWidget {
  const SelectionCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected ? AppShadows.soft : null,
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 8),
              Text(title, style: AppTypography.selectionTitle()),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.selectionSubtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.emoji,
    required this.text,
    this.tint = AppColors.primary,
  });

  final String emoji;
  final String text;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tint.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppTypography.infoBanner),
          ),
        ],
      ),
    );
  }
}

class FlowStepRow extends StatelessWidget {
  const FlowStepRow({
    super.key,
    required this.emoji,
    required this.label,
    this.done = false,
  });

  final String emoji;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.primary.withValues(alpha: 0.125)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: done ? null : Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Text(label, style: AppTypography.flowStep),
        ],
      ),
    );
  }
}

class RouteFieldTile extends StatelessWidget {
  const RouteFieldTile({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    required this.onTap,
    this.value,
  });

  final String label;
  final String icon;
  final String hint;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.routeFieldLabel),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: SamewayDecorations.insetField(),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: value != null
                        ? AppTypography.fieldValue
                        : AppTypography.fieldHintSm,
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
