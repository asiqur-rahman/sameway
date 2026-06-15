import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class RouteConfirmedScreen extends StatelessWidget {
  const RouteConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final draft = AppDataStore.instance.postRideDraft;
        final start = draft.startAddress ?? 'Start';
        final end = draft.endAddress ?? 'End';
        final segmentCount = 1 + draft.stops.length;

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
                    MapPlaceholder(
                      height: 130,
                      postRideShell: true,
                      showRoute: true,
                      startLabel: _short(start),
                      endLabel: _short(end),
                    ),
                    const SizedBox(height: 20),
                    PostRideRoutePoint(
                      sectionLabel: 'START (FROM)',
                      title: start,
                      subtitle: 'Google Maps verified',
                      showGpsBadge: true,
                    ),
                    for (final stop in draft.stops) ...[
                      const SizedBox(height: 12),
                      PostRideRoutePoint(
                        sectionLabel: 'STOP',
                        title: stop,
                        subtitle: 'Google Maps verified',
                        showGpsBadge: true,
                      ),
                    ],
                    const SizedBox(height: 12),
                    PostRideRoutePoint(
                      sectionLabel: 'END (TO)',
                      title: end,
                      subtitle: 'Google Maps verified',
                      showGpsBadge: true,
                    ),
                    const SizedBox(height: 16),
                    RouteTipBanner(
                      text:
                          'Why GPS coordinates matter: Riders searching from anywhere along this route will automatically appear as matches because their home falls within your route corridor ($segmentCount segment${segmentCount == 1 ? '' : 's'}).',
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
      },
    );
  }

  static String _short(String address) => address.split(',').first.trim();
}
