import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/features/ride_day/ride_day_store.dart';

class LetDriverKnowScreen extends StatefulWidget {
  const LetDriverKnowScreen({super.key});

  @override
  State<LetDriverKnowScreen> createState() => _LetDriverKnowScreenState();
}

class _LetDriverKnowScreenState extends State<LetDriverKnowScreen> {
  final _store = RideDayStore.instance;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _store.refreshLive();
  }

  Future<void> _setStatus(String status, String message) async {
    setState(() => _updating = true);
    try {
      await _store.updateMyStatus(status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final live = _store.live;
        final driverName = live?.driver?.name ?? 'your driver';
        final pickup = live?.from ?? 'pickup point';

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
                'Let $driverName know',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$driverName is heading to your pickup point. Update your status so they know what to expect.',
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
                subtitle: 'Standing at $pickup',
                color: AppColors.primary,
                onTap: _updating
                    ? null
                    : () => _setStatus('AT_PICKUP', 'Driver notified — you\'re ready'),
              ),
              const SizedBox(height: 12),
              _StatusButton(
                emoji: '🚶',
                title: 'On my way to pickup',
                subtitle: 'Be there shortly',
                color: AppColors.textPrimary,
                onTap: _updating
                    ? null
                    : () => _setStatus('ON_WAY', 'Driver notified — on your way'),
              ),
              const SizedBox(height: 12),
              _StatusButton(
                emoji: '⏰',
                title: 'Running 5 min late',
                subtitle: '$driverName will be notified automatically',
                color: AppColors.textPrimary,
                onTap: _updating
                    ? null
                    : () => _setStatus('LATE', 'Driver notified — running late'),
              ),
              const SizedBox(height: 12),
              _StatusButton(
                emoji: '❌',
                title: 'Can\'t make it today',
                subtitle: 'Cancel this ride for today only',
                color: AppColors.error,
                onTap: _updating
                    ? null
                    : () => _setStatus('CANCELLED', 'Ride cancelled for today'),
              ),
              const Spacer(),
              Text(
                live != null
                    ? 'Pickup in ~${live.minutesUntilDeparture} min · ${live.vehicleLabel}'
                    : '',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        );
      },
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
  final VoidCallback? onTap;

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
