import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class PickStartLocationScreen extends StatelessWidget {
  PickStartLocationScreen({super.key});

  final _searchController = TextEditingController();

  static const _savedPlaces = [
    _SavedPlace(emoji: '🏠', title: 'Home', subtitle: 'Uttara Sector 4, Dhaka'),
    _SavedPlace(emoji: '🏢', title: 'Office', subtitle: 'Motijheel, Dhaka'),
    _SavedPlace(emoji: '🕐', title: 'Recent', subtitle: 'Farmgate Bus Stand, Dhaka'),
  ];

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          MobilePageHeader(
            title: 'Pick Start',
            subtitle: 'Where will you leave from?',
            onBack: () => context.pop(),
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
                const MapPlaceholder(height: 400, hint: 'Drag pin or search below'),
                const SizedBox(height: 16),
                SamewayTextField(
                  label: 'Search',
                  hint: 'Search start location',
                  icon: '🔍',
                  controller: _searchController,
                ),
                const SizedBox(height: 20),
                const SectionHeader('SAVED PLACES'),
                const SizedBox(height: 10),
                ..._savedPlaces.map(
                  (place) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SavedPlaceTile(place: place),
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
              label: 'Confirm Start Location',
              onPressed: () => context.push(AppRoutes.pickEnd),
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

class _SavedPlaceTile extends StatelessWidget {
  const _SavedPlaceTile({required this.place});

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
