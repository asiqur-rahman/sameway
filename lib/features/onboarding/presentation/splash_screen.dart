import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/widgets/feature_item.dart';
import 'package:sameway/core/widgets/route_match_illustration.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_secondary_button.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 36),
            const Center(child: SamewayLogo()),
            const SizedBox(height: 8),
            Text(
              'SameWay',
              style: GoogleFonts.inter(
                fontSize: 44,
                letterSpacing: -1.5,
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your commute.\nSplit the cost.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 17,
                color: AppColors.textMuted,
                height: 26.35 / 17,
              ),
            ),
            const SizedBox(height: 22),
            const SizedBox(width: 330, child: RouteMatchIllustration()),
            const SizedBox(height: 22),
            const SizedBox(
              width: 330,
              child: FeatureItem(
                emoji: '🏢',
                label: 'Verified office workers only',
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(
              width: 330,
              child: FeatureItem(
                emoji: '🗺️',
                label: 'Smart route overlap matching',
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(
              width: 330,
              child: FeatureItem(
                emoji: '🤝',
                label: 'No app fees — settle directly',
              ),
            ),
            const SizedBox(height: 69),
            SamewayPrimaryButton(
              label: 'Get Started',
              onPressed: () => context.go(AppRoutes.signUp),
            ),
            const SizedBox(height: 10),
            SamewaySecondaryButton(
              label: 'I already have an account',
              onPressed: () => context.go(AppRoutes.home),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
