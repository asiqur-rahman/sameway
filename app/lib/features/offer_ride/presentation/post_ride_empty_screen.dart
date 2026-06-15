import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class PostRideEmptyScreen extends StatelessWidget {
  const PostRideEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final draft = AppDataStore.instance.postRideDraft;
        final hasRoute = draft.hasRoute;

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
                    PostRideMapPreview(
                      startLabel: _short(draft.startAddress),
                      endLabel: _short(draft.endAddress),
                      showRoute: hasRoute,
                    ),
                    const SizedBox(height: 20),
                    const SectionHeader('YOUR ROUTE'),
                    const SizedBox(height: 12),
                    PostRideRouteBuilder(
                      startValue: draft.startAddress,
                      endValue: draft.endAddress,
                      onPickStart: () => context.push(AppRoutes.pickStart),
                      onPickEnd: () => context.push(AppRoutes.pickEnd),
                      onAddStop: () => context.push(AppRoutes.addStop),
                    ),
                    if (draft.stops.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      for (final stop in draft.stops)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PostRideRoutePoint(
                            sectionLabel: 'STOP',
                            title: stop,
                          ),
                        ),
                    ],
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  0,
                  AppSpacing.screenHorizontal,
                  24,
                ),
                child: hasRoute
                    ? SamewayDarkButton(
                        label: 'Continue →',
                        onPressed: () => context.push(AppRoutes.routeConfirmed),
                      )
                    : const PostRideDisabledButton(
                        label: 'Set Route First to Continue',
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String? _short(String? address) {
    if (address == null || address.trim().isEmpty) return null;
    return address.split(',').first.trim();
  }
}
