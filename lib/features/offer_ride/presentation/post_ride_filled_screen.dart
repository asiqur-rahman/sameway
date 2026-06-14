import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/home/presentation/widgets/home_widgets.dart';

class PostRideFilledScreen extends StatelessWidget {
  const PostRideFilledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          MobilePageHeader(
            title: 'Post a Ride',
            subtitle: 'Almost ready to publish',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                24,
              ),
              children: [
                const MapPlaceholder(
                  height: 160,
                  showRoute: true,
                  startLabel: 'Uttara',
                  endLabel: 'Motijheel',
                ),
                const SizedBox(height: 20),
                const SectionLabel(label: 'YOUR ROUTE'),
                const SizedBox(height: 12),
                const RouteTimeline(
                  route: 'Uttara Sector 4 → Motijheel',
                  schedule: 'Mon–Fri · 8:30 AM · 2 seats available',
                ),
                const SizedBox(height: 20),
                const SectionHeader('RIDE DETAILS'),
                const SizedBox(height: 8),
                const FlowStepRow(
                  emoji: '🕐',
                  label: '8:30 AM departure',
                  done: true,
                ),
                const FlowStepRow(
                  emoji: '💺',
                  label: '2 seats available',
                  done: true,
                ),
                const FlowStepRow(
                  emoji: '🔁',
                  label: 'Mon–Fri repeat',
                  done: true,
                ),
                const SizedBox(height: 16),
                const InfoBanner(
                  emoji: '🚗',
                  text:
                      'Toyota Allion · GPS verified · Riders along your route will see this ride.',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              0,
              AppSpacing.screenHorizontal,
              24,
            ),
            child: SamewayPrimaryButton(
              label: 'Post Ride',
              onPressed: () => context.go(AppRoutes.incomingRequests),
            ),
          ),
        ],
      ),
    );
  }
}
