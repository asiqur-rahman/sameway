import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/session/app_data_models.dart';
import 'package:sameway/core/session/app_data_store.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppDataStore.instance.refreshBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final upcoming = AppDataStore.instance.upcomingRides;
        final completed = AppDataStore.instance.completedRides;
        final rides = _tabIndex == 0 ? upcoming : completed;

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
                child: rides.isEmpty
                    ? Center(
                        child: Text(
                          _tabIndex == 0
                              ? 'No upcoming rides yet'
                              : 'No completed rides yet',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          16,
                          AppSpacing.screenHorizontal,
                          24,
                        ),
                        itemCount: rides.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _RideCard(ride: rides[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({required this.ride});

  final UserRide ride;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = ride.isUpcoming;
    final statusLabel = ride.status == RideStatus.pending
        ? 'Pending · ${ride.timeLabel}'
        : ride.timeLabel;
    final detail = ride.isDriver
        ? ride.detail
        : 'Driver: ${ride.driverName ?? 'Unknown'} · ${ride.detail}';

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUpcoming
                  ? AppColors.primaryTint12
                  : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isUpcoming ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ride.route,
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
