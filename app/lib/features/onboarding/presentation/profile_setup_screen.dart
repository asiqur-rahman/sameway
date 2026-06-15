import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/image_upload_card.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

enum CommuteType { drive, ride, both }

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  CommuteType _commuteType = CommuteType.drive;

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobilePageHeader(
              title: 'Set Up Profile',
              subtitle: 'Step 1 of 3',
              backFallback: AppRoutes.signUp,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ImageUploadCard(
                    title: 'Upload Photo',
                    subtitle: 'Helps build trust with co-riders',
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader('HOW DO YOU COMMUTE?'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SelectionCard(
                        emoji: '🚗',
                        title: 'I Drive',
                        subtitle: 'Offer rides',
                        selected: _commuteType == CommuteType.drive,
                        onTap: () =>
                            setState(() => _commuteType = CommuteType.drive),
                      ),
                      const SizedBox(width: 8),
                      SelectionCard(
                        emoji: '🧑‍🤝‍🧑',
                        title: 'I Ride',
                        subtitle: 'Find rides',
                        selected: _commuteType == CommuteType.ride,
                        onTap: () =>
                            setState(() => _commuteType = CommuteType.ride),
                      ),
                      const SizedBox(width: 8),
                      SelectionCard(
                        emoji: '🔄',
                        title: 'Both',
                        subtitle: 'Flexible',
                        selected: _commuteType == CommuteType.both,
                        onTap: () =>
                            setState(() => _commuteType = CommuteType.both),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SamewayDarkButton(
                    label: 'Continue',
                    onPressed: () => context.push(AppRoutes.vehicle),
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

