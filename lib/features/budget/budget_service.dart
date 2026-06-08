// MoneyBuddy
import 'package:shared_preferences/shared_preferences.dart';

/// Manages monthly budget stored locally via SharedPreferences.
/// Budget is a user preference — does not sync to backend.
class BudgetService {
  static const _keyMonthlyBudget = 'monthly_budget';

  /// Saves the monthly budget amount.
  static Future<void> saveBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMonthlyBudget, amount);
  }

  /// Returns saved monthly budget. Returns 0 if not set.
  static Future<double> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMonthlyBudget) ?? 0.0;
  }

  /// Clears the saved budget.
  static Future<void> clearBudget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMonthlyBudget);
  }

  /// Returns true if user has set a budget.
  static Future<bool> hasBudget() async {
    final budget = await getBudget();
    return budget > 0;
  }
}