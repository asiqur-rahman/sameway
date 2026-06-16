import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/features/ride_day/ride_day_store.dart';

class PickupInScreen extends StatefulWidget {
  const PickupInScreen({super.key});

  @override
  State<PickupInScreen> createState() => _PickupInScreenState();
}

class _PickupInScreenState extends State<PickupInScreen> {
  final _store = RideDayStore.instance;

  @override
  void initState() {
    super.initState();
    _store.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final live = _store.live;
        final driver = live?.driver;
        final driverName = driver?.name ?? 'Your driver';

        return SamewayScreen(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            24,
            AppSpacing.screenHorizontal,
            24,
          ),
          child: _store.loadingLive && live == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const Spacer(),
                    Text(
                      'PICKUP IN',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${live?.minutesUntilDeparture ?? 0}',
                      style: GoogleFonts.inter(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'min',
                      style: GoogleFonts.inter(fontSize: 16, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      driver?.status == 'HEADING_OUT'
                          ? '$driverName is on the way'
                          : '$driverName · ${driver?.statusLabel ?? 'Confirmed'}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      live?.vehicleLabel ?? '',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('📍', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pickup point',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      live?.from ?? '—',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('🏢', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Destination',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      live?.to ?? '—',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
        );
      },
    );
  }
}
