import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/web_scaffold.dart';

class WebLandingScreen extends StatelessWidget {
  const WebLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      activeNav: 'How it Works',
      child: SingleChildScrollView(
        child: Column(
          children: [
            WebHero(
              title: 'Share your commute',
              subtitle:
                  'SameWay connects verified office commuters in Dhaka. Split costs, reduce traffic, and ride with people from your company.',
              cta: SamewayPrimaryButton(
                label: 'Get Started — It\'s Free',
                height: 49,
                borderRadius: 12,
                fontSize: 16,
                onPressed: () => context.go(AppRoutes.webSignIn),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOW IT WORKS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: _StepCard(step: '1', title: 'Verify your work email', body: 'Sign up with your company domain')),
                      SizedBox(width: 16),
                      Expanded(child: _StepCard(step: '2', title: 'Find or post a ride', body: 'Match with commuters on your route')),
                      SizedBox(width: 16),
                      Expanded(child: _StepCard(step: '3', title: 'Ride together', body: 'Chat, coordinate pickup, split costs')),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: SamewayPrimaryButton(
                      label: 'Sign in with work email',
                      backgroundColor: AppColors.primaryDark,
                      height: 49,
                      borderRadius: 12,
                      fontSize: 16,
                      onPressed: () => context.go(AppRoutes.webSignIn),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.body,
  });

  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
