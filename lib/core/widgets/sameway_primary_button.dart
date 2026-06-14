import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';

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
  });

  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: -0.3,
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
    this.height = 49,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SamewayPrimaryButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: AppColors.primaryDark,
      height: height,
      borderRadius: 14,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );
  }
}
