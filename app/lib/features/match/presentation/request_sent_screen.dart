import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_secondary_button.dart';
import 'package:sameway/features/find_ride/find_ride_flow.dart';

class RequestSentScreen extends StatelessWidget {
  const RequestSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = FindRideFlow.instance;
    final driverName = flow.lastRequestDriverName ?? 'the driver';
    final threadId = flow.lastRequestChatThreadId;

    final steps = [
      _Step(
        icon: '✉️',
        title: '$driverName is notified',
        subtitle: 'They get your ride request instantly',
      ),
      const _Step(
        icon: '👀',
        title: 'Driver reviews your profile',
        subtitle: 'Ratings, route match, and preferences',
      ),
      _Step(
        icon: '✅',
        title: 'Ride confirmed',
        subtitle: 'You\'ll get a push when $driverName accepts',
      ),
      const _Step(
        icon: '💬',
        title: 'Chat opens',
        subtitle: 'Coordinate pickup and cost split',
      ),
    ];

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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('✅', style: TextStyle(fontSize: 36)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Request Sent!',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Your request to join $driverName\'s ride is waiting for approval.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'WHAT HAPPENS NEXT',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...steps.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StepRow(step: step),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SamewayDarkButton(
            label: '💬 Chat with $driverName',
            onPressed: threadId == null
                ? () => context.go(AppRoutes.chat)
                : () => context.go('${AppRoutes.chatConversation}?threadId=$threadId'),
          ),
          const SizedBox(height: 10),
          SamewaySecondaryButton(
            label: 'Browse more rides',
            outlined: true,
            onPressed: () => context.go(AppRoutes.searchResults),
          ),
        ],
      ),
    );
  }
}

class _Step {
  const _Step({required this.icon, required this.title, required this.subtitle});

  final String icon;
  final String title;
  final String subtitle;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});

  final _Step step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(step.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  step.subtitle,
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
    );
  }
}
