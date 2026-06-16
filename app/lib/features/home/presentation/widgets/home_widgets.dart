import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/maps/device_location_service.dart';
import 'package:sameway/core/maps/map_config.dart';
import 'package:sameway/core/maps/search_location_resolver.dart';
import 'package:sameway/core/models/map_location.dart';
import 'package:sameway/core/models/search_location.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/widgets/sameway_banner.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.label,
    this.color = AppColors.primary,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.sectionAccent(color: color),
        ),
      ],
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'or',
            style: AppTypography.routeMeta,
          ),
        ),
        const Expanded(child: Divider(height: 1)),
      ],
    );
  }
}

class ActiveRideCard extends StatelessWidget {
  const ActiveRideCard({
    super.key,
    required this.timeLabel,
    required this.routeLabel,
    this.status = 'Active',
    this.onTapRoute,
  });

  final String timeLabel;
  final String routeLabel;
  final String status;
  final String? onTapRoute;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapRoute != null ? () => context.push(onTapRoute!) : null,
      child: Container(
      height: 83,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: SamewayDecorations.card(radius: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.125),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text('🚗', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timeLabel,
                  style: AppTypography.cardTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  routeLabel,
                  style: AppTypography.cardSubtitle,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.094),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: AppTypography.badge(),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class RecentSearchRow extends StatelessWidget {
  const RecentSearchRow({
    super.key,
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push(AppRoutes.searchFilters),
      child: Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: SamewayDecorations.card(radius: 16),
      child: Row(
        children: [
          const Text('🕐', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTypography.listRowTitle,
            ),
          ),
          Text(
            '↗',
            style: AppTypography.cardSubtitle.copyWith(fontSize: 18),
          ),
        ],
      ),
      ),
    );
  }
}

class PreferenceChip extends StatelessWidget {
  const PreferenceChip({
    super.key,
    required this.label,
    this.selected = false,
    this.useRoboto = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool useRoboto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      height: 21,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryDark : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.preferenceChipCompact(
          selected: selected,
          roboto: useRoboto,
        ),
      ),
    );

    if (onTap == null) return chip;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: chip,
    );
  }
}

class FindPreferencesRow extends StatelessWidget {
  const FindPreferencesRow({
    super.key,
    required this.carSelected,
    required this.bikeSelected,
    required this.anyGenderSelected,
    required this.onCarChanged,
    required this.onBikeChanged,
    required this.onAnyGenderChanged,
  });

  final bool carSelected;
  final bool bikeSelected;
  final bool anyGenderSelected;
  final ValueChanged<bool> onCarChanged;
  final ValueChanged<bool> onBikeChanged;
  final ValueChanged<bool> onAnyGenderChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PreferenceChip(
          label: '🚗 Car',
          selected: carSelected,
          useRoboto: true,
          onTap: () => onCarChanged(!carSelected),
        ),
        const SizedBox(width: 6),
        PreferenceChip(
          label: '🏍 Bike ok',
          selected: bikeSelected,
          onTap: () => onBikeChanged(!bikeSelected),
        ),
        const SizedBox(width: 6),
        PreferenceChip(
          label: 'Any gender',
          selected: anyGenderSelected,
          onTap: () => onAnyGenderChanged(!anyGenderSelected),
        ),
      ],
    );
  }
}

class FilterSegmentChip extends StatelessWidget {
  const FilterSegmentChip({
    super.key,
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryDark : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.filterSegmentChip(selected: selected),
      ),
    );
  }
}

class GenderFilterChip extends StatelessWidget {
  const GenderFilterChip({
    super.key,
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.07)
            : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.transparent,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.genderFilterChip(selected: selected),
      ),
    );
  }
}

class RouteTimeline extends StatelessWidget {
  const RouteTimeline({
    super.key,
    required this.route,
    required this.schedule,
  });

