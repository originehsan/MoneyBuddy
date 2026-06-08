import 'package:flutter/material.dart';

/// MoneyBuddy Color System
/// Never use raw hex in widgets — always use these tokens.
@immutable
class AppColors {
  const AppColors._();

  // ── Primary — Emerald ──────────────────────────────────────────
  static const Color kPrimary = Color(0xFF059669);
  static const Color kPrimaryDark = Color(0xFF047857);
  static const Color kPrimaryDeep = Color(0xFF064E3B);
  static const Color kPrimaryMid = Color(0xFF065F46);
  static const Color kPrimaryLight = Color(0xFFD1FAE5);
  static const Color kPrimaryTint = Color(0xFFECFDF5);

  // ── Backgrounds ────────────────────────────────────────────────
  static const Color kBackground = Color(0xFFF8FAFC);
  static const Color kSurface = Color(0xFFF0F4F1);
  static const Color kCard = Color(0xFFFFFFFF);
  static const Color kCardAlt = Color(0xFFF7FAF8);
  static const Color kInputFill = Color(0xFFEBF0EC);

  // ── Income / Expense ───────────────────────────────────────────
  static const Color kIncome = Color(0xFF059669);
  static const Color kIncomeBg = Color(0xFFECFDF5);
  static const Color kIncomeText = Color(0xFF065F46);

  static const Color kExpense = Color(0xFFEF4444);
  static const Color kExpenseBg = Color(0xFFFEF2F2);
  static const Color kExpenseText = Color(0xFFB91C1C);

  // ── Semantic ───────────────────────────────────────────────────
  static const Color kWarning = Color(0xFFF59E0B);
  static const Color kWarningBg = Color(0xFFFFFBEB);
  static const Color kWarningText = Color(0xFF92400E);

  static const Color kInfo = Color(0xFF3B82F6);
  static const Color kInfoBg = Color(0xFFEFF6FF);
  static const Color kInfoText = Color(0xFF1D4ED8);

  static const Color kSuccess = Color(0xFF059669);
  static const Color kSuccessBg = Color(0xFFECFDF5);
  static const Color kError = Color(0xFFEF4444);
  static const Color kErrorBg = Color(0xFFFEF2F2);

  // ── Text ───────────────────────────────────────────────────────
  static const Color kTextPrimary = Color(0xFF0F172A);
  static const Color kTextSecondary = Color(0xFF475569);
  static const Color kTextHint = Color(0xFF94A3B8);
  static const Color kTextDisabled = Color(0xFFCBD5E1);
  static const Color kTextOnPrimary = Color(0xFFFFFFFF);
  static const Color kTextOnDark = Color(0xFFFFFFFF);
  static const Color kTextOnDarkMuted = Color(0xFFA7F3D0);

  // ── Borders ────────────────────────────────────────────────────
  static const Color kBorder = Color(0xFFE2E8F0);
  static const Color kBorderActive = Color(0xFF059669);
  static const Color kBorderError = Color(0xFFEF4444);
  static const Color kDivider = Color(0xFFEEF2EE);

  // ── Category colors ────────────────────────────────────────────
  static const Color kCatFood = Color(0xFFEF4444);
  static const Color kCatFoodBg = Color(0xFFFEF2F2);
  static const Color kCatTransport = Color(0xFF3B82F6);
  static const Color kCatTransportBg = Color(0xFFEFF6FF);
  static const Color kCatShopping = Color(0xFFA855F7);
  static const Color kCatShoppingBg = Color(0xFFFDF4FF);
  static const Color kCatSalary = Color(0xFF059669);
  static const Color kCatSalaryBg = Color(0xFFECFDF5);
  static const Color kCatBills = Color(0xFFF59E0B);
  static const Color kCatBillsBg = Color(0xFFFFFBEB);
  static const Color kCatHealth = Color(0xFF10B981);
  static const Color kCatHealthBg = Color(0xFFF0FDF4);
  static const Color kCatTravel = Color(0xFFF97316);
  static const Color kCatTravelBg = Color(0xFFFFF7ED);
  static const Color kCatEducation = Color(0xFF06B6D4);
  static const Color kCatEducationBg = Color(0xFFF0F9FF);
  static const Color kCatEntertain = Color(0xFFEC4899);
  static const Color kCatEntertainBg = Color(0xFFFDF2F8);
  static const Color kCatOther = Color(0xFF94A3B8);
  static const Color kCatOtherBg = Color(0xFFF8FAFC);

  // ── Chart palette ──────────────────────────────────────────────
  static const List<Color> kChartColors = [
    Color(0xFF059669),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFFA855F7),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFFEC4899),
  ];
  static const double kChartFillOpacity = 0.12;

  // ── Gradients ──────────────────────────────────────────────────
  static const LinearGradient kBalanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF047857)],
  );

  static const LinearGradient kDeepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF064E3B), Color(0xFF047857)],
  );

  static const LinearGradient kAuthGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF047857)],
  );

  static const LinearGradient kAnalyticsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF06B6D4)],
  );

  // ── Helpers ────────────────────────────────────────────────────
  static Color categoryColor(String category) {
    switch (category.toLowerCase().trim()) {
      case 'food':
      case 'dining':
        return kCatFood;
      case 'transport':
        return kCatTransport;
      case 'shopping':
        return kCatShopping;
      case 'salary':
      case 'income':
        return kCatSalary;
      case 'bills':
      case 'utilities':
        return kCatBills;
      case 'health':
      case 'medical':
        return kCatHealth;
      case 'travel':
        return kCatTravel;
      case 'education':
        return kCatEducation;
      case 'entertainment':
        return kCatEntertain;
      default:
        return kCatOther;
    }
  }

  static Color categoryBg(String category) {
    switch (category.toLowerCase().trim()) {
      case 'food':
      case 'dining':
        return kCatFoodBg;
      case 'transport':
        return kCatTransportBg;
      case 'shopping':
        return kCatShoppingBg;
      case 'salary':
      case 'income':
        return kCatSalaryBg;
      case 'bills':
      case 'utilities':
        return kCatBillsBg;
      case 'health':
      case 'medical':
        return kCatHealthBg;
      case 'travel':
        return kCatTravelBg;
      case 'education':
        return kCatEducationBg;
      case 'entertainment':
        return kCatEntertainBg;
      default:
        return kCatOtherBg;
    }
  }

  static Color transactionColor(String type) =>
      type.toLowerCase() == 'income' ? kIncome : kExpense;

  static Color transactionBg(String type) =>
      type.toLowerCase() == 'income' ? kIncomeBg : kExpenseBg;
}
