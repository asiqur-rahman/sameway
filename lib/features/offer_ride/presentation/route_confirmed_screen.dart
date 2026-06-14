import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class RouteConfirmedScreen extends StatelessWidget {
  const RouteConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          const MobilePageHeader(
            title: 'Post a Ride',
            subtitle: 'Route confirmed',
            backFallback: AppRoutes.addStop,
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
                  height: 130,
                  postRideShell: true,
                  showRoute: true,
                  distanceLabel: '~28 km',
                  startLabel: 'Uttara',
                  endLabel: 'Motijheel',
                ),
                const SizedBox(height: 20),
                const PostRideRoutePoint(
                  sectionLabel: 'START (FROM)',
                  title: 'Uttara Sector 4, Dhaka',
                  subtitle: '23.8759°N, 90.3795°E · Google Maps verified',
                  showGpsBadge: true,
                ),
                const SizedBox(height: 12),
                const PostRideRoutePoint(
                  sectionLabel: 'END (TO)',
                  title: 'Motijheel, Dhaka',
                  subtitle: '23.7279°N, 90.4174°E · Google Maps verified',
                  showGpsBadge: true,
                ),
                const SizedBox(height: 16),
                const RouteTipBanner(
                  text:
                      'Why GPS coordinates matter: Riders searching from anywhere along this 28km route — like Mirpur or Farmgate — will automatically appear as matches because their home falls within your route corridor.',
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
            child: SamewayDarkButton(
              label: 'Confirm & Continue →',
              textStyle: AppTypography.buttonDarkRobotoRegular,
              onPressed: () => context.push(AppRoutes.postRideFilled),
            ),
          ),
        ],
      ),
    );
  }
}
