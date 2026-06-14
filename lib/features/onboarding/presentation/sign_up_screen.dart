import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_secondary_button.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        28,
        AppSpacing.screenHorizontal,
        24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create account',
              style: GoogleFonts.inter(
                fontSize: 30,
                letterSpacing: -1,
                color: AppColors.textPrimary,
                height: 36.3 / 30,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'For verified office commuters only',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            SamewayTextField(
              label: 'Full Name',
              icon: '👤',
              hint: AppPlaceholders.fullName,
              controller: _nameController,
            ),
            const SizedBox(height: 4),
            SamewayTextField(
              label: 'Work Email',
              icon: '✉️',
              hint: AppPlaceholders.workEmail,
              controller: _emailController,
              helper: 'We verify your company email domain automatically',
            ),
            const SizedBox(height: 4),
            SamewayTextField(
              label: 'Phone Number',
              icon: '📱',
              hint: AppPlaceholders.phone,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 4),
            SamewayTextField(
              label: 'Password',
              icon: '🔒',
              hint: AppPlaceholders.passwordCreate,
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🛡️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Why verification? SameWay is exclusively for office workers. We check your email domain to keep every ride safe and trusted.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 19.5 / 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
              SamewayDarkButton(
                label: 'Create Account',
                onPressed: () => context.push(AppRoutes.profileSetup),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Divider(height: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'or',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const Expanded(child: Divider(height: 1)),
              ],
            ),
            const SizedBox(height: 16),
            SamewaySecondaryButton(
              label: '🔗 Continue with LinkedIn',
              outlined: true,
              onPressed: () {},
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Already have an account? Sign In',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
