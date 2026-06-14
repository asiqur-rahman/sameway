import 'package:flutter/material.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';

class SamewayPrimaryButton extends StatelessWidget {
  const SamewayPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.height = 53,
    this.borderRadius = 16,
    this.fontSize = 17,
    this.fontWeight = FontWeight.w700,
    this.textStyle,
  });

  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          label,
          style: (textStyle ?? AppTypography.buttonLarge.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
          )).copyWith(color: foregroundColor),
        ),
      ),
    );
  }
}

class SamewayDarkButton extends StatelessWidget {
  const SamewayDarkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 49,
    this.textStyle,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SamewayPrimaryButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: AppColors.primaryDark,
      height: height,
      borderRadius: AppRadius.lg,
      textStyle: textStyle ?? AppTypography.buttonPrimary,
    );
  }
}
