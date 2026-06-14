import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';

class DepartureInScreen extends StatelessWidget {
  const DepartureInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        24,
        AppSpacing.screenHorizontal,
        24,
      ),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'DEPARTURE IN',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '12:45',
            style: GoogleFonts.inter(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              letterSpacing: -2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Uttara Sector 4 → Motijheel',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '2 riders confirmed · 8:30 AM departure',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMuted,
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
              children: [
                _RiderRow(name: 'Rafiq Ahmed', status: 'Confirmed'),
                const Divider(height: 16, color: AppColors.border),
                _RiderRow(name: 'Sadia Khan', status: 'Confirmed'),
              ],
            ),
          ),
          const Spacer(),
          SamewayPrimaryButton(
            label: '📢 Notify riders I\'m heading out',
            backgroundColor: AppColors.primaryDark,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _RiderRow extends StatelessWidget {
  const _RiderRow({required this.name, required this.status});

  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            name.characters.first,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          status,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
