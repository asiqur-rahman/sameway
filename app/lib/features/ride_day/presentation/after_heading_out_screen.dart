import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/ride_day/ride_day_store.dart';

class AfterHeadingOutScreen extends StatefulWidget {
  const AfterHeadingOutScreen({super.key});

  @override
  State<AfterHeadingOutScreen> createState() => _AfterHeadingOutScreenState();
}

class _AfterHeadingOutScreenState extends State<AfterHeadingOutScreen> {
  final _store = RideDayStore.instance;

  @override
  void initState() {
    super.initState();
    _store.refreshLive();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final live = _store.live;
        final riders = live?.riders ?? [];

        return SamewayScreen(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            8,
            AppSpacing.screenHorizontal,
            24,
          ),
          child: Column(
            children: [
              MobilePageHeader(
                title: 'After Heading Out',
                subtitle: 'RIDE DAY · DRIVER',
                backFallback: AppRoutes.tapToNotify,
              ),
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint12,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  live?.vehicleLabel.isNotEmpty == true
                      ? live!.vehicleLabel.characters.first
                      : '🚗',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'You\'re on the way!',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                riders.isEmpty
                    ? 'Riders notified. Head to your first pickup when ready.'
                    : 'Riders have been notified. Pick up ${riders.first.name} first.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: riders.isEmpty
                    ? Center(
                        child: Text(
                          'No riders on this ride',
                          style: GoogleFonts.inter(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: riders.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final rider = riders[index];
                          return _PickupCard(
                            name: rider.name,
                            location: live?.from ?? '',
                            isNext: index == 0,
                          );
                        },
                      ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Final destination: ${live?.to ?? '—'}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PickupCard extends StatelessWidget {
  const _PickupCard({
    required this.name,
    required this.location,
    required this.isNext,
  });

  final String name;
  final String location;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isNext ? AppColors.primary : AppColors.border,
          width: isNext ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name.characters.first : '?',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  location,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (isNext)
            Text(
              'Next',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
