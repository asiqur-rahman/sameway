import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/models/map_location.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

/// Full-screen map picker — office address must be confirmed here.
class PickOfficeMapScreen extends StatefulWidget {
  const PickOfficeMapScreen({super.key, this.initial});

  final MapLocation? initial;

  @override
  State<PickOfficeMapScreen> createState() => _PickOfficeMapScreenState();
}

class _PickOfficeMapScreenState extends State<PickOfficeMapScreen> {
  final _searchController = TextEditingController();
  MapLocation? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    if (_selected != null) {
      _searchController.text = _selected!.address;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectPreset(MapLocation location) {
    setState(() {
      _selected = location;
      _searchController.text = location.address;
    });
  }

  void _confirm() {
    final location = _selected;
    if (location == null || !location.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select your office pin on the map to continue'),
        ),
      );
      return;
    }
    context.pop(location);
  }

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          const MobilePageHeader(
            title: 'Select Office on Map',
            subtitle: 'Work verification · Step 2 of 3',
            backFallback: AppRoutes.workVerification,
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
                const InfoBanner(
                  emoji: '📍',
                  text:
                      'Office address must be pinned on the map. Typing alone is not enough — drag the pin or pick a location below.',
                ),
                const SizedBox(height: 16),
                MapPlaceholder(
                  height: 320,
                  postRideShell: true,
                  hint: _selected == null
                      ? 'Tap a suggested office or search below'
                      : 'Office pin placed',
                  interactive: true,
                  showZoomControls: true,
                ),
                if (_selected != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint12,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        const Text('🏢', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected office',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                _selected!.address,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SamewayTextField(
                  label: 'Search office',
                  hint: AppPlaceholders.officeAddress,
                  icon: '🔍',
                  controller: _searchController,
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                const SectionHeader('SUGGESTED OFFICES'),
                const SizedBox(height: 10),
                ...OfficeMapPresets.offices.map(
                  (office) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _OfficePresetTile(
                      location: office,
                      selected: _selected?.address == office.address,
                      onTap: () => _selectPreset(office),
                    ),
                  ),
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
              label: 'Confirm Office Location',
              textStyle: AppTypography.buttonDark,
              onPressed: _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficePresetTile extends StatelessWidget {
  const _OfficePresetTile({
    required this.location,
    required this.selected,
    required this.onTap,
  });

  final MapLocation location;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint7 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            const Text('🏢', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                location.address,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
