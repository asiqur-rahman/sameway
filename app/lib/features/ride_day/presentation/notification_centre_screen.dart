import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';

class NotificationCentreScreen extends StatelessWidget {
  const NotificationCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              'Notifications',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
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
              children: [
                _SectionHeader(label: 'TODAY'),
                _NotificationTile(
                  icon: '🚗',
                  title: 'Karim is on the way',
                  body: 'ETA to your pickup: 6 min',
                  time: '8:22 AM',
                  unread: true,
                ),
                _NotificationTile(
                  icon: '✅',
                  title: 'Ride confirmed for tomorrow',
                  body: 'Uttara → Motijheel · 8:30 AM',
                  time: '7:45 AM',
                ),
                _NotificationTile(
                  icon: '💬',
                  title: 'New message from Karim',
                  body: 'I\'ll be at the pickup point at 8:25',
                  time: '7:30 AM',
                ),
                const SizedBox(height: 16),
                _SectionHeader(label: 'YESTERDAY'),
                _NotificationTile(
                  icon: '⭐',
                  title: 'Rate your ride',
                  body: 'How was your commute with Karim?',
                  time: '6:15 PM',
                ),
                _NotificationTile(
                  icon: '🎉',
                  title: 'Ride completed',
                  body: 'Uttara → Motijheel · ৳80',
                  time: '9:45 AM',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });

  final String icon;
  final String title;
  final String body;
  final String time;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unread ? AppColors.primaryTint7 : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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
