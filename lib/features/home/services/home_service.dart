// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../transactions/models/transaction_model.dart';
import '../models/home_stats_model.dart';

/// Computes home stats from Firestore transaction data.
class HomeService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _txCollection =>
      _firestore.collection('users').doc(_uid).collection('transactions');

  Future<HomeStatsModel?> getHomeStats() async {
    try {
      final snapshot = await _txCollection.get();
      final all = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final nextMonth = DateTime(now.year, now.month + 1, 1);

      // Strict month filter — upper bound prevents next month leakage
      final monthTx = all
          .where((tx) =>
              !tx.date.isBefore(monthStart) && tx.date.isBefore(nextMonth))
          .toList();

      final totalIncome = monthTx
          .where((t) => t.isIncome)
          .fold(0.0, (acc, t) => acc + t.amount);

      final totalExpense = monthTx
          .where((t) => !t.isIncome)
          .fold(0.0, (acc, t) => acc + t.amount);

      // Today's spend
      final todayStart = DateTime(now.year, now.month, now.day);
      final todaySpend = monthTx
          .where((t) => !t.isIncome && !t.date.isBefore(todayStart))
          .fold(0.0, (acc, t) => acc + t.amount);

      // Account balance from user doc
      final userDoc = await _firestore.collection('users').doc(_uid).get();

      final data =
          userDoc.exists ? userDoc.data() as Map<String, dynamic>? : null;
      final accountBalance = _toDouble(data?['accountBalance']);
      final remainingBalance = accountBalance + totalIncome - totalExpense;

      // Averages based on days elapsed
      final daysElapsed = now.day;
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      final avgDaily = daysElapsed > 0 ? totalExpense / daysElapsed : 0.0;
      final avgWeekly = avgDaily * 7;
      final avgMonthly = avgDaily * daysInMonth;

      return HomeStatsModel(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        remainingBalance: remainingBalance,
        averageDailyExpense: avgDaily,
        averageWeeklyExpense: avgWeekly,
        averageMonthlyExpense: avgMonthly,
        todaySpend: todaySpend,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> getUserName() async => _auth.currentUser?.displayName;

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
