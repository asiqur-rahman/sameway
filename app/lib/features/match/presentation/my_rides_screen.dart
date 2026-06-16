import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/api/repositories/rides_repository.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_models.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_banner.dart';
import 'package:sameway/core/widgets/sameway_bottom_nav.dart';
import 'package:sameway/core/widgets/sameway_loading.dart';
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

  Future<void> _cancelRide(UserRide ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          ride.isDriver ? 'Cancel ride?' : 'Cancel booking?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          ride.isDriver
              ? 'This will cancel the ride for all passengers.'
              : 'You will be removed from this ride.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel ride'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await RidesRepository.instance.cancelRide(ride.id);
      if (!mounted) return;
      SamewayBanner.showSuccess(context, 'Ride cancelled');
      AppDataStore.instance.refreshBookings(refresh: true);
    } catch (e) {
      if (!mounted) return;
      SamewayBanner.showError(context, e);
    }
  }

  void _rateRide(UserRide ride) {
    final currentUserId = AppSession.instance.currentUser?.id ?? '';
    final targetUserId = ride.isDriver
        ? null // driver rates a rider — not implemented yet
        : ride.driverUserId;
    final targetName = ride.isDriver ? 'your rider' : (ride.driverName ?? 'your driver');

    if (targetUserId == null || targetUserId.isEmpty) {
      SamewayBanner.showInfo(context, 'Driver info not available for this ride.');
      return;
    }

    context.push(
      AppRoutes.rateRide,
      extra: {
        'rideId': ride.id,
        'targetUserId': targetUserId,
        'targetName': targetName,
        'isDriver': !ride.isDriver, // rider rates the driver
        'currentUserId': currentUserId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final store = AppDataStore.instance;
        final upcoming = store.upcomingRides;
        final completed = store.completedRides;
        final rides = _tabIndex == 0 ? upcoming : completed;
        final isLoading = store.isLoadingBookings && !store.isRefreshingBookings;

        return SamewayScreen(
          bottomNavigationBar: const SamewayBottomNav(currentIndex: 1),
          child: Column(
            children: [
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
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
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => store.refreshBookings(refresh: true),
                  child: isLoading
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenHorizontal,
                            16,
                            AppSpacing.screenHorizontal,
                            24,
                          ),
                          children: const [
                            RideCardSkeleton(),
                            SizedBox(height: 12),
                            RideCardSkeleton(),
                            SizedBox(height: 12),
                            RideCardSkeleton(),
                          ],
                        )
                      : rides.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: MediaQuery.sizeOf(context).height * 0.28,
                                ),
                                AsyncContent(
                                  isLoading: false,
                                  isEmpty: true,
                                  emptyIcon: _tabIndex == 0 ? '🗓️' : '✅',
                                  emptyMessage: _tabIndex == 0
                                      ? 'No upcoming rides yet.\nSearch or post a ride to get started.'
                                      : 'No completed rides yet.',
                                  child: const SizedBox.shrink(),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.screenHorizontal,
                                16,
                                AppSpacing.screenHorizontal,
                                24,
                              ),
                              itemCount: rides.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) => _RideCard(
                                ride: rides[index],
                                showCancel:
                                    _tabIndex == 0 && rides[index].isUpcoming,
                                showRate: _tabIndex == 1 &&
                                    rides[index].status == RideStatus.completed &&
                                    !rides[index].isDriver,
                                onCancel: () => _cancelRide(rides[index]),
                                onRate: () => _rateRide(rides[index]),
                              ),
                            ),
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
  const _RideCard({
    required this.ride,
    required this.showCancel,
    required this.showRate,
    required this.onCancel,
    required this.onRate,
  });

  final UserRide ride;
  final bool showCancel;
  final bool showRate;
  final VoidCallback onCancel;
  final VoidCallback onRate;

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
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUpcoming ? AppColors.primaryTint12 : AppColors.surfaceMuted,
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

          // Route
          Text(
            ride.route,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),

          // Action row
          if (showCancel || showRate) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (showRate)
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: FilledButton.icon(
                        onPressed: onRate,
                        icon: const Icon(Icons.star_outline_rounded, size: 16),
                        label: Text(
                          'Rate ride',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                if (showCancel)
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel ride',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
