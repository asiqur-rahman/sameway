import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';

/// Text styles extracted from the SameWay Figma file (390px mobile artboard).
abstract final class AppTypography {
  // --- Home header ---
  static TextStyle get greetingMeta => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 16 / 13,
      );

  static TextStyle get greetingTitle => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.6,
        color: AppColors.textPrimary,
        height: 27 / 22,
      );

  // --- Tabs (Roboto in Figma) ---
  static TextStyle tabSelected({Color? color}) => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        height: 16 / 14,
      );

  static TextStyle tabUnselected({Color? color}) => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textMuted,
        height: 16 / 14,
      );

  // --- Section labels ---
  static TextStyle sectionAccent({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: color ?? AppColors.primary,
        height: 13 / 11,
      );

  static TextStyle get sectionOverline => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textMuted,
        height: 13 / 11,
      );

  // --- Route block ---
  static TextStyle get routeTitle => GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 18 / 15,
      );

  static TextStyle get routeMeta => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 15 / 12,
      );

  static TextStyle chipLabel({Color? color}) => GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textSecondary,
        height: 14 / 12,
      );

  // --- Buttons ---
  static TextStyle preferenceChipCompact({
    required bool selected,
    bool roboto = false,
  }) {
    final style = roboto
        ? GoogleFonts.roboto(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 13 / 11,
          )
        : GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 13 / 11,
          );
    return style.copyWith(
      color: selected ? Colors.white : AppColors.textSecondary,
    );
  }

  static TextStyle filterSegmentChip({required bool selected}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 17 / 14,
        color: selected ? Colors.white : AppColors.textSecondary,
      );

  static TextStyle genderFilterChip({required bool selected}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 16 / 13,
        color: selected ? AppColors.primary : AppColors.textPrimary,
      );

  static TextStyle get searchButton => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.3,
        color: Colors.white,
        height: 19 / 16,
      );

  static TextStyle get buttonPrimary => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: Colors.white,
        height: 19 / 16,
      );

  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: Colors.white,
      );

  // --- Page chrome ---
  static TextStyle get pageTitle => GoogleFonts.inter(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 23 / 19,
      );

  static TextStyle get pageSubtitle => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 15 / 12,
      );

  // --- Forms ---
  static TextStyle get fieldLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
        height: 15 / 12,
      );

  static TextStyle get fieldValue => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 18 / 15,
      );

  static TextStyle get fieldHint => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 18 / 15,
      );

  static TextStyle get fieldHintSm => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get routeFieldLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.textMuted,
        height: 13 / 11,
      );

  // --- Cards / list rows ---
  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 18 / 15,
      );

  static TextStyle get cardSubtitle => GoogleFonts.roboto(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 15.23 / 13,
      );

  static TextStyle get listRowTitle => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle badge({Color? color}) => GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.primary,
        height: 13 / 11,
      );

  // --- Bottom nav ---
  static TextStyle navLabel({required bool selected}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? AppColors.primary : AppColors.textMuted,
        height: 13 / 11,
      );

  // --- Misc ---
  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get link => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
      );

  static TextStyle get infoBanner => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.45,
      );

  static TextStyle get flowStep => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle selectionTitle({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle get selectionSubtitle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );
}
