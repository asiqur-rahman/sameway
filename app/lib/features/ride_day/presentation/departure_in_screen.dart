import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/features/ride_day/ride_day_store.dart';

class DepartureInScreen extends StatefulWidget {
  const DepartureInScreen({super.key});

  @override
  State<DepartureInScreen> createState() => _DepartureInScreenState();
}

class _DepartureInScreenState extends State<DepartureInScreen> {
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
        final today = _store.today;
        final riders = live?.riders ?? [];

        return SamewayScreen(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            24,
            AppSpacing.screenHorizontal,
            24,
          ),
          child: _store.loadingToday && live == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                      live?.departureTimeLabel ?? today?.departureTimeLabel ?? '--:--',
                      style: GoogleFonts.inter(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      live?.route ?? today?.route ?? 'No ride scheduled today',
                      style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary),
                    ),
                    Text(
                      '${riders.length} rider${riders.length == 1 ? '' : 's'} confirmed · '
                      '${live?.minutesUntilDeparture ?? today?.minutesUntilDeparture ?? 0} min until departure',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 32),
                    if (riders.isEmpty)
                      Text(
                        'No confirmed riders yet',
                        style: GoogleFonts.inter(color: AppColors.textMuted),
                      )
                    else
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
                            for (var i = 0; i < riders.length; i++) ...[
                              if (i > 0) const Divider(height: 16, color: AppColors.border),
                              _RiderRow(name: riders[i].name, status: riders[i].statusLabel),
                            ],
                          ],
                        ),
                      ),
                    const Spacer(),
                    if (today?.isDriver == true || live?.isDriver == true)
                      SamewayDarkButton(
                        label: 'Continue to notify riders',
                        onPressed: live == null && today == null
                            ? null
                            : () => context.push(AppRoutes.tapToNotify),
                      ),
                  ],
                ),
        );
      },
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
            name.isNotEmpty ? name.characters.first : '?',
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
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
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