  final String route;
  final String schedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.125)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(width: 2, height: 18, color: AppColors.border),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: AppTypography.routeTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  schedule,
                  style: AppTypography.routeMeta,
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _TagChip(label: '🚗 Toyota Allion'),
                    _TagChip(label: '💺 2 seats'),
                    _TagChip(label: '✓ GPS verified', accent: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    this.accent = false,
  });

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTypography.chipLabel(
          color: accent ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Map-first Find tab preview — wireframes v2.
class FindRideMapPreview extends StatelessWidget {
  const FindRideMapPreview({
    super.key,
    required this.badgeLabel,
    this.start,
    this.end,
  });

  final String badgeLabel;
  final MapLocation? start;
  final MapLocation? end;

  bool get _hasRoute =>
      start != null && end != null && start!.isValid && end!.isValid;

  /// Badge text for the map overlay from a live or in-progress ride search.
  static String badgeFor({
    required bool hasRoute,
    required bool loading,
    int? count,
  }) {
    if (!hasRoute) return 'Set your route';
    if (loading) return 'Searching…';
    final n = count ?? 0;
    if (n == 0) return 'No rides found';
    return '$n ride${n == 1 ? '' : 's'} found';
  }

  @override
  Widget build(BuildContext context) {
    final routeKey = _hasRoute
        ? '${start!.lat},${start!.lng}-${end!.lat},${end!.lng}'
        : 'no-route';
    const emptyHint = 'Set From and To to see your route';

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MapPlaceholder(
              key: ValueKey(routeKey),
              height: 180,
              showRoute: _hasRoute,
              showEmptyMap: !_hasRoute,
              mapStart: start,
              mapEnd: end,
              startLabel: start?.address,
              endLabel: end?.address,
              liveMarkers: _hasRoute,
              hint: _hasRoute ? '' : emptyHint,
              centerHint: !_hasRoute,
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeLabel,
                  style: AppTypography.badge(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 8,
              child: _OsmMapsBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OsmMapsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF7EBC6F),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'O',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text('OpenStreetMap', style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _FindMapGridPainter extends CustomPainter {
  const _FindMapGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1DCE9)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (var i = 0; i <= 7; i++) {
      final x = size.width * i / 7;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FindMapRoutePainter extends CustomPainter {
  const _FindMapRoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 390;
    final scaleY = size.height / 210;

    final road = Paint()
      ..color = const Color(0xFFB8CCDE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(30 * scaleX, 185 * scaleY)
      ..quadraticBezierTo(120 * scaleX, 140 * scaleY, 195 * scaleX, 110 * scaleY)
      ..quadraticBezierTo(270 * scaleX, 80 * scaleY, 360 * scaleX, 38 * scaleY);
    canvas.drawPath(path, road);

    canvas.drawCircle(Offset(30 * scaleX, 185 * scaleY), 8 * scaleX, Paint()..color = AppColors.primary);
    canvas.drawPath(
      Path()
        ..moveTo(360 * scaleX, 26 * scaleY)
        ..cubicTo(360 * scaleX, 26 * scaleY, 350 * scaleX, 37 * scaleY, 360 * scaleX, 48 * scaleY)
        ..cubicTo(370 * scaleX, 37 * scaleY, 360 * scaleX, 26 * scaleY, 360 * scaleX, 26 * scaleY),
      Paint()..color = AppColors.textPrimary,
    );
    canvas.drawCircle(Offset(360 * scaleX, 36 * scaleY), 4, Paint()..color = Colors.white);

    for (final (x, y, pct) in [(115.0, 143.0, '94'), (195.0, 110.0, '89'), (265.0, 78.0, '82')]) {
      final center = Offset(x * scaleX, y * scaleY);
      canvas.drawCircle(center, 14 * scaleX, Paint()..color = AppColors.accentBlue.withValues(alpha: 0.85));
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$pct%',
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Circular swap control aligned on the route spine between From and To.
class RouteSwapButton extends StatelessWidget {
  const RouteSwapButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Icon(
            Icons.swap_vert_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class LocationFieldRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isOrigin;
  final String actionLabel;
  final VoidCallback? onTap;
  final bool mutedValue;

  const LocationFieldRow({
    super.key,
    required this.label,
    required this.value,
    required this.isOrigin,
    this.actionLabel = '📍 Change',
    this.onTap,
    this.mutedValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isOrigin ? AppColors.primary : AppColors.textPrimary,
                borderRadius: BorderRadius.circular(isOrigin ? 5 : 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: AppTypography.sectionAccent(color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: mutedValue
                        ? AppTypography.locationValue.copyWith(color: AppColors.textMuted)
                        : AppTypography.locationValue,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isOrigin
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                actionLabel,
                style: AppTypography.chipLabel(
                  color: isOrigin ? AppColors.primary : AppColors.textSecondary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateTimeFieldTile extends StatelessWidget {
  const DateTimeFieldTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
    this.onTap,
    this.mutedValue = false,
  });

  final String emoji;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool mutedValue;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: AppTypography.sectionAccent(color: AppColors.textMuted)),
                Text(
                  value,
                  style: mutedValue
                      ? AppTypography.dateTimeValue.copyWith(color: AppColors.textMuted)
                      : AppTypography.dateTimeValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: child);
  }
}

/// Bottom sheet to pick or type a commute location (home Find tab).
Future<SearchLocation?> showHomeLocationPicker(
  BuildContext context, {
  required String title,
  String? initial,
  double? initialLat,
  double? initialLng,
  bool preferCurrentLocation = false,
}) {
  return showModalBottomSheet<SearchLocation>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _HomeLocationPickerSheet(
      title: title,
      initial: initial,
      initialLat: initialLat,
      initialLng: initialLng,
      preferCurrentLocation: preferCurrentLocation,
    ),
  );
}

class _HomeLocationPickerSheet extends StatefulWidget {
  const _HomeLocationPickerSheet({
    required this.title,
    this.initial,
    this.initialLat,
    this.initialLng,
    this.preferCurrentLocation = false,
  });

  final String title;
  final String? initial;
  final double? initialLat;
  final double? initialLng;
  final bool preferCurrentLocation;

  @override
  State<_HomeLocationPickerSheet> createState() => _HomeLocationPickerSheetState();
}

class _HomeLocationPickerSheetState extends State<_HomeLocationPickerSheet> {
  late final TextEditingController _controller;
  SearchLocation? _gpsLocation;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial?.trim() ?? '');
    if (widget.preferCurrentLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prefillCurrentLocation());
    }
  }

  Future<void> _prefillCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    final current = await DeviceLocationService.getCurrentSearchLocation();
    if (!mounted) return;
    if (current == null) {
      setState(() => _locating = false);
      return;
    }
    setState(() {
      _gpsLocation = current;
      _locating = false;
      _controller.text = current.address;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<({String emoji, String label, SearchLocation location})> get _saved {
    final saved = <({String emoji, String label, SearchLocation location})>[];
    final home = SearchLocationResolver.savedHome();
    if (home != null) {
      saved.add((emoji: '🏠', label: 'Home', location: home));
    }
    final office = SearchLocationResolver.savedOffice();
    if (office != null) {
      saved.add((emoji: '🏢', label: 'Office', location: office));
    }
    return saved;
  }

  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    final current = await DeviceLocationService.getCurrentSearchLocation();
    if (!mounted) return;
    if (current == null) {
      setState(() => _locating = false);
      SamewayBanner.showWarning(
        context,
        'Could not get GPS — enable location permission in settings',
      );
      return;
    }
    setState(() {
      _gpsLocation = current;
      _locating = false;
      _controller.text = current.address;
    });
  }

  Future<void> _pinOnMap() async {
    final savedLabel = widget.initial?.trim();
    final typedLabel = _controller.text.trim();
    final initialPin = SearchLocationResolver.hasValidCoords(widget.initialLat, widget.initialLng)
        ? MapLocation(
            address: (savedLabel != null && savedLabel.isNotEmpty)
                ? savedLabel
                : (typedLabel.isNotEmpty ? typedLabel : 'Pinned location'),
            lat: widget.initialLat!,
            lng: widget.initialLng!,
          )
        : _gpsLocation != null
            ? MapLocation(
                address: _gpsLocation!.address,
                lat: _gpsLocation!.lat,
                lng: _gpsLocation!.lng,
              )
            : null;
    final picked = await context.push<MapLocation>(
      AppRoutes.pickOfficeMap,
      extra: initialPin,
    );
    if (picked != null && picked.isValid && mounted) {
      Navigator.pop(
        context,
        SearchLocation(
          address: picked.address,
          lat: picked.lat,
          lng: picked.lng,
        ),
      );
    }
  }

  Future<void> _confirmTyped() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_gpsLocation != null && text == _gpsLocation!.address) {
      Navigator.pop(context, _gpsLocation);
      return;
    }
    final matched = SearchLocationResolver.matchSavedPlace(text);
    if (matched != null) {
      Navigator.pop(context, matched);
      return;
    }
    try {
      final resolved = await SearchLocationResolver.geocodeOrFallback(text);
      if (mounted) Navigator.pop(context, resolved);
    } catch (_) {
      if (mounted) {
        SamewayBanner.showWarning(
          context,
          'Could not geocode address — use Pin on map',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = _saved;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        16,
        AppSpacing.screenHorizontal,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: AppTypography.greetingTitle),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _locating ? null : () => _useCurrentLocation(),
            icon: _locating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.my_location, size: 18),
            label: Text(_locating ? 'Getting location…' : 'Use current location'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: saved.isEmpty && !widget.preferCurrentLocation,
            decoration: InputDecoration(
              hintText: 'Search or enter address',
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          if (saved.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('SAVED', style: AppTypography.sectionAccent(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            for (final place in saved)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(place.emoji, style: const TextStyle(fontSize: 20)),
                title: Text(place.label, style: AppTypography.listRowTitle),
                subtitle: Text(
                  place.location.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.cardSubtitle,
                ),
                onTap: () => Navigator.pop(context, place.location),
              ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pinOnMap,
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('Pin on map'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _confirmTyped,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Use this location'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

