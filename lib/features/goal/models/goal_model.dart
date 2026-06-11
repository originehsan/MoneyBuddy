// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';

/// A savings goal with target amount, deadline and progress.
class GoalModel {
  final String   id;
  final String   title;
  final String   icon;
  final double   targetAmount;
  final double   savedAmount;
  final DateTime deadline;
  final DateTime createdAt;

  const GoalModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    required this.createdAt,
  });

  double get progress =>
      targetAmount > 0
          ? (savedAmount / targetAmount).clamp(0.0, 1.0)
          : 0.0;

  double get remaining =>
      (targetAmount - savedAmount).clamp(0.0, double.infinity);

  bool get isCompleted => savedAmount >= targetAmount;

  int get daysLeft =>
      deadline.difference(DateTime.now()).inDays;

  /// Daily savings needed to reach goal by deadline.
  double get dailySavingsNeeded {
    final days = daysLeft;
    if (days <= 0 || isCompleted) return 0.0;
    return remaining / days;
  }

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id:           doc.id,
      title:        data['title']        as String,
      icon:         data['icon']         as String? ?? 'star',
      targetAmount: _toDouble(data['targetAmount']),
      savedAmount:  _toDouble(data['savedAmount']),
      deadline:     (data['deadline'] as Timestamp).toDate(),
      createdAt:    (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title':        title,
    'icon':         icon,
    'targetAmount': targetAmount,
    'savedAmount':  savedAmount,
    'deadline':     Timestamp.fromDate(deadline),
    'createdAt':    Timestamp.fromDate(createdAt),
  };

  GoalModel copyWith({double? savedAmount}) => GoalModel(
    id:           id,
    title:        title,
    icon:         icon,
    targetAmount: targetAmount,
    savedAmount:  savedAmount ?? this.savedAmount,
    deadline:     deadline,
    createdAt:    createdAt,
  );

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}