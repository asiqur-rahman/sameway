import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_typography.dart';

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
  const RecentSearchRow({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.searchResults),
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

/// Home Find tab — compact multi-select preference pills in one row (Figma).
class FindPreferencesRow extends StatefulWidget {
  const FindPreferencesRow({super.key});

  @override
  State<FindPreferencesRow> createState() => _FindPreferencesRowState();
}

class _FindPreferencesRowState extends State<FindPreferencesRow> {
  bool _carSelected = true;
  bool _bikeSelected = false;
  bool _anyGenderSelected = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PreferenceChip(
          label: '🚗 Car',
          selected: _carSelected,
          useRoboto: true,
          onTap: () => setState(() => _carSelected = !_carSelected),
        ),
        const SizedBox(width: 6),
        PreferenceChip(
          label: '🏍 Bike ok',
          selected: _bikeSelected,
          onTap: () => setState(() => _bikeSelected = !_bikeSelected),
        ),
        const SizedBox(width: 6),
        PreferenceChip(
          label: 'Any gender',
          selected: _anyGenderSelected,
          onTap: () => setState(() => _anyGenderSelected = !_anyGenderSelected),
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
