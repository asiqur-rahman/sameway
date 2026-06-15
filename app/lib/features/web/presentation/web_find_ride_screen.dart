import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/web_scaffold.dart';

class WebFindRideScreen extends StatelessWidget {
  WebFindRideScreen({super.key});

  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      activeNav: 'Find a Ride',
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find a Ride',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SamewayTextField(
                      label: 'From',
                      icon: '📍',
                      hint: AppPlaceholders.from,
                      controller: _fromController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SamewayTextField(
                      label: 'To',
                      icon: '🏢',
                      hint: AppPlaceholders.to,
                      controller: _toController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SamewayTextField(
                      label: 'Date',
                      hint: AppPlaceholders.date,
                      controller: _dateController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SamewayTextField(
                      label: 'Arrive by',
                      hint: AppPlaceholders.arriveBy,
                      controller: _timeController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SamewayPrimaryButton(
                    label: 'Search',
                    backgroundColor: AppColors.primaryDark,
                    height: 47,
                    borderRadius: 10,
                    fontSize: 14,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'MATCHED ROUTES',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _MatchCard(
                    driver: 'Karim Rahman',
                    route: 'Uttara Sector 4 → Motijheel',
                    time: '8:30 AM · 2 seats',
                    rating: '4.8',
                  ),
                  const SizedBox(height: 12),
                  _MatchCard(
                    driver: 'Tanvir Hossain',
                    route: 'Uttara House Building → Motijheel',
                    time: '8:45 AM · 1 seat',
                    rating: '4.6',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.driver,
    required this.route,
    required this.time,
    required this.rating,
  });

  final String driver;
  final String route;
  final String time;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              driver.characters.first,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  route,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '⭐ $rating',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          const SizedBox(width: 16),
          SamewayPrimaryButton(
            label: 'Request',
            height: 40,
            borderRadius: 8,
            fontSize: 13,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
