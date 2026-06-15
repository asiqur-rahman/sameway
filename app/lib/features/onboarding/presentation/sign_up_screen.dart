import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/constants/app_brand.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/validation/form_validators.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_secondary_button.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final err = await AppSession.instance.register(
      fullName: _nameController.text,
      workEmail: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    context.push(AppRoutes.profileSetup);
  }

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.signUpHorizontal,
        AppSpacing.signUpTop,
        AppSpacing.signUpHorizontal,
        24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create account', style: AppTypography.screenHeroTitle),
              const SizedBox(height: 4),
              Text(
                'Sign up with any email — Gmail works too',
                style: AppTypography.screenHeroSubtitle,
              ),
              const SizedBox(height: 32),
              SamewayTextField(
                label: 'Full Name',
                icon: '👤',
                hint: AppPlaceholders.fullName,
                controller: _nameController,
                validator: FormValidators.fullName,
              ),
              SamewayTextField(
                label: 'Email',
                icon: '✉️',
                hint: AppPlaceholders.workEmail,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                helper:
                    'Without a company email, your ID will not get the office verified badge.',
                validator: FormValidators.workEmail,
              ),
              SamewayTextField(
                label: 'Phone Number',
                icon: '📱',
                hint: AppPlaceholders.phone,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: FormValidators.phone,
              ),
              SamewayTextField(
                label: 'Password',
                icon: '🔒',
                hint: AppPlaceholders.passwordCreate,
                controller: _passwordController,
                obscureText: true,
                validator: FormValidators.password,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                margin: const EdgeInsets.only(bottom: 20),
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
                      child: Text.rich(
                        TextSpan(
                          style: AppTypography.infoBanner.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Why verification? ',
                              style: AppTypography.infoBannerTitle,
                            ),
                            TextSpan(
                              text:
                                  '$kAppName is for office commuters. A company email earns the ✓ Office Verified badge after we confirm your domain.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SamewayDarkButton(
                label: _loading ? 'Creating account…' : 'Create Account',
                onPressed: _loading ? () {} : _submit,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(child: Divider(height: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('or', style: AppTypography.caption),
                  ),
                  const Expanded(child: Divider(height: 1)),
                ],
              ),
              const SizedBox(height: 16),
              SamewaySecondaryButton(
                label: '🔗  Continue with LinkedIn',
                outlined: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('LinkedIn sign-up is not configured yet'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.signIn),
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.caption.copyWith(fontSize: 13),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign In',
                          style: AppTypography.linkAction,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
