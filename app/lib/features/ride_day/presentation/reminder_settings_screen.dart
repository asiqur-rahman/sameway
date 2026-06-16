import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/api/models/reminder_settings.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/features/ride_day/ride_day_store.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final _store = RideDayStore.instance;

  @override
  void initState() {
    super.initState();
    _store.refreshReminderSettings();
  }

  void _update(ReminderSettings settings) {
    _store.saveReminderSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final s = _store.reminders;

        return SamewayScreen(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            16,
            AppSpacing.screenHorizontal,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminder Settings',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Push notifications for ride day events',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              _SectionLabel(title: 'DRIVER REMINDERS'),
              _ToggleTile(
                title: 'Departure reminder',
                subtitle: '15 min before your scheduled departure',
                value: s.driverDeparture,
                onChanged: (v) => _update(s.copyWith(driverDeparture: v)),
              ),
              _ToggleTile(
                title: 'Notify riders prompt',
                subtitle: 'Remind to tap "Notify riders" when heading out',
                value: s.driverNotifyRiders,
                onChanged: (v) => _update(s.copyWith(driverNotifyRiders: v)),
              ),
              const SizedBox(height: 16),
              _SectionLabel(title: 'RIDER REMINDERS'),
              _ToggleTile(
                title: 'Pickup reminder',
                subtitle: '10 min before driver arrives at pickup',
                value: s.riderPickup,
                onChanged: (v) => _update(s.copyWith(riderPickup: v)),
              ),
              _ToggleTile(
                title: 'Let driver know',
                subtitle: 'Prompt to confirm you\'re ready or running late',
                value: s.riderLetDriverKnow,
                onChanged: (v) => _update(s.copyWith(riderLetDriverKnow: v)),
              ),
              const SizedBox(height: 16),
              _SectionLabel(title: 'GENERAL'),
              _ToggleTile(
                title: 'Daily ride summary',
                subtitle: 'Morning digest of today\'s rides',
                value: s.dailySummary,
                onChanged: (v) => _update(s.copyWith(dailySummary: v)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
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

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
