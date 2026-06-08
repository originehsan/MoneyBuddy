// MoneyBuddy

/// Maps the /predict/expense API response predictions object.
class PredictionModel {
  final double nextDaySum;
  final double nextWeekSum;
  final double nextMonthSum;

  const PredictionModel({
    required this.nextDaySum,
    required this.nextWeekSum,
    required this.nextMonthSum,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    final predictions = json['predictions'] ?? json;
    final nextDay     = predictions['next_day_forecast'];

    return PredictionModel(
      // next_day_forecast is a List — take first value
      nextDaySum:   nextDay is List && nextDay.isNotEmpty
                      ? _toDouble(nextDay[0])
                      : _toDouble(nextDay),
      nextWeekSum:  _toDouble(predictions['next_week_forecast_sum']),
      nextMonthSum: _toDouble(predictions['next_month_forecast_sum']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}