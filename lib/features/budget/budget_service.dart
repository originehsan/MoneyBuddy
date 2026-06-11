// MoneyBuddy
import 'package:shared_preferences/shared_preferences.dart';

/// Manages budget stored locally via SharedPreferences.
/// Supports both overall monthly budget and per-category budgets.
class BudgetService {
  static const _keyMonthlyBudget  = 'monthly_budget';
  static const _keyCategoryPrefix = 'budget_cat_';

  // ── Overall monthly budget ────────────────────────────────────

  static Future<void> saveBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMonthlyBudget, amount);
  }

  static Future<double> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMonthlyBudget) ?? 0.0;
  }

  static Future<void> clearBudget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMonthlyBudget);
  }

  static Future<bool> hasBudget() async {
    return (await getBudget()) > 0;
  }

  // ── Category budgets ──────────────────────────────────────────

  /// Save budget for a specific category.
  static Future<void> saveCategoryBudget(
      String category, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
        '$_keyCategoryPrefix${category.toLowerCase()}', amount);
  }

  /// Get budget for a specific category. Returns 0 if not set.
  static Future<double> getCategoryBudget(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(
            '$_keyCategoryPrefix${category.toLowerCase()}') ??
        0.0;
  }

  /// Get all category budgets as a map.
  static Future<Map<String, double>> getAllCategoryBudgets() async {
    final prefs    = await SharedPreferences.getInstance();
    final keys     = prefs.getKeys();
    final budgets  = <String, double>{};

    for (final key in keys) {
      if (key.startsWith(_keyCategoryPrefix)) {
        final category = key.replaceFirst(_keyCategoryPrefix, '');
        final amount   = prefs.getDouble(key) ?? 0.0;
        if (amount > 0) {
          // Capitalize first letter for display
          final displayCat = category[0].toUpperCase() +
              category.substring(1);
          budgets[displayCat] = amount;
        }
      }
    }
    return budgets;
  }

  /// Clear budget for a specific category.
  static Future<void> clearCategoryBudget(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
        '$_keyCategoryPrefix${category.toLowerCase()}');
  }

  /// Clear all category budgets.
  static Future<void> clearAllCategoryBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final keys  = prefs.getKeys()
        .where((k) => k.startsWith(_keyCategoryPrefix))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}