import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class WorkLocationScreen extends StatelessWidget {
  WorkLocationScreen({super.key});

  final _officeController = TextEditingController();
  final _homeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobilePageHeader(
              title: 'Work Location',
              subtitle: 'Step 3 of 3',
              backFallback: AppRoutes.vehicle,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SamewayTextField(
                    label: 'Office Address',
                    icon: '🏢',
                    hint: AppPlaceholders.officeAddress,
                    controller: _officeController,
                  ),
                  const SizedBox(height: 12),
                  SamewayTextField(
                    label: 'Home Address',
                    icon: '📍',
                    hint: AppPlaceholders.homeAddress,
                    controller: _homeController,
                  ),
                  const SizedBox(height: 16),
                  const MapPlaceholder(
                    height: 160,
                    hint: 'Your commute route will appear here',
                  ),
                  const SizedBox(height: 32),
                  SamewayDarkButton(
                    label: 'Continue',
                    onPressed: () => context.push(AppRoutes.officeId),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

