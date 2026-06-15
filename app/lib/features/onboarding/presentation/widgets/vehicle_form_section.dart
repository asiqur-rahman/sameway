import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/session/user_profile.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/utils/commute_time_format.dart';
import 'package:sameway/core/widgets/commute_time_select_field.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

enum VehicleType { car, bike }

class VehicleFormSection extends StatefulWidget {
  const VehicleFormSection({super.key});

  @override
  State<VehicleFormSection> createState() => VehicleFormSectionState();
}

class VehicleFormSectionState extends State<VehicleFormSection> {
  final makeModelController = TextEditingController();
  final licensePlateController = TextEditingController();
  final colorController = TextEditingController();
  final leaveController = TextEditingController();
  final latestController = TextEditingController();

  VehicleType vehicleType = VehicleType.car;
  int? carSeats;

  TimeOfDay? _usuallyLeave;
  TimeOfDay? _latestDepart;

  @override
  void initState() {
    super.initState();
    final vehicle = AppSession.instance.currentUser?.vehicle;
    if (vehicle == null) return;
    makeModelController.text = vehicle.makeModel;
    licensePlateController.text = vehicle.licensePlate;
    if (vehicle.color.isNotEmpty) {
      colorController.text = vehicle.color;
    }
    _usuallyLeave = CommuteTimeFormat.parse(vehicle.usuallyLeave);
    _latestDepart = CommuteTimeFormat.parse(vehicle.latestDepart);
    if (_usuallyLeave != null) {
      leaveController.text = vehicle.usuallyLeave;
    }
    if (_latestDepart != null) {
      latestController.text = vehicle.latestDepart;
    }
    vehicleType = vehicle.type == 'bike' ? VehicleType.bike : VehicleType.car;
    carSeats = vehicle.seats;
  }

  @override
  void dispose() {
    makeModelController.dispose();
    licensePlateController.dispose();
    colorController.dispose();
    leaveController.dispose();
    latestController.dispose();
    super.dispose();
  }

  bool validate(BuildContext context) {
    if (makeModelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your vehicle make & model')),
      );
      return false;
    }
    if (licensePlateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your license plate')),
      );
      return false;
    }
    if (vehicleType == VehicleType.car &&
        (carSeats == null || carSeats! < 1 || carSeats! > 3)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select available seats (1–3) for your car')),
      );
      return false;
    }
    return true;
  }

  VehicleInfo collectVehicle() {
    return VehicleInfo(
      type: vehicleType == VehicleType.car ? 'car' : 'bike',
      makeModel: makeModelController.text.trim(),
      licensePlate: licensePlateController.text.trim(),
      color: colorController.text.trim(),
      seats: vehicleType == VehicleType.car ? (carSeats ?? 1) : 1,
      usuallyLeave: _usuallyLeave != null
          ? CommuteTimeFormat.format(_usuallyLeave!)
          : leaveController.text.trim(),
      latestDepart: _latestDepart != null
          ? CommuteTimeFormat.format(_latestDepart!)
          : latestController.text.trim(),
      riderPreference: 'Anyone welcome',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBike = vehicleType == VehicleType.bike;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('VEHICLE TYPE'),
        Row(
          children: [
            SelectionCard(
              emoji: '🚗',
              title: 'Car',
              subtitle: '1–3 seats',
              selected: vehicleType == VehicleType.car,
              onTap: () => setState(() => vehicleType = VehicleType.car),
            ),
            const SizedBox(width: 8),
            SelectionCard(
              emoji: '🏍',
              title: 'Bike',
              subtitle: '1 seat',
              selected: vehicleType == VehicleType.bike,
              onTap: () => setState(() {
                vehicleType = VehicleType.bike;
                carSeats = null;
              }),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionHeader('VEHICLE DETAILS'),
        SamewayTextField(
          label: 'Make & Model',
          icon: isBike ? '🏍' : '🚗',
          hint: isBike ? 'e.g. Honda CB150' : AppPlaceholders.makeModel,
          controller: makeModelController,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SamewayTextField(
                label: 'License Plate',
                icon: '🔢',
                hint: AppPlaceholders.licensePlate,
                controller: licensePlateController,
              ),
            ),
            const SizedBox(width: 8),
            if (isBike)
              const Expanded(child: _FixedSeatField(seats: 1))
            else
              Expanded(
                child: _CarSeatPicker(
                  selected: carSeats,
                  onSelected: (seats) => setState(() => carSeats = seats),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SamewayTextField(
          label: 'Vehicle Color',
          icon: '🎨',
          hint: AppPlaceholders.vehicleColor,
          controller: colorController,
        ),
        const SizedBox(height: 18),
        const SectionHeader('DEPARTURE WINDOW'),
        Row(
          children: [
            Expanded(
              child: CommuteTimeSelectField(
                label: 'Usually Leave',
                icon: '⏰',
                value: _usuallyLeave,
                placeholder: AppPlaceholders.usuallyLeave,
                onSelected: (time) => setState(() {
                  _usuallyLeave = time;
                  leaveController.text = CommuteTimeFormat.format(time);
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CommuteTimeSelectField(
                label: 'Latest Depart',
                icon: '⏱',
                value: _latestDepart,
                placeholder: AppPlaceholders.latestDepart,
                onSelected: (time) => setState(() {
                  _latestDepart = time;
                  latestController.text = CommuteTimeFormat.format(time);
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionHeader('RIDER PREFERENCE'),
        Row(
          children: [
            Expanded(child: _PreferenceTile(label: 'Anyone welcome', selected: true)),
            const SizedBox(width: 8),
            Expanded(child: _PreferenceTile(label: 'Same gender only', selected: false)),
          ],
        ),
      ],
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withValues(alpha: 0.07) : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _CarSeatPicker extends StatelessWidget {
  const _CarSeatPicker({required this.selected, required this.onSelected});

  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seats', style: AppTypography.fieldLabel),
        const SizedBox(height: 5),
        Container(
          height: 47,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              for (final seats in [1, 2, 3])
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelected(seats),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: selected == seats ? AppColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: selected == seats
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$seats',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: selected == seats ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
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
        Text('Seats', style: AppTypography.fieldLabel),
        const SizedBox(height: 5),
        Container(
          height: 47,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$seats',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
