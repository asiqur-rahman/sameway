import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/maps/map_config.dart';
import 'package:sameway/core/maps/map_route_resolver.dart';
import 'package:sameway/core/maps/sameway_map_view.dart';
import 'package:sameway/core/models/map_location.dart';
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
    this.postRideShell = false,
    this.distanceLabel,
    this.mapStart,
    this.mapEnd,
    this.liveMarkers = false,
    this.pickerMode = false,
    this.onMapPicked,
    this.pickerInitial,
    this.showMyLocation = false,
  });

  final double height;
  final String hint;
  final bool showRoute;
  final String? startLabel;
  final String? endLabel;
  final bool interactive;
  final bool showZoomControls;
  final bool postRideShell;
  final String? distanceLabel;
  final MapLocation? mapStart;
  final MapLocation? mapEnd;
  final bool liveMarkers;
  final bool pickerMode;
  final ValueChanged<MapLocation>? onMapPicked;
  final MapLocation? pickerInitial;
  final bool showMyLocation;

  @override
  Widget build(BuildContext context) {
    if (MapConfig.useNativeMaps &&
        (showRoute || interactive || pickerMode || mapStart != null)) {
      final resolverStart = MapRouteResolver.searchStart;
      final resolverEnd = MapRouteResolver.searchEnd;
      final start = mapStart ??
          (showRoute
              ? MapLocation(
                  address: startLabel ?? resolverStart.address,
                  lat: resolverStart.lat,
                  lng: resolverStart.lng,
                )
              : null);
      final end = mapEnd ??
          (showRoute
              ? MapLocation(
                  address: endLabel ?? resolverEnd.address,
                  lat: resolverEnd.lat,
                  lng: resolverEnd.lng,
                )
              : null);

      return SamewayMapView(
        height: height,
        start: start,
        end: end,
        initialCenter: pickerInitial ?? (pickerMode ? start : null),
        pickerMode: pickerMode || interactive,
        liveMarkers: liveMarkers || (showRoute && !pickerMode && !interactive),
        showMyLocation: showMyLocation || interactive,
        hint: hint,
        borderRadius: postRideShell ? AppRadius.xl : AppRadius.md,
        onPickerChanged: onMapPicked,
        pickerAddress: pickerInitial?.address,
      );
    }

    return _LegacyMapPlaceholder(
      height: height,
      hint: hint,
      showRoute: showRoute,
      startLabel: startLabel,
      endLabel: endLabel,
      interactive: interactive,
      showZoomControls: showZoomControls,
      postRideShell: postRideShell,
      distanceLabel: distanceLabel,
    );
  }
}

class _LegacyMapPlaceholder extends StatelessWidget {
  const _LegacyMapPlaceholder({
    required this.height,
    required this.hint,
    required this.showRoute,
    this.startLabel,
    this.endLabel,
    required this.interactive,
    required this.showZoomControls,
    required this.postRideShell,
    this.distanceLabel,
  });

  final double height;
  final String hint;
  final bool showRoute;
  final String? startLabel;
  final String? endLabel;
  final bool interactive;
  final bool showZoomControls;
  final bool postRideShell;
  final String? distanceLabel;

  @override
  Widget build(BuildContext context) {
    final shellColor = postRideShell ? AppColors.mapShell : const Color(0xFFE8EDF2);
    final radius = postRideShell ? AppRadius.xl : AppRadius.md;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: shellColor,
          border: postRideShell ? null : Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _MapGridPainter(showRoute: showRoute, shellColor: shellColor),
            ),
            if (distanceLabel != null)
              Positioned(
                top: 48,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      distanceLabel!,
                      style: AppTypography.badge(color: Colors.white),
                    ),
                  ),
                ),
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
            if (showRoute && !postRideShell)
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
              left: postRideShell ? 22 : 12,
              bottom: postRideShell ? 18 : 10,
              right: postRideShell ? 22 : 12,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: postRideShell ? 16 : 10,
                  vertical: postRideShell ? 8 : 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: postRideShell ? 0.85 : 0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: postRideShell ? null : Border.all(color: AppColors.border),
                ),
                child: Text(
                  showRoute && startLabel != null && endLabel != null
                      ? '$startLabel → $endLabel'
                      : hint,
                  style: postRideShell
                      ? AppTypography.fieldHintSm.copyWith(fontSize: 13)
                      : GoogleFonts.inter(
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
  const _MapGridPainter({required this.showRoute, this.shellColor = const Color(0xFFE8EDF2)});

  final bool showRoute;
  final Color shellColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = shellColor,
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

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        10,
        AppSpacing.screenHorizontal,
        14,
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
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(label, style: AppTypography.sectionOverline),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.07)
                : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                title,
                style: AppTypography.selectionTitle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
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
    this.neutral = false,
    this.compact = false,
    this.bottomMargin = 0,
  });

  final String emoji;
  final String text;
  final Color tint;
  final bool neutral;
  final bool compact;
  final double bottomMargin;

  @override
  Widget build(BuildContext context) {
    final style = compact ? AppTypography.infoBannerCompact : AppTypography.infoBanner;
    final emojiSize = compact ? 14.0 : (neutral ? 16.0 : 14.0);
    final padding = compact
        ? const EdgeInsets.fromLTRB(14, 10, 14, 10)
        : const EdgeInsets.fromLTRB(14, 11, 14, 11);
    final bgColor = neutral
        ? AppColors.surfaceMuted
        : compact
            ? tint.withValues(alpha: 0.06)
            : tint.withValues(alpha: 0.07);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomMargin),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: neutral || compact
              ? null
              : Border.all(color: tint.withValues(alpha: 0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: TextStyle(fontSize: emojiSize)),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: style)),
          ],
        ),
      ),
    );
  }
}

