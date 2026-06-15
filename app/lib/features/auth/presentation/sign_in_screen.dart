import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/validation/form_validators.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final err = await AppSession.instance.signIn(
      workEmail: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    final route = AppSession.instance.onboardingRouteForCurrentUser() ??
        AppRoutes.home;
    context.go(route);
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
              Text('Sign in', style: AppTypography.screenHeroTitle),
              const SizedBox(height: 4),
              Text(
                'Use the email you signed up with',
                style: AppTypography.screenHeroSubtitle,
              ),
              const SizedBox(height: 32),
              SamewayTextField(
                label: 'Email',
                icon: '✉️',
                hint: 'you@gmail.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: FormValidators.workEmail,
              ),
              SamewayTextField(
                label: 'Password',
                icon: '🔒',
                hint: 'Your password',
                controller: _passwordController,
                obscureText: true,
                validator: FormValidators.password,
              ),
              const SizedBox(height: 8),
              SamewayDarkButton(
                label: _loading ? 'Signing in…' : 'Sign In',
                onPressed: _loading ? () {} : _submit,
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.signUp),
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.caption.copyWith(fontSize: 13),
                      children: [
                        const TextSpan(text: 'No account? '),
                        TextSpan(
                          text: 'Create one',
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
