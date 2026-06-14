import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class PostRideFilledScreen extends StatefulWidget {
  const PostRideFilledScreen({super.key});

  @override
  State<PostRideFilledScreen> createState() => _PostRideFilledScreenState();
}

class _PostRideFilledScreenState extends State<PostRideFilledScreen> {
  int _seats = 2;
  int _repeatIndex = 2;

  static const _repeatOptions = ['Once', 'Daily', 'Weekdays'];

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          const MobilePageHeader(
            title: 'Post a Ride',
            backFallback: AppRoutes.routeConfirmed,
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
                  startLabel: 'Uttara',
                  endLabel: 'Motijheel',
                  hint: 'Custom multi-stop route',
                ),
                const SizedBox(height: 20),
                const SectionHeader('YOUR ROUTE'),
                const SizedBox(height: 12),
                const PostRideRoutePoint(
                  sectionLabel: 'START',
                  title: 'Uttara Sector 4, Dhaka',
                ),
                const SizedBox(height: 8),
                const PostRideRoutePoint(
                  sectionLabel: 'STOP 1',
                  title: 'Badda, Dhaka',
                ),
                const SizedBox(height: 8),
                const PostRideRoutePoint(
                  sectionLabel: 'END',
                  title: 'Motijheel, Dhaka',
                ),
                const SizedBox(height: 12),
                const RouteTipBanner(
                  text:
                      '3 segments created. Riders searching Uttara→Badda, Badda→Motijheel, or the full route will all discover your ride.',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: PostRideValueField(
                        label: 'DATE',
                        emoji: '📅',
                        value: 'Mon, Jun 13',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PostRideValueField(
                        label: 'TIME',
                        emoji: '⏰',
                        value: '8:30 AM',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('REPEAT', style: AppTypography.routeSectionLabel),
                const SizedBox(height: 5),
                Row(
                  children: [
                    for (var index = 0; index < _repeatOptions.length; index++) ...[
                      if (index > 0) const SizedBox(width: 8),
                      Expanded(
                        child: PostRideRepeatChip(
                          label: _repeatOptions[index],
                          selected: _repeatIndex == index,
                          onTap: () => setState(() => _repeatIndex = index),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                PostRideSeatsStepper(
                  value: _seats,
                  onDecrement: () {
                    if (_seats > 1) setState(() => _seats--);
                  },
                  onIncrement: () {
                    if (_seats < 4) setState(() => _seats++);
                  },
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
              label: 'Post Ride',
              textStyle: AppTypography.buttonDark,
              onPressed: () => context.go(AppRoutes.incomingRequests),
            ),
          ),
        ],
      ),
    );
  }
}
