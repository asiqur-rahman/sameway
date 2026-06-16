import 'package:sameway/core/session/user_profile.dart';

abstract final class FormValidators {
  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 2) return 'Enter your full name';
    if (v.length > 100) return 'Name is too long';
    return null;
  }

  static String? workEmail(String? value) {
    final v = value?.trim().toLowerCase() ?? '';
    if (v.isEmpty) return 'Enter your email';
    final emailRe = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRe.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value) {
    final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Enter $label';
    return null;
  }

  static String routeForPhase(OnboardingPhase phase) {
    return switch (phase) {
      OnboardingPhase.accountCreated => '/profile-setup',
      OnboardingPhase.profileDone => '/commute-details',
      OnboardingPhase.commuteDone => '/work-verification',
      OnboardingPhase.complete => '/home',
    };
  }
}
