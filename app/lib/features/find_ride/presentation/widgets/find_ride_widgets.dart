import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/maps/map_route_resolver.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/find_ride/find_ride_flow.dart';
import 'package:sameway/features/home/presentation/widgets/home_widgets.dart';

/// Vertical route spine beside From / To fields (wireframe v2 search screen).
class FindRouteFieldStack extends StatelessWidget {
  const FindRouteFieldStack({
    super.key,
    required this.fromController,
    required this.toController,
    this.onFromTap,
    this.onToTap,
    this.onSwap,
  });

  final TextEditingController fromController;
  final TextEditingController toController;
  final VoidCallback? onFromTap;
  final VoidCallback? onToTap;
  final VoidCallback? onSwap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 34),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RouteSpineDot(isOrigin: true),
                if (onSwap != null)
                  RouteSwapButton(onPressed: onSwap!)
                else
                  Container(width: 2, height: 28, color: AppColors.border),
                _RouteSpineDot(isOrigin: false),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                _RouteInputField(
                  label: 'From',
                  icon: '📍',
                  controller: fromController,
                  onTap: onFromTap,
                ),
                const SizedBox(height: 8),
                _RouteInputField(
                  label: 'To',
                  icon: '🏢',
                  controller: toController,
                  onTap: onToTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSpineDot extends StatelessWidget {
  const _RouteSpineDot({required this.isOrigin});

  final bool isOrigin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isOrigin ? AppColors.primary : AppColors.textPrimary,
        shape: isOrigin ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isOrigin ? null : BorderRadius.circular(3),
      ),
    );
  }
}

class _RouteInputField extends StatelessWidget {
  const _RouteInputField({
    required this.label,
    required this.icon,
    required this.controller,
    this.onTap,
  });

  final String label;
  final String icon;
  final TextEditingController controller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.fieldLabel),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: SamewayDecorations.insetField(radius: 12),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: onTap != null,
                  onTap: onTap,
                  style: AppTypography.locationValue,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: label == 'From'
                        ? 'Where are you leaving from?'
                        : 'Where are you going?',
                    hintStyle: AppTypography.locationValue.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) return field;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: field);
  }
}

class FindWalkDistanceCard extends StatelessWidget {
  const FindWalkDistanceCard({
    super.key,
    required this.minutes,
    required this.onChanged,
  });

  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: SamewayDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: minutes.toDouble(),
                  min: 5,
                  max: 20,
                  divisions: 3,
                  label: '$minutes min',
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$minutes min',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            '≈ ${minutes * 70}m walking',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class FindMinMatchRow extends StatelessWidget {
  const FindMinMatchRow({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(FindRideFlow.minMatchOptions.length, (index) {
        final selected = index == selectedIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == FindRideFlow.minMatchOptions.length - 1 ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.surfaceMuted : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.textPrimary : AppColors.border,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  FindRideFlow.minMatchOptions[index],
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class FindResultsMapStrip extends StatelessWidget {
  const FindResultsMapStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final start = MapRouteResolver.optionalSearchStart;
    final end = MapRouteResolver.optionalSearchEnd;
    final hasRoute =
        start != null && end != null && start.isValid && end.isValid;
    final routeKey = hasRoute
        ? '${start.lat},${start.lng}-${end.lat},${end.lng}'
        : 'no-route';

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          MapPlaceholder(
            key: ValueKey(routeKey),
            height: 120,
            showRoute: hasRoute,
            mapStart: start,
            mapEnd: end,
            startLabel: start?.address ?? FindRideFlow.instance.from,
            endLabel: end?.address ?? FindRideFlow.instance.to,
            liveMarkers: hasRoute,
            hint: hasRoute ? 'Matching routes' : 'Route map',
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🏍 Bike routes included',
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FindRideResultCard extends StatelessWidget {
  const FindRideResultCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  final FindRideListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: SamewayDecorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _DriverAvatar(initial: listing.driverInitial),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.driverName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FindKudosStrip(
                        rides: listing.rides,
                        onTimePct: listing.onTimePct,
                        compact: true,
                      ),
                    ],
                  ),
                ),
                Text(
                  listing.isBike ? '🏍' : '🚗',
                  style: const TextStyle(fontSize: 26),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FROM', style: AppTypography.sectionAccent(color: AppColors.textMuted)),
                        Text(listing.from, style: AppTypography.chipLabel()),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 18, color: AppColors.textSecondary),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('TO', style: AppTypography.sectionAccent(color: AppColors.textMuted)),
                        Text(listing.to, style: AppTypography.chipLabel()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _SmallTag(label: '⏰ ${listing.departTime}'),
                _SmallTag(label: '${listing.seats} seats'),
                _SmallTag(label: '${listing.overlap}% match', accent: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent ? AppColors.primaryTint7 : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: accent ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Text('✓', style: TextStyle(fontSize: 8, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class FindKudosStrip extends StatelessWidget {
  const FindKudosStrip({
    super.key,
    required this.rides,
    required this.onTimePct,
    this.kudos = const [],
    this.compact = false,
  });

  final int rides;
  final int onTimePct;
  final List<String> kudos;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Text(
        '$rides rides · $onTimePct% on time',
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$rides rides · $onTimePct% on time',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
        ),
        if (kudos.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: kudos.map((k) => _SmallTag(label: k)).toList(),
          ),
        ],
      ],
    );
  }
}

class FindVerifyBadge extends StatelessWidget {
  const FindVerifyBadge({super.key, required this.org});

  final String org;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '✓ $org',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class FindRouteMatchCard extends StatelessWidget {
  const FindRouteMatchCard({super.key, required this.overlap});

  final int overlap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: SamewayDecorations.card(),
      child: Row(
        children: [
          Text(
            '$overlap%',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route Match',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '$overlap% of your journey is covered',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FindPickupBanner extends StatelessWidget {
  const FindPickupBanner({
    super.key,
    required this.label,
    required this.detail,
  });

  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Text('📍', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                Text(
                  detail,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FindSortFilterRow extends StatelessWidget {
  const FindSortFilterRow({
    super.key,
    required this.vehicleFilter,
    required this.onFilterChanged,
  });

  final String vehicleFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort: Best Match',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
        ),
        const SizedBox(width: 8),
        for (final filter in ['All', 'Car', 'Bike'])
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: PreferenceChip(
                label: filter,
                selected: vehicleFilter == filter,
              ),
            ),
          ),
      ],
    );
  }
}
