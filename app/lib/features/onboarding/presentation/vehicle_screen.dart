import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/onboarding/onboarding_state.dart';
import 'package:sameway/features/onboarding/presentation/widgets/vehicle_form_section.dart';

/// Legacy catalog route — vehicle details belong in [CommuteDetailsScreen] for drivers only.
class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final _formKey = GlobalKey<VehicleFormSectionState>();

  @override
  void initState() {
    super.initState();
    if (!OnboardingState.instance.isDriver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle details are only required if you drive. Riders skip this step.'),
          ),
        );
        context.go(AppRoutes.commuteDetails);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!OnboardingState.instance.isDriver) {
      return const SamewayScreen(child: SizedBox.shrink());
    }

    return SamewayScreen(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MobilePageHeader(
              title: 'Your Vehicle',
              subtitle: 'Drivers only · Step 2 of 3',
              backFallback: AppRoutes.commuteDetails,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: Column(
                children: [
                  VehicleFormSection(key: _formKey),
                  const SizedBox(height: 24),
                  SamewayDarkButton(
                    label: 'Continue',
                    onPressed: () {
                      if (_formKey.currentState?.validate(context) ?? false) {
                        OnboardingState.instance.hasVehicleDetails = true;
                        context.push(AppRoutes.workVerification);
                      }
                    },
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
