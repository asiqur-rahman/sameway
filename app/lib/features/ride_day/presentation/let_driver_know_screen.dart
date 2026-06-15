import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';

class LetDriverKnowScreen extends StatelessWidget {
  const LetDriverKnowScreen({super.key});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let Karim know',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Karim is heading to your pickup point. Update your status so he knows what to expect.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _StatusButton(
            emoji: '✅',
            title: 'I\'m ready at the pickup point',
            subtitle: 'Standing at Uttara Sector 4 Gate',
            color: AppColors.primary,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _StatusButton(
            emoji: '🚶',
            title: 'On my way to pickup',
            subtitle: 'Be there in ~3 minutes',
            color: AppColors.textPrimary,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _StatusButton(
            emoji: '⏰',
            title: 'Running 5 min late',
            subtitle: 'Karim will be notified automatically',
            color: AppColors.textPrimary,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _StatusButton(
            emoji: '❌',
            title: 'Can\'t make it today',
            subtitle: 'Cancel this ride for today only',
            color: AppColors.error,
            onTap: () {},
          ),
          const Spacer(),
          Text(
            'Pickup in ~6 min · Toyota Allion',
            textAlign: TextAlign.center,
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

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
