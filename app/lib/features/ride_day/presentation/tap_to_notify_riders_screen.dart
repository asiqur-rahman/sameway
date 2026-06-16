import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_banner.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/ride_day/ride_day_store.dart';

class TapToNotifyRidersScreen extends StatefulWidget {
  const TapToNotifyRidersScreen({super.key});

  @override
  State<TapToNotifyRidersScreen> createState() => _TapToNotifyRidersScreenState();
}

class _TapToNotifyRidersScreenState extends State<TapToNotifyRidersScreen> {
  final _store = RideDayStore.instance;

  @override
  void initState() {
    super.initState();
    _store.refreshLive();
  }

  Future<void> _notify() async {
    final count = await _store.notifyRiders();
    if (!mounted) return;
    if (count == null) {
      SamewayBanner.showWarning(context, 'No active ride to notify');
      return;
    }
    context.push(AppRoutes.afterHeadingOut);
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
                riders.isEmpty
                    ? 'No riders booked yet — you can still mark yourself as heading out.'
                    : 'Tap below to ping ${riders.length} rider${riders.length == 1 ? '' : 's'}.\nThey\'ll get a push notification instantly.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _store.notifying ? null : _notify,
                child: Opacity(
                  opacity: _store.notifying ? 0.6 : 1,
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
                        Text(
                          _store.notifying ? '⏳' : '📢',
                          style: const TextStyle(fontSize: 44),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _store.notifying ? 'Sending…' : 'Notify\nRiders',
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
              ),
              const SizedBox(height: 32),
              if (riders.isNotEmpty)
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
                        '${riders.length} rider${riders.length == 1 ? '' : 's'} will be notified',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final rider in riders) ...[
                        _RiderChip(name: rider.name),
                        if (rider != riders.last) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              const Spacer(),
              Text(
                live != null
                    ? 'Departure in ${live.minutesUntilDeparture} min · ${live.route}'
                    : '',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RiderChip extends StatelessWidget {
  const _RiderChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            name.isNotEmpty ? name.characters.first : '?',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const Icon(Icons.notifications_active_outlined, size: 18, color: AppColors.primary),
      ],
    );
  }
}
