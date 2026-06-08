import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';

/// MoneyBuddy — Material 3 ThemeData
/// Usage in main.dart: theme: AppTheme.light
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build();

  static ThemeData _build() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ── Color scheme ─────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: AppColors.kPrimary,
        onPrimary: AppColors.kTextOnPrimary,
        primaryContainer: AppColors.kPrimaryLight,
        onPrimaryContainer: AppColors.kPrimaryDeep,
        secondary: AppColors.kInfo,
        onSecondary: AppColors.kTextOnPrimary,
        error: AppColors.kError,
        onError: AppColors.kTextOnPrimary,
        surface: AppColors.kCard,
        onSurface: AppColors.kTextPrimary,
        outline: AppColors.kBorder,
        outlineVariant: AppColors.kDivider,
      ),

      scaffoldBackgroundColor: AppColors.kBackground,

      // ── Text theme ───────────────────────────────────────────
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        headlineSmall: AppTextStyles.headingSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonPrimary,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // ── AppBar ───────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.kBackground,
        foregroundColor: AppColors.kTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headingMedium,
        iconTheme: const IconThemeData(
          color: AppColors.kTextPrimary,
          size: 22,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // ── Elevated button ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kPrimary,
          foregroundColor: AppColors.kTextOnPrimary,
          disabledBackgroundColor: AppColors.kPrimaryLight,
          disabledForegroundColor: AppColors.kPrimaryMid,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 56),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonLarge,
          ),
          textStyle: AppTextStyles.buttonPrimary,
        ),
      ),

      // ── Outlined button ──────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.kPrimary,
          side: const BorderSide(color: AppColors.kPrimary, width: 1.5),
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonLarge,
          ),
          textStyle: AppTextStyles.buttonSecondary,
        ),
      ),

      // ── Text button ──────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.kPrimary,
          textStyle: AppTextStyles.buttonSmall,
        ),
      ),

      // ── Input decoration ─────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.kInputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: AppTextStyles.inputHint,
        labelStyle: AppTextStyles.inputLabel,
        errorStyle: AppTextStyles.inputError,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.kBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.kBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.kBorderActive,
            width: 1.5,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.kBorderError),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.kBorderError,
            width: 1.5,
          ),
        ),
      ),

      // ── Card ─────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: AppColors.kCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: AppColors.kBorder, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Bottom nav ───────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.kCard,
        selectedItemColor: AppColors.kPrimary,
        unselectedItemColor: AppColors.kTextHint,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.navActive,
        unselectedLabelStyle: AppTextStyles.navInactive,
      ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.kDivider,
        thickness: 0.8,
        space: 0,
      ),

      // ── FAB ──────────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.kPrimary,
        foregroundColor: AppColors.kTextOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Bottom sheet ─────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.kCard,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheet,
        ),
        elevation: 0,
      ),

      // ── Chip ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.kSurface,
        selectedColor: AppColors.kPrimaryLight,
        labelStyle: AppTextStyles.labelMedium,
        side: const BorderSide(color: AppColors.kBorder, width: 0.8),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.pill,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Snackbar ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.kTextPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.tile,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Progress indicator ───────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.kPrimary,
        linearTrackColor: AppColors.kPrimaryLight,
      ),

      // ── Switch ───────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.kPrimary
                : AppColors.kTextHint),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.kPrimaryLight
                : AppColors.kBorder),
      ),
    );
  }
}