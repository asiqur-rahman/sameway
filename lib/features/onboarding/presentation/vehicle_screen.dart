import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

enum VehicleType { car, bike }

class VehicleScreen extends StatefulWidget {
  VehicleScreen({super.key});

  final _makeModelController =
      TextEditingController(text: 'Toyota Allion 2019');
  final _licensePlateController =
      TextEditingController(text: 'Dhaka Metro GA-1234');
  final _seatsController = TextEditingController(text: '4');

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  VehicleType _vehicleType = VehicleType.car;

  @override
  void dispose() {
    widget._makeModelController.dispose();
    widget._licensePlateController.dispose();
    widget._seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobilePageHeader(
              title: 'Your Vehicle',
              subtitle: 'Step 2 of 3',
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SelectionCard(
                        emoji: '🚗',
                        title: 'Car',
                        subtitle: '4+ seats',
                        selected: _vehicleType == VehicleType.car,
                        onTap: () =>
                            setState(() => _vehicleType = VehicleType.car),
                      ),
                      const SizedBox(width: 12),
                      SelectionCard(
                        emoji: '🏍️',
                        title: 'Bike',
                        subtitle: '1–2 seats',
                        selected: _vehicleType == VehicleType.bike,
                        onTap: () =>
                            setState(() => _vehicleType = VehicleType.bike),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SamewayTextField(
                    label: 'Make & Model',
                    icon: '🚗',
                    controller: widget._makeModelController,
                  ),
                  const SizedBox(height: 12),
                  SamewayTextField(
                    label: 'License Plate',
                    icon: '🔢',
                    controller: widget._licensePlateController,
                  ),
                  const SizedBox(height: 12),
                  SamewayTextField(
                    label: 'Seats',
                    icon: '💺',
                    controller: widget._seatsController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                  SamewayDarkButton(
                    label: 'Continue',
                    onPressed: () => context.go(AppRoutes.workLocation),
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
