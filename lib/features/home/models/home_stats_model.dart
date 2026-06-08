// MoneyBuddy
/// Maps the /homepage/home API response to typed Dart fields.
class HomeStatsModel {
  final double totalIncome;
  final double totalExpense;
  final double remainingBalance;
  final double averageDailyExpense;
  final double averageWeeklyExpense;
  final double averageMonthlyExpense;

  const HomeStatsModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.remainingBalance,
    required this.averageDailyExpense,
    required this.averageWeeklyExpense,
    required this.averageMonthlyExpense,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) {
    return HomeStatsModel(
      totalIncome:           _toDouble(json['totalIncome']),
      totalExpense:          _toDouble(json['totalExpense']),
      remainingBalance:      _toDouble(json['remainingBalance']),
      averageDailyExpense:   _toDouble(json['averageDailyExpense']),
      averageWeeklyExpense:  _toDouble(json['averageWeeklyExpense']),
      averageMonthlyExpense: _toDouble(json['averageMonthlyExpense']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}