import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class TapToNotifyRidersScreen extends StatelessWidget {
  const TapToNotifyRidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            title: 'Tap to Notify',
            subtitle: 'Let riders know you\'re heading out',
            backFallback: AppRoutes.departureIn,
          ),
          const Spacer(),
          Text(
            'TAP TO NOTIFY RIDERS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ready to leave?',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap below to ping Rafiq and Sadia.\nThey\'ll get a push notification instantly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.push(AppRoutes.afterHeadingOut),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📢', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 6),
                  Text(
                    'Notify\nRiders',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2 riders will be notified',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                _RiderChip(name: 'Rafiq Ahmed', location: 'Uttara Sector 4 Gate'),
                const SizedBox(height: 8),
                _RiderChip(name: 'Sadia Khan', location: 'Uttara House Building'),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Departure in 12 min · Uttara → Motijheel',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiderChip extends StatelessWidget {
  const _RiderChip({required this.name, required this.location});

  final String name;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            name.characters.first,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                location,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.notifications_active_outlined, size: 18, color: AppColors.primary),
      ],
    );
  }
}
