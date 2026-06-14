import 'package:flutter/material.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';

/// Figma-style depth: white surfaces float above the slate page background.
abstract final class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x060F172A),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const soft = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const navBar = [
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 16,
      offset: Offset(0, -4),
    ),
  ];
}

abstract final class SamewayDecorations {
  static BoxDecoration card({double radius = AppRadius.xl}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.card,
    );
  }

  static BoxDecoration insetField({double radius = AppRadius.md}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
    );
  }

  static BoxDecoration mutedInset({double radius = AppRadius.md}) {
    return BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
    );
  }

  static BoxDecoration track({double radius = 14}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.soft,
    );
  }

  static BoxDecoration iconButton({double radius = 14}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.soft,
    );
  }
}
