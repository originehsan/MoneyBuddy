// MoneyBuddy
import 'package:get/get.dart';
import '../../transactions/services/transaction_service.dart';
import '../budget_service.dart';

/// Manages budget screen state.
/// Combines category budgets (SharedPreferences) with
/// actual spending (Firestore transactions).
class BudgetController extends GetxController {
  final _transactionService = TransactionService();

  final isLoading        = true.obs;
  final categoryBudgets  = <String, double>{}.obs;   // limits set by user
  final categorySpending = <String, double>{}.obs;   // actual this month
  final totalBudget      = 0.0.obs;
  final totalSpent       = 0.0.obs;

  // All supported budget categories
  static const categories = [
    'Food', 'Transport', 'Shopping', 'Bills',
    'Health', 'Travel', 'Education', 'Entertainment',
    'Rent', 'EMI', 'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadBudgets(),
        _loadSpending(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadBudgets() async {
    final budgets      = await BudgetService.getAllCategoryBudgets();
    categoryBudgets.value = budgets;
    totalBudget.value  = budgets.values.fold(0.0, (a, b) => a + b);
  }

  Future<void> _loadSpending() async {
    final now        = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonth  = DateTime(now.year, now.month + 1, 1);

    final transactions = await _transactionService.getTransactions();
    final monthExpenses = transactions.where((tx) =>
        !tx.isIncome &&
        !tx.date.isBefore(monthStart) &&
        tx.date.isBefore(nextMonth));

    final spending = <String, double>{};
    for (final tx in monthExpenses) {
      final cat = tx.category ?? 'Other';
      spending[cat] = (spending[cat] ?? 0) + tx.amount;
    }
    categorySpending.value = spending;
    totalSpent.value = spending.values.fold(0.0, (a, b) => a + b);
  }

  // ── CRUD ──────────────────────────────────────────────────────

  Future<void> saveCategoryBudget(
      String category, double amount) async {
    await BudgetService.saveCategoryBudget(category, amount);
    await _loadBudgets();
  }

  Future<void> clearCategoryBudget(String category) async {
    await BudgetService.clearCategoryBudget(category);
    await _loadBudgets();
  }

  Future<void> clearAllBudgets() async {
    await BudgetService.clearAllCategoryBudgets();
    await _loadBudgets();
  }

  // ── Computed helpers ──────────────────────────────────────────

  double spentFor(String category) =>
      categorySpending[category] ?? 0.0;

  double budgetFor(String category) =>
      categoryBudgets[category] ?? 0.0;

  double remainingFor(String category) {
    final b = budgetFor(category);
    final s = spentFor(category);
    return b > 0 ? b - s : 0.0;
  }

  double progressFor(String category) {
    final b = budgetFor(category);
    final s = spentFor(category);
    if (b <= 0) return 0.0;
    return (s / b).clamp(0.0, 1.0);
  }

  bool isOverBudget(String category) {
    final b = budgetFor(category);
    return b > 0 && spentFor(category) > b;
  }

  bool isNearBudget(String category) {
    final p = progressFor(category);
    return p >= 0.8 && p < 1.0;
  }

  /// Categories that have either a budget set or spending this month
  List<String> get activeCategories {
    final withBudget  = categoryBudgets.keys.toSet();
    final withSpend   = categorySpending.keys.toSet();
    final all         = {...withBudget, ...withSpend}.toList();
    all.sort();
    return all;
  }

  /// Categories with no budget set yet
  List<String> get unbudgetedCategories =>
      categories.where((c) => budgetFor(c) == 0).toList();

}