import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class PostRideEmptyScreen extends StatelessWidget {
  const PostRideEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          MobilePageHeader(
            title: 'Post a Ride',
            subtitle: 'Set your route first',
            backFallback: AppRoutes.home,
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
                const MapPlaceholder(),
                const SizedBox(height: 20),
                const SectionHeader('YOUR ROUTE'),
                const SizedBox(height: 12),
                RouteFieldTile(
                  label: 'START',
                  icon: '📍',
                  hint: 'Tap to set start location',
                  onTap: () => context.push(AppRoutes.pickStart),
                ),
                const SizedBox(height: 12),
                RouteFieldTile(
                  label: 'END',
                  icon: '🏢',
                  hint: 'Tap to set destination / office',
                  onTap: () => context.push(AppRoutes.pickEnd),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.addStop),
                  child: Text(
                    '＋ Add a stop',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const InfoBanner(
                  emoji: '📍',
                  text:
                      'Locations are geocoded via Google Maps. Pick points on the map or search by place name.',
                ),
                const SizedBox(height: 20),
                const SectionHeader('RIDE DETAILS'),
                const SizedBox(height: 8),
                const _DisabledDetailRow(
                  emoji: '🕐',
                  label: 'Departure time',
                  hint: 'Set after route',
                ),
                const _DisabledDetailRow(
                  emoji: '💺',
                  label: 'Available seats',
                  hint: 'Set after route',
                ),
                const _DisabledDetailRow(
                  emoji: '🔁',
                  label: 'Repeat',
                  hint: 'Set after route',
                ),
                const SizedBox(height: 24),
                Opacity(
                  opacity: 0.45,
                  child: SamewayPrimaryButton(
                    label: 'Set Route First to Continue',
                    onPressed: () {},
                    backgroundColor: AppColors.textMuted,
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

class _DisabledDetailRow extends StatelessWidget {
  const _DisabledDetailRow({
    required this.emoji,
    required this.label,
    required this.hint,
  });

  final String emoji;
  final String label;
  final String hint;

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
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  hint,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
