import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/web_scaffold.dart';

class WebSignInScreen extends StatelessWidget {
  WebSignInScreen({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      activeNav: 'Sign In',
      child: Center(
        child: Container(
          width: 400,
          margin: const EdgeInsets.all(48),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sign in',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Use your verified work email',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              SamewayTextField(
                label: 'Work Email',
                icon: '✉️',
                hint: AppPlaceholders.workEmail,
                controller: _emailController,
              ),
              const SizedBox(height: 12),
              SamewayTextField(
                label: 'Password',
                icon: '🔒',
                hint: AppPlaceholders.passwordSignIn,
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SamewayPrimaryButton(
                label: 'Sign In',
                backgroundColor: AppColors.primaryDark,
                height: 49,
                borderRadius: 12,
                fontSize: 16,
                onPressed: () => context.go(AppRoutes.webDashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