/// 12px uppercase in-card label — wireframe "Who can see this ID?"
class FieldGroupLabel extends StatelessWidget {
  const FieldGroupLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.fieldGroupLabel,
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

/// Compact map preview for Post a Ride empty state (Figma: 100px, #eef2f7 shell).
class PostRideMapPreview extends StatelessWidget {
  const PostRideMapPreview({
    super.key,
    this.showRoute = false,
    this.startLabel,
    this.endLabel,
  });

  final bool showRoute;
  final String? startLabel;
  final String? endLabel;

  @override
  Widget build(BuildContext context) {
    final label = showRoute && startLabel != null && endLabel != null
        ? '$startLabel → $endLabel'
        : 'Route map will appear after locations are set';

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        height: 100,
        width: double.infinity,
        color: AppColors.mapShell,
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: AppTypography.fieldHintSm.copyWith(fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}

/// Start / end location field on Post a Ride (Figma: muted 48px tile).
class PostRideRouteField extends StatelessWidget {
  const PostRideRouteField({
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
  final VoidCallback onTap;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final selected = value != null && value!.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.routeSectionLabel),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selected ? value! : hint,
                    style: selected
                        ? AppTypography.fieldValue.copyWith(fontSize: 14)
                        : AppTypography.fieldHintSm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Centered "+ Add a stop" pill between start and end (Figma connector row).
class RouteAddStopRow extends StatelessWidget {
  const RouteAddStopRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 8,
            child: Center(
              child: Container(
                width: 2,
                height: 20,
                color: AppColors.border,
              ),
            ),
          ),
          Expanded(
            child: Container(height: 1, color: AppColors.border),
          ),
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 29,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('+', style: AppTypography.addStopPlus),
                  const SizedBox(width: 4),
                  Text('Add a stop', style: AppTypography.addStopLabel),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(height: 1, color: AppColors.border),
          ),
        ],
      ),
    );
  }
}

/// Route builder: start → add stop → end.
class PostRideRouteBuilder extends StatelessWidget {
  const PostRideRouteBuilder({
    super.key,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onAddStop,
    this.startValue,
    this.endValue,
  });

  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onAddStop;
  final String? startValue;
  final String? endValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostRideRouteField(
          label: 'START (FROM)',
          icon: '📍',
          hint: 'Tap to set your home / start location',
          value: startValue,
          onTap: onPickStart,
        ),
        RouteAddStopRow(onTap: onAddStop),
        PostRideRouteField(
          label: 'END (TO / OFFICE)',
          icon: '🏢',
          hint: 'Tap to set your office / destination',
          value: endValue,
          onTap: onPickEnd,
        ),
      ],
    );
  }
}

class RouteTipBanner extends StatelessWidget {
  const RouteTipBanner({
    super.key,
    this.text =
        'Set your route first — Google Maps will geocode each point so riders anywhere along your path get matched automatically.',
    this.emoji = '💡',
  });

  final String text;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.infoBanner.copyWith(
                color: AppColors.textMuted,
                height: 19.2 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostRideDisabledField extends StatelessWidget {
  const PostRideDisabledField({
    super.key,
    required this.label,
    required this.emoji,
  });

  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.routeSectionLabel),
        const SizedBox(height: 5),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text('Set after route', style: AppTypography.fieldHintSm),
            ],
          ),
        ),
      ],
    );
  }
}

class PostRideDisabledButton extends StatelessWidget {
  const PostRideDisabledButton({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        label,
        style: AppTypography.buttonDisabled,
      ),
    );
  }
}

/// Read-only route point with optional GPS subtitle (Route Confirmed / Filled).
class PostRideRoutePoint extends StatelessWidget {
  const PostRideRoutePoint({
    super.key,
    required this.sectionLabel,
    required this.title,
    this.subtitle,
    this.showGpsBadge = false,
  });

  final String sectionLabel;
  final String title;
  final String? subtitle;
  final bool showGpsBadge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sectionLabel, style: AppTypography.routeSectionLabel),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.fieldValue),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTypography.caption),
              ],
              if (showGpsBadge) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint7,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'GPS',
                    style: AppTypography.badge(color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Filled / editable field row (Date, Time, Seats).
class PostRideValueField extends StatelessWidget {
  const PostRideValueField({
    super.key,
    required this.label,
    required this.emoji,
    required this.value,
    this.onTap,
  });

  final String label;
  final String emoji;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Text(value, style: AppTypography.fieldValue.copyWith(fontSize: 15)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.routeSectionLabel),
        const SizedBox(height: 5),
        if (onTap != null)
          GestureDetector(onTap: onTap, child: child)
        else
          child,
      ],
    );
  }
}

class PostRideRepeatChip extends StatelessWidget {
  const PostRideRepeatChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 37,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          label,
          style: AppTypography.filterSegmentChip(selected: selected),
        ),
      ),
    );
  }
}

class PostRideSeatsStepper extends StatelessWidget {
  const PostRideSeatsStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EMPTY SEATS', style: AppTypography.routeSectionLabel),
        const SizedBox(height: 5),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              _StepperButton(label: '−', onTap: onDecrement),
              Expanded(
                child: Center(
                  child: Text(
                    '$value',
                    style: AppTypography.greetingTitle.copyWith(fontSize: 28),
                  ),
                ),
              ),
              _StepperButton(label: '+', onTap: onIncrement),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.fieldValue.copyWith(fontSize: 20),
        ),
      ),
    );
  }
}
