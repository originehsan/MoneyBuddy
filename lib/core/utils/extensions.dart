// MoneyBuddy
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ── BuildContext ───────────────────────────────────────────────
extension ContextExtensions on BuildContext {
  double get screenWidth  => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get safeTop      => MediaQuery.of(this).padding.top;
  double get safeBottom   => MediaQuery.of(this).padding.bottom;
  bool   get isNarrow     => screenWidth < 400;
  ThemeData get theme     => Theme.of(this);
}

// ── String ────────────────────────────────────────────────────
extension StringExtensions on String {
  /// 'hello world' → 'Hello World'
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  /// 'hello' → 'Hello'
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// 'income' → true
  bool get isIncome => toLowerCase() == 'income';

  /// Valid email check
  bool get isValidEmail =>
      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Truncate: 'Hello World' → 'Hello...'
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';
}

// ── num ───────────────────────────────────────────────────────
extension NumExtensions on num {
  /// 16.h → SizedBox(height: 16)
  SizedBox get h => SizedBox(height: toDouble());

  /// 8.w → SizedBox(width: 8)
  SizedBox get w => SizedBox(width: toDouble());

  /// 16.paddingAll → EdgeInsets.all(16)
  EdgeInsets get paddingAll => EdgeInsets.all(toDouble());

  /// 24.paddingH → EdgeInsets.symmetric(horizontal: 24)
  EdgeInsets get paddingH =>
      EdgeInsets.symmetric(horizontal: toDouble());

  /// 20.paddingV → EdgeInsets.symmetric(vertical: 20)
  EdgeInsets get paddingV =>
      EdgeInsets.symmetric(vertical: toDouble());
}

// ── DateTime ──────────────────────────────────────────────────
extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return year == y.year && month == y.month && day == y.day;
  }
}

// ── Color from category string ────────────────────────────────
extension CategoryColorExtension on String {
  Color get categoryColor => AppColors.categoryColor(this);
  Color get categoryBg    => AppColors.categoryBg(this);
}