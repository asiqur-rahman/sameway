import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/home/presentation/widgets/home_widgets.dart';

class RouteConfirmedScreen extends StatelessWidget {
  const RouteConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          MobilePageHeader(
            title: 'Route Confirmed',
            subtitle: 'Review before posting',
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
                  height: 220,
                  showRoute: true,
                  startLabel: 'Uttara',
                  endLabel: 'Motijheel',
                  hint: 'Uttara → Motijheel',
                ),
                const SizedBox(height: 20),
                const SectionHeader('ROUTE SUMMARY'),
                const SizedBox(height: 12),
                const RouteTimeline(
                  route: 'Uttara Sector 4 → Motijheel',
                  schedule: '~45 min · 18.2 km via Airport Rd',
                ),
                const SizedBox(height: 16),
                const InfoBanner(
                  emoji: '✓',
                  text:
                      'Your route is saved. Next, set departure time, seats, and repeat schedule.',
                  tint: AppColors.primary,
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
              label: 'Confirm & Continue',
              onPressed: () => context.push(AppRoutes.postRideFilled),
            ),
          ),
        ],
      ),
    );
  }
}
