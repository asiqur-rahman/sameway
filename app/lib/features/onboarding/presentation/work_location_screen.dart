import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/models/map_location.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/core/widgets/work_verification_steps.dart';

class WorkLocationScreen extends StatefulWidget {
  const WorkLocationScreen({super.key});

  @override
  State<WorkLocationScreen> createState() => _WorkLocationScreenState();
}

class _WorkLocationScreenState extends State<WorkLocationScreen> {
  final _homeController = TextEditingController();
  final _officeDisplayController = TextEditingController();
  MapLocation? _office;

  @override
  void dispose() {
    _homeController.dispose();
    _officeDisplayController.dispose();
    super.dispose();
  }

  Future<void> _pickOfficeOnMap() async {
    final result = await context.push<MapLocation>(
      AppRoutes.pickOfficeMap,
      extra: _office,
    );
    if (result != null && mounted) {
      setState(() {
        _office = result;
        _officeDisplayController.text = result.address;
      });
    }
  }

  void _continue() {
    if (_office == null || !_office!.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your office address on the map'),
        ),
      );
      return;
    }
    context.push(AppRoutes.officeId);
  }

  @override
  Widget build(BuildContext context) {
    final officeSelected = _office != null && _office!.isValid;

    return SamewayScreen(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MobilePageHeader(
              title: 'Work Location',
              subtitle: 'Work verification · Step 2 of 3',
              backFallback: AppRoutes.vehicle,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WorkVerificationSteps(
                    currentStep: 2,
                    emailDone: true,
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader('OFFICE ADDRESS (REQUIRED ON MAP)'),
                  const SizedBox(height: 8),
                  const InfoBanner(
                    emoji: '🏢',
                    text:
                        'Your office must be selected on the map so co-riders can match routes near your workplace.',
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickOfficeOnMap,
                    child: AbsorbPointer(
                      child: SamewayTextField(
                        label: 'Office Address',
                        icon: '🏢',
                        hint: officeSelected
                            ? _office!.address
                            : 'Tap to select on map',
                        controller: _officeDisplayController,
                        readOnly: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickOfficeOnMap,
                    child: MapPlaceholder(
                      height: 180,
                      interactive: officeSelected,
                      showZoomControls: true,
                      hint: officeSelected
                          ? 'Office pinned — tap to adjust'
                          : 'Tap to open map and pin your office',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _pickOfficeOnMap,
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(
                        officeSelected ? 'Change office on map' : 'Select on map',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SamewayTextField(
                    label: 'Home Address (optional)',
                    icon: '📍',
                    hint: AppPlaceholders.homeAddress,
                    controller: _homeController,
                  ),
                  const SizedBox(height: 32),
                  SamewayDarkButton(
                    label: 'Continue',
                    onPressed: _continue,
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
