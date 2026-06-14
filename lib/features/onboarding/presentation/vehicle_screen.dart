import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

enum VehicleType { car, bike }

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final _makeModelController = TextEditingController();
  final _licensePlateController = TextEditingController();

  VehicleType _vehicleType = VehicleType.car;
  int? _carSeats;

  @override
  void dispose() {
    _makeModelController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _selectVehicleType(VehicleType type) {
    setState(() {
      _vehicleType = type;
      if (type == VehicleType.bike) {
        _carSeats = null;
      }
    });
  }

  void _continue(BuildContext context) {
    if (_vehicleType == VehicleType.car && (_carSeats == null || _carSeats! < 1 || _carSeats! > 3)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select available seats (1–3) for your car')),
      );
      return;
    }
    context.push(AppRoutes.workLocation);
  }

  @override
  Widget build(BuildContext context) {
    final isBike = _vehicleType == VehicleType.bike;

    return SamewayScreen(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobilePageHeader(
              title: 'Your Vehicle',
              subtitle: 'Step 2 of 3',
              backFallback: AppRoutes.profileSetup,
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
                        subtitle: '1–3 seats',
                        selected: _vehicleType == VehicleType.car,
                        onTap: () => _selectVehicleType(VehicleType.car),
                      ),
                      const SizedBox(width: 12),
                      SelectionCard(
                        emoji: '🏍️',
                        title: 'Bike',
                        subtitle: '1 seat',
                        selected: _vehicleType == VehicleType.bike,
                        onTap: () => _selectVehicleType(VehicleType.bike),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SamewayTextField(
                    label: 'Make & Model',
                    icon: isBike ? '🏍️' : '🚗',
                    hint: isBike ? 'e.g. Honda CB150' : AppPlaceholders.makeModel,
                    controller: _makeModelController,
                  ),
                  const SizedBox(height: 12),
                  SamewayTextField(
                    label: 'License Plate',
                    icon: '🔢',
                    hint: AppPlaceholders.licensePlate,
                    controller: _licensePlateController,
                  ),
                  const SizedBox(height: 12),
                  if (isBike)
                    const _FixedSeatField(seats: 1)
                  else
                    _CarSeatPicker(
                      selected: _carSeats,
                      onSelected: (seats) => setState(() => _carSeats = seats),
                    ),
                  const SizedBox(height: 32),
                  SamewayDarkButton(
                    label: 'Continue',
                    onPressed: () => _continue(context),
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

class _CarSeatPicker extends StatelessWidget {
  const _CarSeatPicker({
    required this.selected,
    required this.onSelected,
  });

  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available seats',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'How many riders can you take? (max 3)',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final seats in [1, 2, 3]) ...[
              if (seats > 1) const SizedBox(width: 8),
              Expanded(
                child: _SeatOption(
                  seats: seats,
                  selected: selected == seats,
                  onTap: () => onSelected(seats),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SeatOption extends StatelessWidget {
  const _SeatOption({
    required this.seats,
    required this.selected,
    required this.onTap,
  });

  final int seats;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 47,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$seats seat${seats > 1 ? 's' : ''}',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FixedSeatField extends StatelessWidget {
  const _FixedSeatField({required this.seats});

  final int seats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available seats',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 47,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Text('💺', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text(
                '$seats seat',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                'Fixed for bikes',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
