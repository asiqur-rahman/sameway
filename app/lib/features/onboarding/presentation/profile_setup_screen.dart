import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/session/user_profile.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/validation/form_validators.dart';
import 'package:sameway/core/widgets/onboarding_step_layout.dart';
import 'package:sameway/core/widgets/image_upload_card.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/onboarding/onboarding_state.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  CommuteType _commuteType = CommuteType.drive;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final user = AppSession.instance.currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _commuteType = user?.commuteType ?? CommuteType.drive;
    _photoPath = user?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _modeHint {
    return switch (_commuteType) {
      CommuteType.drive =>
        "You'll share your car or bike with co-workers. Next step will ask for your vehicle details.",
      CommuteType.ride =>
        "You'll be matched with verified drivers heading your way. Next step will set your ride preferences.",
      CommuteType.walk =>
        'Connect with fellow walkers who share your route. No vehicle details needed.',
    };
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    await AppSession.instance.updateCurrent((user) {
      user.fullName = _nameController.text.trim();
      user.commuteType = _commuteType;
      user.photoPath = _photoPath;
      user.phase = OnboardingPhase.profileDone;
    });
    if (!mounted) return;
    context.push(AppRoutes.commuteDetails);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'Set Up Profile',
      subtitle: 'Step 1 of 3',
      step: 1,
      showBack: false,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader('PROFILE PHOTO'),
              ImageUploadCard(
                title: 'Upload your photo',
                subtitle: 'Builds trust with co-commuters',
                onImageChanged: (file) {
                  setState(() => _photoPath = file?.path);
                },
              ),
              const SizedBox(height: 26),
              const SectionHeader('YOUR NAME'),
              SamewayTextField(
                label: 'Full Name',
                icon: '👤',
                hint: AppPlaceholders.fullName,
                controller: _nameController,
                validator: FormValidators.fullName,
              ),
              const SectionHeader('HOW DO YOU COMMUTE?'),
              Row(
                children: [
                  SelectionCard(
                    emoji: '🚗',
                    title: 'I Drive',
                    subtitle: 'Offer rides',
                    selected: _commuteType == CommuteType.drive,
                    onTap: () => setState(() => _commuteType = CommuteType.drive),
                  ),
                  const SizedBox(width: 8),
                  SelectionCard(
                    emoji: '🧍',
                    title: 'I Ride',
                    subtitle: 'Find rides',
                    selected: _commuteType == CommuteType.ride,
                    onTap: () => setState(() => _commuteType = CommuteType.ride),
                  ),
                  const SizedBox(width: 8),
                  SelectionCard(
                    emoji: '🚶',
                    title: 'I Walk',
                    subtitle: 'Walk to work',
                    selected: _commuteType == CommuteType.walk,
                    onTap: () => setState(() => _commuteType = CommuteType.walk),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InfoBanner(
                emoji: '💡',
                text: _modeHint,
                neutral: true,
                bottomMargin: 24,
              ),
              SamewayDarkButton(
                label: 'Continue → Step 2',
                onPressed: _continue,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
