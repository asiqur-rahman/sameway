import 'package:flutter/material.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';

class SamewayPrimaryButton extends StatelessWidget {
  const SamewayPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.height = 53,
    this.borderRadius = 16,
    this.fontSize = 17,
    this.fontWeight = FontWeight.w700,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
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
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.7),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.9),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: foregroundColor,
                  ),
                )
              : Text(
                  key: const ValueKey('label'),
                  label,
                  style: (textStyle ?? AppTypography.buttonLarge.copyWith(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  )).copyWith(color: foregroundColor),
                ),
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
    this.isLoading = false,
    this.height = 49,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SamewayPrimaryButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppColors.primaryDark,
      height: height,
      borderRadius: AppRadius.lg,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      textStyle: textStyle ?? AppTypography.buttonDark,
    );
  }
}
