import 'package:flutter/material.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_secondary_button.dart';
import 'package:sameway/core/widgets/setup_progress_bar.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

/// Wireframe v2 onboarding shell: [MobilePageHeader] → 16px → progress → body.
class OnboardingStepLayout extends StatelessWidget {
  const OnboardingStepLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.step,
    required this.children,
    this.showBack = true,
    this.backFallback,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final int step;
  final List<Widget> children;
  final bool showBack;
  final String? backFallback;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobilePageHeader(
              title: title,
              subtitle: subtitle,
              showBack: showBack,
              backFallback: backFallback,
              onBack: onBack,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.onboardingBodyTop,
                AppSpacing.screenHorizontal,
                AppSpacing.onboardingBodyBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SetupProgressBar(step: step),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom action row — wireframe `← Back` outline + primary CTA.
class OnboardingButtonRow extends StatelessWidget {
  const OnboardingButtonRow({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.onBack,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SamewaySecondaryButton(
            label: '← Back',
            outlined: true,
            height: 49,
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SamewayDarkButton(
            label: primaryLabel,
            onPressed: onPrimary,
          ),
        ),
      ],
    );
  }
}
