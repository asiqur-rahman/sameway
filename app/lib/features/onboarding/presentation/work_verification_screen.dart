import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sameway/core/models/map_location.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/session/user_profile.dart';
import 'package:sameway/core/widgets/onboarding_step_layout.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class WorkVerificationScreen extends StatefulWidget {
  const WorkVerificationScreen({super.key});

  @override
  State<WorkVerificationScreen> createState() => _WorkVerificationScreenState();
}

class _WorkVerificationScreenState extends State<WorkVerificationScreen> {
  final _companyController = TextEditingController();
  final _homeController = TextEditingController();
  final _officeDisplayController = TextEditingController();
  final _designationController = TextEditingController();

  MapLocation? _office;
  IdVisibility _idVisibility = IdVisibility.adminOnly;
  String? _idCardPath;

  @override
  void initState() {
    super.initState();
    final user = AppSession.instance.currentUser;
    if (user != null) {
      _companyController.text = user.companyName ?? '';
      _homeController.text = user.homeAddress ?? '';
      _designationController.text = user.designation ?? '';
      _idVisibility = user.idVisibility;
      _idCardPath = user.idCardPath;
      if (user.officeAddress != null) {
        _office = MapLocation(
          address: user.officeAddress!,
          lat: user.officeLat ?? 0,
          lng: user.officeLng ?? 0,
        );
        _officeDisplayController.text = user.officeAddress!;
      }
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _homeController.dispose();
    _officeDisplayController.dispose();
    _designationController.dispose();
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

  Future<void> _pickIdCard() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      setState(() => _idCardPath = file.path);
    }
  }

  Future<void> _finish() async {
    if (_office == null || !_office!.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your office address on the map')),
      );
      return;
    }
    await AppSession.instance.updateCurrent((user) {
      user.companyName = _companyController.text.trim();
      user.officeAddress = _office!.address;
      user.officeLat = _office!.lat;
      user.officeLng = _office!.lng;
      user.homeAddress = _homeController.text.trim().isEmpty
          ? null
          : _homeController.text.trim();
      final designation = _designationController.text.trim();
      user.designation = designation.isEmpty ? null : designation;
      user.idVisibility = _idVisibility;
      user.idCardPath = _idCardPath;
      user.phase = OnboardingPhase.complete;
    });
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSession.instance.currentUser;
    final officeSelected = _office != null && _office!.isValid;

    return OnboardingStepLayout(
      title: 'Work Verification',
      subtitle: 'Step 3 of 3',
      step: 3,
      backFallback: AppRoutes.commuteDetails,
      children: [
        const SectionHeader('WHERE DO YOU WORK?'),
        SamewayTextField(
          label: 'Office / Company Name',
          icon: '🏢',
          hint: 'Company name',
          controller: _companyController,
        ),
        GestureDetector(
          onTap: _pickOfficeOnMap,
          child: AbsorbPointer(
            child: SamewayTextField(
              label: 'Office Address',
              icon: '📍',
              hint: officeSelected ? _office!.address : 'Tap to select on map',
              controller: _officeDisplayController,
              readOnly: true,
            ),
          ),
        ),
        GestureDetector(
          onTap: _pickOfficeOnMap,
          child: MapPlaceholder(
            height: 160,
            interactive: officeSelected,
            showZoomControls: true,
            hint: officeSelected
                ? 'Office pinned — tap to adjust'
                : 'Tap to open map and pin your office',
          ),
        ),
        const InfoBanner(
          emoji: '💡',
          text:
              'Your office address helps us match you with co-workers who share your commute direction.',
          compact: true,
          bottomMargin: 20,
        ),
        SamewayTextField(
          label: 'Home Address (optional)',
          icon: '📍',
          hint: AppPlaceholders.homeAddress,
          controller: _homeController,
        ),
        const SectionHeader('OFFICE ID VERIFICATION'),
        SamewayTextField(
          label: 'Designation (optional)',
          icon: '💼',
          hint: AppPlaceholders.designation,
          controller: _designationController,
          helper: 'Your job title helps co-riders recognize you at work',
        ),
        _UploadIdCard(path: _idCardPath, onPick: _pickIdCard),
        const FieldGroupLabel('Who can see this ID?'),
        Row(
          children: [
            Expanded(
              child: _VisibilityOption(
                emoji: '🔒',
                title: 'Admin Only',
                subtitle: 'Only our verification team',
                selected: _idVisibility == IdVisibility.adminOnly,
                onTap: () => setState(() => _idVisibility = IdVisibility.adminOnly),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _VisibilityOption(
                emoji: '👥',
                title: 'Public to Riders',
                subtitle: 'All matched riders can view',
                selected: _idVisibility == IdVisibility.publicToRiders,
                onTap: () => setState(() => _idVisibility = IdVisibility.publicToRiders),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        InfoBanner(
          emoji: '🛡️',
          text:
              'Admin Only is recommended. Our team verifies your employment and grants a ✓ Verified badge. Your ID is never shared without your consent.',
          tint: AppColors.primary,
          compact: true,
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.19)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.125),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text('✅', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.workEmailVerified == true
                          ? 'Work email already verified'
                          : 'Work email pending verification',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      user?.workEmailVerified == true
                          ? '${user!.workEmail} — domain confirmed'
                          : user?.workEmail ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OnboardingButtonRow(
          primaryLabel: '🎉 Finish Setup',
          onPrimary: _finish,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _UploadIdCard extends StatelessWidget {
  const _UploadIdCard({this.path, required this.onPick});

  final String? path;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final hasFile = path != null && path!.isNotEmpty;

    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 2, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Column(
          children: [
            Text(hasFile ? '✅' : '🪪', style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              hasFile ? 'Office ID selected' : '📎 Upload Office ID Card',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasFile ? path!.split(RegExp(r'[/\\]')).last : 'JPG, PNG or PDF · Max 5 MB',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hasFile ? 'Change File' : 'Choose File',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  const _VisibilityOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.07) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
