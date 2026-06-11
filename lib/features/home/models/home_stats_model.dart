// MoneyBuddy

/// Home stats computed from Firestore transactions.
class HomeStatsModel {
  final double totalIncome;
  final double totalExpense;
  final double remainingBalance;
  final double averageDailyExpense;
  final double averageWeeklyExpense;
  final double averageMonthlyExpense;
  final double todaySpend;

  const HomeStatsModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.remainingBalance,
    required this.averageDailyExpense,
    required this.averageWeeklyExpense,
    required this.averageMonthlyExpense,
    this.todaySpend = 0.0,
  });

  double get netCashFlow => totalIncome - totalExpense;
  bool get isPositive    => netCashFlow >= 0;
}