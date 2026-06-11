// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tracks a loan/EMI with progress and next due date.
class EmiModel {
  final String   id;
  final String   name;
  final String   icon;
  final double   totalAmount;
  final double   emiAmount;
  final int      totalMonths;
  final int      paidMonths;
  final DateTime startDate;
  final double?  interestRate;

  const EmiModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.totalAmount,
    required this.emiAmount,
    required this.totalMonths,
    required this.paidMonths,
    required this.startDate,
    this.interestRate,
  });

  int get remainingMonths =>
      (totalMonths - paidMonths).clamp(0, totalMonths);

  double get totalPaid     => emiAmount * paidMonths;
  double get totalRemaining => emiAmount * remainingMonths;

  double get progress =>
      totalMonths > 0
          ? (paidMonths / totalMonths).clamp(0.0, 1.0)
          : 0.0;

  bool get isCompleted => paidMonths >= totalMonths;

  DateTime get nextDueDate {
    return DateTime(
      startDate.year,
      startDate.month + paidMonths,
      startDate.day,
    );
  }

  int get daysUntilDue =>
      nextDueDate.difference(DateTime.now()).inDays;

  factory EmiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmiModel(
      id:           doc.id,
      name:         data['name']         as String,
      icon:         data['icon']         as String? ?? 'creditcard',
      totalAmount:  _toDouble(data['totalAmount']),
      emiAmount:    _toDouble(data['emiAmount']),
      totalMonths:  (data['totalMonths'] as num).toInt(),
      paidMonths:   (data['paidMonths']  as num).toInt(),
      startDate:    (data['startDate'] as Timestamp).toDate(),
      interestRate: data['interestRate'] != null
          ? _toDouble(data['interestRate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'name':         name,
    'icon':         icon,
    'totalAmount':  totalAmount,
    'emiAmount':    emiAmount,
    'totalMonths':  totalMonths,
    'paidMonths':   paidMonths,
    'startDate':    Timestamp.fromDate(startDate),
    if (interestRate != null) 'interestRate': interestRate,
  };

  EmiModel copyWith({int? paidMonths}) => EmiModel(
    id:           id,
    name:         name,
    icon:         icon,
    totalAmount:  totalAmount,
    emiAmount:    emiAmount,
    totalMonths:  totalMonths,
    paidMonths:   paidMonths ?? this.paidMonths,
    startDate:    startDate,
    interestRate: interestRate,
  );

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}