// MoneyBuddy
import 'package:flutter/material.dart';

/// Responsive sizing utility for MoneyBuddy.
///
/// Base design is 390px wide (Pixel 7 / iPhone 14).
/// All Android phones from budget (360px) to flagship (428px) are covered.
///
/// Usage:
///   R.sp(context, 16)  → scaled font size
///   R.w(context, 60)   → scaled width
///   R.h(context, 100)  → scaled height
///   R.hp(context, 0.2) → percentage of screen height
class R {
  R._();

  static const double _baseWidth  = 390.0;
  static const double _baseHeight = 844.0;

  /// Scaled width — use for fixed-width containers, icons, avatars
  static double w(BuildContext context, double value) {
    final width = MediaQuery.of(context).size.width;
    return value * (width / _baseWidth);
  }

  /// Scaled height — use for fixed-height containers
  static double h(BuildContext context, double value) {
    final height = MediaQuery.of(context).size.height;
    return value * (height / _baseHeight);
  }

  /// Scaled font size — clamps so text never gets too small or huge
  static double sp(BuildContext context, double value) {
    final scaled = w(context, value);
    return scaled.clamp(value * 0.82, value * 1.18);
  }

  /// Percentage of screen height — use for top spacing, hero sections
  static double hp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * percent;
  }

  /// Percentage of screen width
  static double wp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * percent;
  }

  /// Horizontal screen padding — adjusts for small/large screens
  static double screenH(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 370) return 16.0;
    if (width > 410) return 28.0;
    return 24.0;
  }

  /// True if screen width < 380px (budget Android phones)
  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < 380;

  /// True if screen width > 410px (large flagship phones)
  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width > 410;

  /// Safe screen width — never crashes on weird screen sizes
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
}