import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_bottom_nav.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_tab_switcher.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      bottomNavigationBar: const SamewayBottomNav(currentIndex: 1),
      child: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              'MY RIDES',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              12,
              AppSpacing.screenHorizontal,
              0,
            ),
            child: SamewayTabSwitcher(
              tabs: const ['Upcoming', 'Completed'],
              selectedIndex: _tabIndex,
              onChanged: (index) => setState(() => _tabIndex = index),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                16,
                AppSpacing.screenHorizontal,
                24,
              ),
              children: _tabIndex == 0
                  ? const [
                      _RideCard(
                        status: 'Tomorrow · 8:30 AM',
                        route: 'Uttara Sector 4 → Motijheel',
                        detail: 'Driver: Karim Rahman · 2 seats',
                        isUpcoming: true,
                      ),
                      SizedBox(height: 12),
                      _RideCard(
                        status: 'Fri, Jun 20 · 8:30 AM',
                        route: 'Uttara Sector 4 → Motijheel',
                        detail: 'Driver: Karim Rahman · 2 seats',
                        isUpcoming: true,
                      ),
                    ]
                  : const [
                      _RideCard(
                        status: 'Jun 12 · Completed',
                        route: 'Uttara Sector 4 → Motijheel',
                        detail: 'Driver: Karim Rahman · ৳80',
                        isUpcoming: false,
                      ),
                      SizedBox(height: 12),
                      _RideCard(
                        status: 'Jun 11 · Completed',
                        route: 'Uttara Sector 4 → Gulshan 1',
                        detail: 'Driver: Tanvir Hossain · ৳60',
                        isUpcoming: false,
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({
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
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? AppColors.primaryTint12
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isUpcoming ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            route,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
