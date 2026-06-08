// MoneyBuddy

/// Confidence level based on days of expense data available.
enum PredictionConfidence {
  insufficient, // < 3 days — UI should hide or show disclaimer
  low,          // 3–6 days
  medium,       // 7–13 days
  high,         // 14+ days
}

/// Spending forecast computed locally from transaction history.
/// Uses trimmed mean (top 5% removed) over calendar days.
class PredictionModel {
  final double nextDaySum;
  final double nextWeekSum;
  final double nextMonthSum;
  final int daysOfData;
  final PredictionConfidence confidence;

  const PredictionModel({
    required this.nextDaySum,
    required this.nextWeekSum,
    required this.nextMonthSum,
    required this.daysOfData,
    required this.confidence,
  });

  /// Returned when user has no expense data at all.
  static const PredictionModel zero = PredictionModel(
    nextDaySum:   0,
    nextWeekSum:  0,
    nextMonthSum: 0,
    daysOfData:   0,
    confidence:   PredictionConfidence.insufficient,
  );

  bool get hasData    => daysOfData > 0;
  bool get isReliable => confidence != PredictionConfidence.insufficient;
}