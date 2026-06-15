import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/constants/app_brand.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/session/user_profile.dart';
import 'package:sameway/core/widgets/onboarding_step_layout.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/onboarding/onboarding_state.dart';
import 'package:sameway/features/onboarding/presentation/widgets/vehicle_form_section.dart';

/// Step 2 of 3 — commute details vary by mode (wireframes v2).
class CommuteDetailsScreen extends StatefulWidget {
  const CommuteDetailsScreen({super.key});

  @override
  State<CommuteDetailsScreen> createState() => _CommuteDetailsScreenState();
}

class _CommuteDetailsScreenState extends State<CommuteDetailsScreen> {
  final _vehicleFormKey = GlobalKey<VehicleFormSectionState>();
  late CommuteType _mode;

  String _preferredVehicle = 'Any';
  String _genderPreference = 'No preference';
  int _maxWalkMinutes = 10;
  bool _walkWithOthers = true;
  String _walkingPace = 'Normal';
  final _leaveByController = TextEditingController();
  final _arriveByController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = AppSession.instance.currentUser;
    _mode = user?.commuteType ?? OnboardingState.instance.commuteType;
    final prefs = user?.commutePreferences;
    if (prefs != null) {
      _preferredVehicle = prefs.preferredVehicle;
      _genderPreference = prefs.genderPreference;
      _maxWalkMinutes = prefs.maxWalkMinutes;
      _walkWithOthers = prefs.walkWithOthers;
      _walkingPace = prefs.walkingPace;
      if (prefs.leaveBy.isNotEmpty) {
        _leaveByController.text = prefs.leaveBy;
      }
      if (prefs.arriveBy.isNotEmpty) {
        _arriveByController.text = prefs.arriveBy;
      }
    }
  }

  @override
  void dispose() {
    _leaveByController.dispose();
    _arriveByController.dispose();
    super.dispose();
  }

  void _continue() async {
    if (_mode == CommuteType.drive) {
      final form = _vehicleFormKey.currentState;
      if (form == null || !form.validate(context)) return;
      final vehicle = form.collectVehicle();
      await AppSession.instance.updateCurrent((user) {
        user.commuteType = _mode;
        user.vehicle = vehicle;
        user.phase = OnboardingPhase.commuteDone;
      });
    } else {
      await AppSession.instance.updateCurrent((user) {
        user.commuteType = _mode;
        user.commutePreferences = _buildPreferences();
        user.vehicle = null;
        user.phase = OnboardingPhase.commuteDone;
      });
    }
    if (!mounted) return;
    context.push(AppRoutes.workVerification);
  }

  CommutePreferences _buildPreferences() {
    final leaveBy = _leaveByController.text.trim();
    final arriveBy = _arriveByController.text.trim();
    if (_mode == CommuteType.walk) {
      return CommutePreferences(
        walkWithOthers: _walkWithOthers,
        walkingPace: _walkingPace,
        leaveBy: leaveBy,
        arriveBy: arriveBy,
      );
    }
    return CommutePreferences(
      preferredVehicle: _preferredVehicle,
      genderPreference: _genderPreference,
      maxWalkMinutes: _maxWalkMinutes,
      leaveBy: leaveBy,
      arriveBy: arriveBy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'Commute Details',
      subtitle: 'Step 2 of 3',
      step: 2,
      backFallback: AppRoutes.profileSetup,
      children: [
        _ModePillRow(
          mode: _mode,
          onChanged: (m) => setState(() {
            _mode = m;
            OnboardingState.instance.commuteType = m;
          }),
        ),
        const SizedBox(height: 22),
        if (_mode == CommuteType.drive)
          VehicleFormSection(key: _vehicleFormKey)
                  else if (_mode == CommuteType.ride)
                    _RiderPreferencesSection(
                      preferredVehicle: _preferredVehicle,
                      genderPreference: _genderPreference,
                      maxWalkMinutes: _maxWalkMinutes,
                      leaveByController: _leaveByController,
                      arriveByController: _arriveByController,
                      onPreferredVehicleChanged: (v) =>
                          setState(() => _preferredVehicle = v),
                      onGenderChanged: (v) =>
                          setState(() => _genderPreference = v),
                      onWalkMinutesChanged: (v) =>
                          setState(() => _maxWalkMinutes = v),
                    )
                  else
                    _WalkerPreferencesSection(
                      walkWithOthers: _walkWithOthers,
                      walkingPace: _walkingPace,
                      leaveByController: _leaveByController,
                      arriveByController: _arriveByController,
                      onWalkWithOthersChanged: (v) =>
                          setState(() => _walkWithOthers = v),
                      onPaceChanged: (v) => setState(() => _walkingPace = v),
                    ),
        const SizedBox(height: 24),
        OnboardingButtonRow(
          primaryLabel: 'Continue → Step 3',
          onPrimary: _continue,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ModePillRow extends StatelessWidget {
  const _ModePillRow({required this.mode, required this.onChanged});

  final CommuteType mode;
  final ValueChanged<CommuteType> onChanged;

  @override
  Widget build(BuildContext context) {
    const modes = [
      (CommuteType.drive, '🚗', 'I Drive'),
      (CommuteType.ride, '🧍', 'I Ride'),
      (CommuteType.walk, '🚶', 'I Walk'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final (m, icon, label) in modes)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(m),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: mode == m ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: mode == m ? AppShadows.soft : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: mode == m ? FontWeight.w700 : FontWeight.w400,
                          color: mode == m ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RiderPreferencesSection extends StatelessWidget {
  const _RiderPreferencesSection({
    required this.preferredVehicle,
    required this.genderPreference,
    required this.maxWalkMinutes,
    required this.leaveByController,
    required this.arriveByController,
    required this.onPreferredVehicleChanged,
    required this.onGenderChanged,
    required this.onWalkMinutesChanged,
  });

  final String preferredVehicle;
  final String genderPreference;
  final int maxWalkMinutes;
  final TextEditingController leaveByController;
  final TextEditingController arriveByController;
  final ValueChanged<String> onPreferredVehicleChanged;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<int> onWalkMinutesChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('PREFERRED VEHICLE'),
        Row(
          children: [
            Expanded(
              child: _OptionCard(
                emoji: '🚗🏍',
                label: 'Any',
                selected: preferredVehicle == 'Any',
                onTap: () => onPreferredVehicleChanged('Any'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _OptionCard(
                emoji: '🚗',
                label: 'Car only',
                selected: preferredVehicle == 'Car only',
                onTap: () => onPreferredVehicleChanged('Car only'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _OptionCard(
                emoji: '🏍',
                label: 'Bike ok',
                selected: preferredVehicle == 'Bike ok',
                onTap: () => onPreferredVehicleChanged('Bike ok'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionHeader('GENDER PREFERENCE'),
        Row(
          children: [
            Expanded(
              child: _PreferenceTile(
                label: 'No preference',
                selected: genderPreference == 'No preference',
                onTap: () => onGenderChanged('No preference'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PreferenceTile(
                label: 'Same gender',
                selected: genderPreference == 'Same gender',
                onTap: () => onGenderChanged('Same gender'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionHeader('MAX WALKING DISTANCE TO PICKUP'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: SamewayDecorations.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: maxWalkMinutes.toDouble(),
                      min: 5,
                      max: 20,
                      divisions: 3,
                      label: '$maxWalkMinutes min',
                      onChanged: (v) => onWalkMinutesChanged(v.round()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$maxWalkMinutes min',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '≈ ${maxWalkMinutes * 70}m walking',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeader('USUAL DEPARTURE TIME'),
        Row(
          children: [
            Expanded(
              child: SamewayTextField(
                label: 'Leave by',
                icon: '⏰',
                hint: AppPlaceholders.usuallyLeave,
                controller: leaveByController,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SamewayTextField(
                label: 'Arrive by',
                icon: '🏢',
                hint: AppPlaceholders.arriveBy,
                controller: arriveByController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const InfoBanner(
          emoji: '💡',
          text:
              'No vehicle needed — you\'ll be matched with verified drivers heading your way.',
        ),
      ],
    );
  }
}

class _WalkerPreferencesSection extends StatelessWidget {
  const _WalkerPreferencesSection({
    required this.walkWithOthers,
    required this.walkingPace,
    required this.leaveByController,
    required this.arriveByController,
    required this.onWalkWithOthersChanged,
    required this.onPaceChanged,
  });

  final bool walkWithOthers;
  final String walkingPace;
  final TextEditingController leaveByController;
  final TextEditingController arriveByController;
  final ValueChanged<bool> onWalkWithOthersChanged;
  final ValueChanged<String> onPaceChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoBanner(
          emoji: '🚶',
          text:
              'Connect with co-workers who walk the same route. $kAppName will suggest walk buddies near your path.',
        ),
        const SizedBox(height: 18),
        const SectionHeader('WALK WITH OTHERS?'),
        Row(
          children: [
            Expanded(
              child: _OptionCard(
                emoji: '👥',
                label: 'Yes, find me buddies',
                selected: walkWithOthers,
                onTap: () => onWalkWithOthersChanged(true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _OptionCard(
                emoji: '🚶',
                label: 'Prefer solo',
                selected: !walkWithOthers,
                onTap: () => onWalkWithOthersChanged(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionHeader('WALKING PACE'),
        Row(
          children: [
            Expanded(
              child: _PreferenceTile(
                label: 'Leisurely',
                selected: walkingPace == 'Leisurely',
                onTap: () => onPaceChanged('Leisurely'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PreferenceTile(
                label: 'Normal',
                selected: walkingPace == 'Normal',
                onTap: () => onPaceChanged('Normal'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PreferenceTile(
                label: 'Brisk',
                selected: walkingPace == 'Brisk',
                onTap: () => onPaceChanged('Brisk'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionHeader('USUAL DEPARTURE TIME'),
        Row(
          children: [
            Expanded(
              child: SamewayTextField(
                label: 'Leave by',
                icon: '⏰',
                hint: AppPlaceholders.usuallyLeave,
                controller: leaveByController,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SamewayTextField(
                label: 'Arrive by',
                icon: '🏢',
                hint: AppPlaceholders.arriveBy,
                controller: arriveByController,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withValues(alpha: 0.07) : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
