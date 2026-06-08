// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

/// Handles all transaction Firestore operations.
class TransactionService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _txCollection =>
      _firestore.collection('users').doc(_uid).collection('transactions');

  // ── Add ───────────────────────────────────────────────────────

  Future<bool> addTransaction({
    required String type,
    required double amount,
    required String description,
    required String date,
    String? category,
  }) async {
    try {
      await _txCollection.add({
        'type':      type,
        'amount':    amount,
        'description': description,
        'category':  category ?? _autoCategory(description, type),
        'date':      Timestamp.fromDate(DateTime.parse(date)),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Get all ───────────────────────────────────────────────────

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final snapshot = await _txCollection
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ── Delete ────────────────────────────────────────────────────

  Future<bool> deleteTransaction(String id) async {
    try {
      await _txCollection.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Edit ──────────────────────────────────────────────────────

  Future<bool> editTransaction({
    required String id,
    required String type,
    required double amount,
    required String description,
    required String date,
    String? category,
  }) async {
    try {
      await _txCollection.doc(id).update({
        'type':        type,
        'amount':      amount,
        'description': description,
        'category':    category ?? _autoCategory(description, type),
        'date':        Timestamp.fromDate(DateTime.parse(date)),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Real-time stream ──────────────────────────────────────────

  Stream<List<TransactionModel>> transactionsStream() {
    return _txCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  // ── Auto categorization ───────────────────────────────────────
  // Fixes: now takes type into account
  // Income transactions → category based on source
  // Expense transactions → category based on where money went

  String _autoCategory(String description, String type) {
    final desc = description.toLowerCase();

    if (type.toLowerCase() == 'income') {
      if (_matches(desc, ['salary', 'stipend', 'payroll', 'ctc'])) return 'Salary';
      if (_matches(desc, ['freelance', 'client', 'project', 'invoice'])) return 'Freelance';
      if (_matches(desc, ['interest', 'dividend', 'return', 'profit', 'investment'])) return 'Investment';
      if (_matches(desc, ['bonus', 'incentive', 'reward', 'gift', 'cashback'])) return 'Bonus';
      if (_matches(desc, ['rent', 'rental', 'tenant'])) return 'Rental';
      return 'Income';
    }

    // Expense categories
    if (_matches(desc, ['zomato', 'swiggy', 'blinkit', 'food', 'restaurant', 'cafe', 'pizza', 'burger', 'dhaba', 'chai', 'lunch', 'dinner', 'breakfast'])) return 'Food';
    if (_matches(desc, ['uber', 'ola', 'rapido', 'bus', 'metro', 'auto', 'petrol', 'fuel', 'diesel', 'transport', 'cab', 'rickshaw'])) return 'Transport';
    if (_matches(desc, ['amazon', 'flipkart', 'myntra', 'meesho', 'shopping', 'mall', 'clothes', 'fashion', 'shoes', 'dress'])) return 'Shopping';
    if (_matches(desc, ['netflix', 'spotify', 'hotstar', 'prime', 'youtube', 'movie', 'cinema', 'game', 'entertainment', 'concert'])) return 'Entertainment';
    if (_matches(desc, ['hospital', 'doctor', 'medicine', 'pharmacy', 'health', 'gym', 'fitness', 'clinic', 'medical', 'apollo'])) return 'Health';
    if (_matches(desc, ['electricity', 'water', 'gas', 'wifi', 'internet', 'bill', 'broadband', 'recharge', 'dth'])) return 'Bills';
    if (_matches(desc, ['rent', 'pg', 'hostel', 'accommodation', 'flat', 'apartment'])) return 'Rent';
    if (_matches(desc, ['college', 'school', 'course', 'book', 'education', 'tuition', 'coaching', 'exam', 'fees'])) return 'Education';
    if (_matches(desc, ['flight', 'hotel', 'travel', 'trip', 'holiday', 'booking', 'makemytrip', 'irctc', 'train', 'bus ticket'])) return 'Travel';
    if (_matches(desc, ['emi', 'loan', 'credit', 'debt', 'mortgage', 'installment'])) return 'EMI';

    return 'Other';
  }

  bool _matches(String desc, List<String> keywords) =>
      keywords.any((k) => desc.contains(k));
}