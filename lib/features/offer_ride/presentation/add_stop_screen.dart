import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
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
          MobilePageHeader(
            title: 'Add a Stop',
            subtitle: 'Optional — pick up riders along the way',
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
                  height: 400,
                  hint: 'Tap map to add an optional stop',
                ),
                const SizedBox(height: 16),
                SamewayTextField(
                  label: 'Search',
                  hint: 'Search stop location',
                  icon: '🔍',
                  controller: _searchController,
                ),
                const SizedBox(height: 16),
                const InfoBanner(
                  emoji: '💡',
                  text:
                      'Stops help riders join along your route. You can skip this and add stops later.',
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
            child: SamewayPrimaryButton(
              label: 'Confirm Stop & Review Route',
              onPressed: () => context.push(AppRoutes.routeConfirmed),
            ),
          ),
        ],
      ),
    );
  }
}
