// MoneyBuddy

/// Represents a single data point in a transaction graph.
class GraphModel {
  final double amount;
  final String label;
  final String type;

  const GraphModel({
    required this.amount,
    required this.label,
    required this.type,
  });

  factory GraphModel.fromJson(Map<String, dynamic> json) {
    return GraphModel(
      amount: _toDouble(json['amount'] ?? json['totalExpense'] ?? 0),
      label:  json['time']?.toString() ?? json['date']?.toString() ?? '',
      type:   json['type']?.toString() ?? 'Expense',
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}