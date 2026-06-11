// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';

/// Group model — members stored as {name, email}.
/// Expenses use settlements (not splitDetails).
/// UI shows names only — email used for backend matching.
class GroupModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String creatorEmail;
  final List<GroupMember> members;
  final List<GroupExpense> expenses;

  const GroupModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.creatorEmail,
    required this.members,
    required this.expenses,
  });

  double get totalExpense => expenses.fold(0.0, (acc, e) => acc + e.amount);

  int get totalSettlements =>
      expenses.fold(0, (acc, e) => acc + e.settlements.length);

  int get paidSettlements => expenses.fold(
      0, (acc, e) => acc + e.settlements.where((s) => s.paid).length);
  double get settledPercent =>
      totalSettlements > 0 ? paidSettlements / totalSettlements : 0.0;

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      createdBy: data['createdBy']?.toString() ?? '',
      creatorEmail: data['creatorEmail']?.toString() ?? '',
      members: _parseMembers(data['members']),
      expenses: [],
    );
  }

  factory GroupModel.fromFirestoreWithExpenses(
    DocumentSnapshot doc,
    List<DocumentSnapshot> expenseDocs,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      createdBy: data['createdBy']?.toString() ?? '',
      creatorEmail: data['creatorEmail']?.toString() ?? '',
      members: _parseMembers(data['members']),
      expenses: expenseDocs.map((e) => GroupExpense.fromFirestore(e)).toList(),
    );
  }

  static List<GroupMember> _parseMembers(dynamic raw) {
    if (raw == null) return [];
    final list = raw as List<dynamic>;
    return list.map((e) {
      if (e is Map) {
        return GroupMember(
          name: e['name']?.toString() ?? '',
          email: e['email']?.toString() ?? '',
        );
      }
      // Legacy: stored as plain string (email)
      final s = e.toString();
      return GroupMember(name: s, email: s);
    }).toList();
  }
}

// ── Group Member ──────────────────────────────────────────────────

class GroupMember {
  final String name;
  final String email;

  const GroupMember({required this.name, required this.email});

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
      };

  String get displayName => name.isNotEmpty ? name : email;

  String get initials {
    final n = displayName.trim();
    if (n.isEmpty) return '?';
    final parts = n.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return n[0].toUpperCase();
  }
}

// ── Group Expense ─────────────────────────────────────────────────

class GroupExpense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String paidBy; // email
  final String paidByName; // display name
  final List<String> splitBetween; // emails
  final double perPersonShare;
  final List<Settlement> settlements;

  const GroupExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.paidBy,
    required this.paidByName,
    required this.splitBetween,
    required this.perPersonShare,
    required this.settlements,
  });

  bool get allSettled =>
      settlements.isNotEmpty && settlements.every((s) => s.paid);

  int get paidCount => settlements.where((s) => s.paid).length;

  factory GroupExpense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupExpense(
      id: doc.id,
      description: data['description']?.toString() ?? '',
      amount: _toDouble(data['amount']),
      date: _parseDate(data['date']),
      paidBy: data['paidBy']?.toString() ?? '',
      paidByName: data['paidByName']?.toString() ?? '',
      splitBetween:
          List<String>.from(data['splitBetween'] as List<dynamic>? ?? []),
      perPersonShare: _toDouble(data['perPersonShare']),
      settlements: (data['settlements'] as List<dynamic>? ?? [])
          .map((s) => Settlement.fromMap(s as Map<String, dynamic>))
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
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}

// ── Settlement ────────────────────────────────────────────────────

class Settlement {
  final String name; // display
  final String email; // backend
  final double amount;
  final bool paid;

  const Settlement({
    required this.name,
    required this.email,
    required this.amount,
    required this.paid,
  });

  factory Settlement.fromMap(Map<String, dynamic> map) {
    return Settlement(
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      amount: _toDouble(map['amount']),
      paid: map['paid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'amount': amount,
        'paid': paid,
      };

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
