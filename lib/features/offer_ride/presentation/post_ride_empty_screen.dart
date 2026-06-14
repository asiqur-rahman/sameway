import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class PostRideEmptyScreen extends StatelessWidget {
  const PostRideEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          const MobilePageHeader(
            title: 'Post a Ride',
            backFallback: AppRoutes.home,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                16,
              ),
              children: [
                const PostRideMapPreview(),
                const SizedBox(height: 20),
                const SectionHeader('YOUR ROUTE'),
                const SizedBox(height: 12),
                PostRideRouteBuilder(
                  onPickStart: () => context.push(AppRoutes.pickStart),
                  onPickEnd: () => context.push(AppRoutes.pickEnd),
                  onAddStop: () => context.push(AppRoutes.addStop),
                ),
                const SizedBox(height: 16),
                const RouteTipBanner(),
                const SizedBox(height: 20),
                const PostRideDisabledField(
                  label: 'DEPARTURE TIME',
                  emoji: '⏰',
                ),
                const SizedBox(height: 12),
                const PostRideDisabledField(
                  label: 'AVAILABLE SEATS',
                  emoji: '🚗',
                ),
                const SizedBox(height: 12),
                const PostRideDisabledField(
                  label: 'REPEAT',
                  emoji: '📅',
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              0,
              AppSpacing.screenHorizontal,
              24,
            ),
            child: PostRideDisabledButton(
              label: 'Set Route First to Continue',
            ),
          ),
        ],
      ),
    );
  }
}
