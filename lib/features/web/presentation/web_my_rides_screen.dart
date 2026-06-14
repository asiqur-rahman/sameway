import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/web_scaffold.dart';

class WebMyRidesScreen extends StatelessWidget {
  const WebMyRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Rides',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _RideRow(
                    status: 'Upcoming',
                    route: 'Uttara Sector 4 → Motijheel',
                    detail: 'Tomorrow · 8:30 AM · Driver: Karim Rahman',
                    isUpcoming: true,
                  ),
                  const SizedBox(height: 12),
                  _RideRow(
                    status: 'Upcoming',
                    route: 'Uttara Sector 4 → Motijheel',
                    detail: 'Fri, Jun 20 · 8:30 AM · Driver: Karim Rahman',
                    isUpcoming: true,
                  ),
                  const SizedBox(height: 12),
                  _RideRow(
                    status: 'Completed',
                    route: 'Uttara Sector 4 → Motijheel',
                    detail: 'Jun 12 · ৳80 · Driver: Karim Rahman',
                    isUpcoming: false,
                  ),
                  const SizedBox(height: 12),
                  _RideRow(
                    status: 'Completed',
                    route: 'Uttara Sector 4 → Gulshan 1',
                    detail: 'Jun 11 · ৳60 · Driver: Tanvir Hossain',
                    isUpcoming: false,
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

class _RideRow extends StatelessWidget {
  const _RideRow({
    required this.status,
    required this.route,
    required this.detail,
    required this.isUpcoming,
  });

  final String status;
  final String route;
  final String detail;
  final bool isUpcoming;

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isUpcoming
                  ? AppColors.primaryTint12
                  : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUpcoming ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detail,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMuted,
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
