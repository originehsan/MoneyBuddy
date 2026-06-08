// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../transactions/models/transaction_model.dart';
import '../models/home_stats_model.dart';

/// Computes home stats from Firestore transaction data.
class HomeService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _txCollection =>
      _firestore.collection('users').doc(_uid).collection('transactions');

  Future<HomeStatsModel?> getHomeStats() async {
    try {
      final snapshot = await _txCollection.get();
      final all = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      final now        = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      // This month only
      final monthTx = all.where((tx) =>
          tx.date.isAfter(monthStart) ||
          tx.date.isAtSameMomentAs(monthStart)).toList();

      final totalIncome = monthTx
          .where((t) => t.isIncome)
          .fold(0.0, (acc, t) => acc + t.amount);

      final totalExpense = monthTx
          .where((t) => !t.isIncome)
          .fold(0.0, (acc, t) => acc + t.amount);

      // Account balance set by user + net this month
      final userDoc = await _firestore
          .collection('users')
          .doc(_uid)
          .get();

    // After
final data = userDoc.exists
    ? userDoc.data() as Map<String, dynamic>?
    : null;
final accountBalance = _toDouble(data?['accountBalance']);

      // Correct formula: base balance + income earned - expenses spent
      final remainingBalance = accountBalance + totalIncome - totalExpense;

      // Averages based on days elapsed so far this month
      final daysElapsed = now.day;
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      // Daily avg = expense so far / days elapsed
      final avgDaily = daysElapsed > 0 ? totalExpense / daysElapsed : 0.0;

      // Weekly avg = daily avg × 7
      final avgWeekly = avgDaily * 7;

      // Monthly projection = daily avg × total days in month
      final avgMonthly = avgDaily * daysInMonth;

      return HomeStatsModel(
        totalIncome:           totalIncome,
        totalExpense:          totalExpense,
        remainingBalance:      remainingBalance,
        averageDailyExpense:   avgDaily,
        averageWeeklyExpense:  avgWeekly,
        averageMonthlyExpense: avgMonthly,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserName() async =>
      _auth.currentUser?.displayName;

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}