import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// MoneyBuddy — Typography System
/// Font: Plus Jakarta Sans (premium, friendly, fintech)
/// Usage: Text('Hello', style: AppTextStyles.headingLarge)
class AppTextStyles {
  AppTextStyles._();

  // ── Display — hero amounts ──────────────────────────────────────
  static final TextStyle displayLarge = GoogleFonts.plusJakartaSans(
    fontSize: 32, 
    fontWeight: FontWeight.w700,
    color: AppColors.kTextOnDark,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static final TextStyle displayMedium = GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.kTextPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static final TextStyle displaySmall = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.kTextPrimary,
    letterSpacing: -0.2,
    height: 1.2,
  );

  // ── Money amounts — tabular figures ────────────────────────────
  static final TextStyle moneyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.kTextPrimary,
    letterSpacing: -0.2,
  );

  static final TextStyle moneyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.kTextPrimary,
  );

  static final TextStyle moneySmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.kTextSecondary,
  );

  // ── Headings ───────────────────────────────────────────────────
  static final TextStyle headingLarge = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.kTextPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static final TextStyle headingMedium = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.kTextPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static final TextStyle headingSmall = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.kTextPrimary,
    letterSpacing: -0.1,
    height: 1.4,
  );

  // ── Auth headings ──────────────────────────────────────────────
  static final TextStyle authHeading = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.kTextPrimary,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static final TextStyle authSubHeading = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.kTextSecondary,
    height: 1.5,
  );

  // ── Body ───────────────────────────────────────────────────────
  static final TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.kTextPrimary,
    height: 1.6,
  );

  static final TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.kTextSecondary,
    height: 1.5,
  );

  static final TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.kTextHint,
    height: 1.4,
  );

  // ── Labels ─────────────────────────────────────────────────────
  static final TextStyle labelLarge = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.kTextPrimary,
    letterSpacing: 0.1,
  );

  static final TextStyle labelMedium = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.kTextSecondary,
    letterSpacing: 0.2,
  );

  static final TextStyle labelSmall = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.kTextHint,
    letterSpacing: 0.3,
  );

  // ── Buttons ────────────────────────────────────────────────────
  static final TextStyle buttonPrimary = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.kTextOnPrimary,
    letterSpacing: 0.1,
  );

  static final TextStyle buttonSecondary = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.kPrimary,
    letterSpacing: 0.1,
  );

  static final TextStyle buttonSmall = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.kPrimary,
  );

  // ── Inputs ─────────────────────────────────────────────────────
  static final TextStyle inputLabel = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.kTextSecondary,
    letterSpacing: 0.1,
  );

  static final TextStyle inputHint = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.kTextHint,
  );

  static final TextStyle inputValue = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.kTextPrimary,
  );

  static final TextStyle inputError = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.kError,
  );

  // ── Onboarding ─────────────────────────────────────────────────
  static final TextStyle onboardingHead = GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.kTextPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static final TextStyle onboardingBody = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.kTextSecondary,
    height: 1.6,
  );

  // ── Navigation ─────────────────────────────────────────────────
  static final TextStyle navActive = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.kPrimary,
  );

  static final TextStyle navInactive = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.kTextHint,
  );
}