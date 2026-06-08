// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String title;
  final String description;
  final List<GroupMember> members;
  final List<GroupTransaction> transactions;

  const GroupModel({
    required this.id,
    required this.title,
    required this.description,
    required this.members,
    required this.transactions,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id:           doc.id,
      title:        data['title']?.toString()       ?? '',
      description:  data['description']?.toString() ?? '',
      members:      (data['members'] as List<dynamic>? ?? [])
          .map((e) => GroupMember(email: e.toString(), name: e.toString()))
          .toList(),
      transactions: [],
    );
  }

  factory GroupModel.fromFirestoreWithExpenses(
    DocumentSnapshot doc,
    List<DocumentSnapshot> expenses,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id:          doc.id,
      title:       data['title']?.toString()       ?? '',
      description: data['description']?.toString() ?? '',
      members:     (data['members'] as List<dynamic>? ?? [])
          .map((e) => GroupMember(email: e.toString(), name: e.toString()))
          .toList(),
      transactions: expenses
          .map((e) => GroupTransaction.fromFirestore(e))
          .toList(),
    );
  }
}

class GroupMember {
  final String name;
  final String email;

  const GroupMember({required this.name, required this.email});
}

class GroupTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String initiatedBy;
  final List<SplitDetail> splitDetails;

  const GroupTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.initiatedBy,
    required this.splitDetails,
  });

  factory GroupTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupTransaction(
      id:          doc.id,
      description: data['description']?.toString() ?? '',
      amount:      _toDouble(data['amount']),
      date:        _parseDate(data['date']),
      initiatedBy: data['initiatedBy']?.toString() ?? '',
      splitDetails: (data['splitDetails'] as List<dynamic>? ?? [])
          .map((e) => SplitDetail.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

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

class SplitDetail {
  final String memberEmail;
  final double share;
  final bool paid;

  const SplitDetail({
    required this.memberEmail,
    required this.share,
    required this.paid,
  });

  factory SplitDetail.fromMap(Map<String, dynamic> map) {
    return SplitDetail(
      memberEmail: map['memberEmail']?.toString() ?? '',
      share:       _toDouble(map['share']),
      paid:        map['paid'] as bool? ?? false,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}