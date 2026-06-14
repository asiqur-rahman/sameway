import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class PickEndLocationScreen extends StatelessWidget {
  PickEndLocationScreen({super.key});

  final _searchController = TextEditingController();

  static const _destinations = [
    _SavedPlace(emoji: '🏢', title: 'Office', subtitle: 'Motijheel, Dhaka'),
    _SavedPlace(emoji: '🏛', title: 'Gulshan 1', subtitle: 'Gulshan Avenue, Dhaka'),
    _SavedPlace(emoji: '🕐', title: 'Recent', subtitle: 'Kakrail Mor, Dhaka'),
  ];

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          MobilePageHeader(
            title: 'Pick Destination',
            subtitle: 'Where are you heading?',
            backFallback: AppRoutes.pickStart,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                24,
              ),
              children: [
                const MapPlaceholder(
                  height: 400,
                  hint: 'Set your office or drop-off point',
                  interactive: true,
                  showZoomControls: true,
                ),
                const SizedBox(height: 16),
                SamewayTextField(
                  label: 'Search',
                  hint: AppPlaceholders.searchDestination,
                  icon: '🔍',
                  controller: _searchController,
                ),
                const SizedBox(height: 20),
                const SectionHeader('SAVED DESTINATIONS'),
                const SizedBox(height: 10),
                ..._destinations.map(
                  (place) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DestinationTile(place: place),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.routeConfirmed),
                    child: Text(
                      'Skip — no extra stop needed',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              0,
              AppSpacing.screenHorizontal,
              24,
            ),
            child: SamewayPrimaryButton(
              label: 'Confirm Destination',
              onPressed: () => context.push(AppRoutes.addStop),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedPlace {
  const _SavedPlace({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({required this.place});

  final _SavedPlace place;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(place.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  place.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
