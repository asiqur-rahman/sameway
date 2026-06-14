import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/home/presentation/widgets/home_widgets.dart';

class RideDetailScreen extends StatelessWidget {
  const RideDetailScreen({super.key});

  static const _reviews = [
    _Review(author: 'Rafiq A.', text: 'Punctual and friendly — great daily commute.'),
    _Review(author: 'Sadia K.', text: 'Clean car, smooth ride through traffic.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          MobilePageHeader(
            title: 'Ride Detail',
            backFallback: AppRoutes.searchResults,
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
                  height: 200,
                  showRoute: true,
                  startLabel: 'Uttara',
                  endLabel: 'Motijheel',
                ),
                const SizedBox(height: 20),
                _DriverHeader(),
                const SizedBox(height: 16),
                const SectionHeader('ROUTE'),
                const SizedBox(height: 10),
                const RouteTimeline(
                  route: 'Uttara Sector 4 → Motijheel',
                  schedule: 'Today · 8:30 AM · 2 seats available',
                ),
                const SizedBox(height: 20),
                const SectionHeader('RECENT REVIEWS'),
                const SizedBox(height: 10),
                ..._reviews.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReviewTile(review: review),
                  ),
                ),
                const SizedBox(height: 8),
                const InfoBanner(
                  emoji: '💬',
                  text:
                      'After the driver accepts, you can chat to coordinate pickup and cost split.',
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
              label: 'Request to Join',
              onPressed: () => context.push(AppRoutes.requestSent),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SamewayDecorations.card(),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.125),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              'K',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Karim Rahman',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint7,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '✓ Verified',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '⭐ 4.9 · 48 rides · Grameenphone',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    PreferenceChip(label: '🚗 Toyota Allion', selected: true),
                    PreferenceChip(label: '💺 2 seats'),
                    PreferenceChip(label: '92% match', selected: true),
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

class _Review {
  const _Review({required this.author, required this.text});

  final String author;
  final String text;
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final _Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: SamewayDecorations.mutedInset(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review.author,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            review.text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
