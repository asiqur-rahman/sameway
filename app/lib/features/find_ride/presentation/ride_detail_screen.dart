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
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/features/find_ride/find_ride_flow.dart';
import 'package:sameway/features/find_ride/presentation/widgets/find_ride_widgets.dart';
import 'package:sameway/features/home/presentation/widgets/home_widgets.dart';

/// Wireframe v2 — ScreenRideDetail.
class RideDetailScreen extends StatelessWidget {
  const RideDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listing = FindRideFlow.instance.selectedRide ?? sampleFindRideListings.first;
    final seatsTaken = listing.coRiderName != null ? 1 : 0;
    final seatsAvailable = listing.seats;

    return SamewayScreen(
      child: Column(
        children: [
          MobilePageHeader(
            title: 'Ride Details',
            backFallback: AppRoutes.searchResults,
            trailing: Text(
              '⎙',
              style: GoogleFonts.inter(fontSize: 20, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                14,
                AppSpacing.screenHorizontal,
                24,
              ),
              children: [
                _DriverCard(listing: listing),
                const SizedBox(height: 14),
                const SectionHeader('ROUTE'),
                const SizedBox(height: 10),
                _RouteCard(listing: listing),
                const SizedBox(height: 12),
                const MapPlaceholder(
                  height: 110,
                  showRoute: true,
                  hint: 'Tap to view full route',
                ),
                const SizedBox(height: 12),
                FindRouteMatchCard(overlap: listing.overlap),
                const SizedBox(height: 16),
                SectionHeader('CO-RIDERS ($seatsTaken of ${seatsTaken + seatsAvailable} seats taken)'),
                const SizedBox(height: 10),
                if (listing.coRiderName != null)
                  Row(
                    children: [
                      _CoRiderAvatar(initial: listing.coRiderInitial ?? '?'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${listing.coRiderName} · $seatsAvailable seats still available',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '$seatsAvailable seats still available',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                  ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Driver's note",
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.driverNote,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '💡 Suggested split: ~৳50–80/day · Settle directly with driver',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
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
            child: SamewayDarkButton(
              label: 'Request to Join →',
              onPressed: () async {
                final flow = FindRideFlow.instance;
                try {
                  await AppDataStore.instance.requestJoinRide(
                    rideId: listing.id,
                    driverName: listing.driverFullName,
                    route: '${listing.from} → ${listing.to}',
                    from: listing.from,
                    to: listing.to,
                    timeLabel: '${flow.dateLabel.isEmpty ? 'Today' : flow.dateLabel} · ${listing.departTime}',
                    detail: 'Driver: ${listing.driverFullName} · ${listing.seats} seat${listing.seats == 1 ? '' : 's'}',
                    matchLabel: '${listing.overlap}% match',
                  );
                  flow.lastRequestChatThreadId = null;
                  flow.lastRequestDriverName = listing.driverName.replaceAll('.', '').split(' ').first;
                  if (context.mounted) context.push(AppRoutes.requestSent);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.listing});

  final FindRideListing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: SamewayDecorations.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              listing.driverInitial,
              style: GoogleFonts.inter(
                fontSize: 28,
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
                Text(
                  listing.driverFullName,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                FindVerifyBadge(org: listing.company),
                const SizedBox(height: 8),
                FindKudosStrip(
                  rides: listing.rides,
                  onTimePct: listing.onTimePct,
                  kudos: listing.kudos,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    PreferenceChip(label: listing.vehicleLabel, selected: true),
                    PreferenceChip(label: listing.vehicleDetail),
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

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.listing});

  final FindRideListing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: SamewayDecorations.card(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(width: 2, height: 42, color: AppColors.border),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(3),
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
                      'START · ${listing.departTime}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      listing.from,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'END · ${listing.arriveTime}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      listing.to,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FindPickupBanner(
            label: listing.pickupLabel,
            detail: listing.pickupDetail,
          ),
        ],
      ),
    );
  }
}

class _CoRiderAvatar extends StatelessWidget {
  const _CoRiderAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            initial,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 1),
            ),
            alignment: Alignment.center,
            child: const Text('✓', style: TextStyle(fontSize: 7, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
