// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single transaction from Firestore.
class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String description;
  final DateTime date;
  final String? category;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.category,
  });

  /// Create from Firestore document.
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id:          doc.id,
      type:        data['type']?.toString()        ?? 'Expense',
      amount:      _toDouble(data['amount']),
      description: data['description']?.toString() ?? '',
      date:        _parseDate(data['date']),
      category:    data['category']?.toString(),
    );
  }

  bool get isIncome => type.toLowerCase() == 'income';

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is Timestamp) return v.toDate();
    try { return DateTime.parse(v.toString()); }
    catch (_) { return DateTime.now(); }
  }
}