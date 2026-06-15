import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_models.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class IncomingRequestsScreen extends StatelessWidget {
  const IncomingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final requests = AppDataStore.instance.pendingJoinRequests;
        final activeRide = AppDataStore.instance.activePostedRide;
        final subtitle = activeRide?.timeLabel ?? 'Your posted ride';

        return SamewayScreen(
          child: Column(
            children: [
              MobilePageHeader(
                title: 'Incoming Requests',
                subtitle: subtitle,
                backFallback: AppRoutes.home,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: InfoBanner(
                  emoji: '👥',
                  text:
                      'Review rider profiles before accepting. You can chat after confirming.',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: requests.isEmpty
                    ? Center(
                        child: Text(
                          'No pending requests',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          0,
                          AppSpacing.screenHorizontal,
                          24,
                        ),
                        itemCount: requests.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _RequestCard(request: requests[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final JoinRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SamewayDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.125),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  request.riderName[0],
                  style: GoogleFonts.inter(
                    fontSize: 18,
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
                    Row(
                      children: [
                        Text(
                          request.riderName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('✓', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                      ],
                    ),
                    Text(
                      request.route,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint7,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.matchLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.note,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      AppDataStore.instance.declineJoinRequest(request.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Decline',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      AppDataStore.instance.acceptJoinRequest(request.id),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Accept',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
