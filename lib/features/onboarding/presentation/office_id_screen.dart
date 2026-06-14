import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

enum VerificationMethod { adminOnly, selfVerify }

class OfficeIdScreen extends StatefulWidget {
  const OfficeIdScreen({super.key});

  @override
  State<OfficeIdScreen> createState() => _OfficeIdScreenState();
}

class _OfficeIdScreenState extends State<OfficeIdScreen> {
  VerificationMethod _method = VerificationMethod.selfVerify;

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobilePageHeader(
              title: 'Office ID',
              subtitle: 'Get your verified badge',
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader('OFFICE ID VERIFICATION'),
                  const SizedBox(height: 12),
                  const _UploadIdCard(),
                  const SizedBox(height: 20),
                  _VerificationOptionTile(
                    emoji: '👔',
                    title: 'Admin Only',
                    subtitle: 'Your HR admin verifies your employee status',
                    selected: _method == VerificationMethod.adminOnly,
                    onTap: () =>
                        setState(() => _method = VerificationMethod.adminOnly),
                  ),
                  const SizedBox(height: 10),
                  _VerificationOptionTile(
                    emoji: '📄',
                    title: 'Self-verify',
                    subtitle: 'Upload your employee ID card for review',
                    selected: _method == VerificationMethod.selfVerify,
                    onTap: () =>
                        setState(() => _method = VerificationMethod.selfVerify),
                  ),
                  const SizedBox(height: 20),
                  const InfoBanner(
                    emoji: '✅',
                    text:
                        'Verified users get a badge on their profile, making co-riders feel safer about sharing a ride.',
                  ),
                  const SizedBox(height: 32),
                  SamewayDarkButton(
                    label: 'Continue',
                    onPressed: () => context.go(AppRoutes.home),
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

class _UploadIdCard extends StatelessWidget {
  const _UploadIdCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(
          children: [
            const Text('🪪', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            Text(
              'Upload Employee ID',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Photo of your company ID card',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationOptionTile extends StatelessWidget {
  const _VerificationOptionTile({
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
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
