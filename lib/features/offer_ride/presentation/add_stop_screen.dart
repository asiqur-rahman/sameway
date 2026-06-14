import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class AddStopScreen extends StatelessWidget {
  AddStopScreen({super.key});

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          const MobilePageHeader(
            title: 'Add a Stop',
            backFallback: AppRoutes.pickEnd,
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
                  height: 400,
                  postRideShell: true,
                  hint: 'Drag to adjust pin',
                  interactive: true,
                  showZoomControls: true,
                ),
                const SizedBox(height: 16),
                SamewayTextField(
                  label: 'Search',
                  hint: AppPlaceholders.searchStop,
                  icon: '🔍',
                  controller: _searchController,
                ),
                const SizedBox(height: 16),
                const RouteTipBanner(
                  text:
                      'Adding a stop means riders boarding here will also see your ride. The stop is added to your route.',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              0,
              AppSpacing.screenHorizontal,
              12,
            ),
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.routeConfirmed),
              child: Center(
                child: Text(
                  'Skip — continue without a stop',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
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
              label: 'Confirm Stop & Review Route',
              textStyle: AppTypography.buttonDark,
              onPressed: () => context.push(AppRoutes.routeConfirmed),
            ),
          ),
        ],
      ),
    );
  }
}
