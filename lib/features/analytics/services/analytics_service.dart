// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../transactions/models/transaction_model.dart';
import '../models/graph_model.dart';
import '../models/prediction_model.dart';

/// Computes all analytics data from Firestore transactions locally.
/// No backend needed — replaces graph1/2/3 + ML prediction endpoints.
class AnalyticsService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _txCollection =>
      _firestore.collection('users').doc(_uid).collection('transactions');

  Future<List<TransactionModel>> _getAllTransactions() async {
    final snapshot = await _txCollection
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  // ── Graph 1 — Today's transactions by hour ────────────────────

  Future<List<GraphModel>> getGraph1() async {
    try {
      final all = await _getAllTransactions();
      final now   = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final todayTx = all.where((tx) =>
          tx.date.isAfter(today) || tx.date.isAtSameMomentAs(today));

      // Group by hour
      final Map<int, double> hourlyMap = {};
      for (final tx in todayTx) {
        if (!tx.isIncome) {
          final hour = tx.date.hour;
          hourlyMap[hour] = (hourlyMap[hour] ?? 0) + tx.amount;
        }
      }

      return hourlyMap.entries.map((e) => GraphModel(
        amount: e.value,
        label:  '${e.key}:00',
        type:   'Expense',
      )).toList()
        ..sort((a, b) => a.label.compareTo(b.label));
    } catch (e) {
      return [];
    }
  }

  // ── Graph 2 — Last 7 days income vs expense ───────────────────

  Future<List<GraphModel>> getGraph2() async {
    try {
      final all = await _getAllTransactions();
      final now = DateTime.now();

      final result = <GraphModel>[];
      for (int i = 6; i >= 0; i--) {
        final day   = DateTime(now.year, now.month, now.day - i);
        final dayTx = all.where((tx) =>
            tx.date.year  == day.year &&
            tx.date.month == day.month &&
            tx.date.day   == day.day);

        final totalExpense = dayTx
            .where((t) => !t.isIncome)
            .fold(0.0, (acc, t) => acc + t.amount);

        result.add(GraphModel(
          amount: totalExpense,
          label:  '${day.day}/${day.month}',
          type:   'Expense',
        ));
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  // ── Graph 3 — Last 4 weeks ────────────────────────────────────

  Future<List<GraphModel>> getGraph3() async {
    try {
      final all = await _getAllTransactions();
      final now = DateTime.now();

      final result = <GraphModel>[];
      for (int week = 3; week >= 0; week--) {
        final weekStart = now.subtract(Duration(days: (week + 1) * 7));
        final weekEnd   = now.subtract(Duration(days: week * 7));

        final weekTx = all.where((tx) =>
            tx.date.isAfter(weekStart) && tx.date.isBefore(weekEnd));

        final totalExpense = weekTx
            .where((t) => !t.isIncome)
            .fold(0.0, (acc, t) => acc + t.amount);

        result.add(GraphModel(
          amount: totalExpense,
          label:  'Week ${4 - week}',
          type:   'Expense',
        ));
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  // ── Smart Prediction — local average based ────────────────────

  Future<PredictionModel?> getPrediction() async {
    try {
      final all = await _getAllTransactions();
      if (all.isEmpty) return null;

      final now   = DateTime.now();
      final expenses = all.where((t) => !t.isIncome).toList();
      if (expenses.isEmpty) return null;

      // Last 30 days expenses
      final last30 = expenses.where((tx) =>
          tx.date.isAfter(now.subtract(const Duration(days: 30))));

      final total30 = last30.fold(0.0, (acc, t) => acc + t.amount);
      final avgDaily = total30 / 30;

      // Next day = average daily
      final nextDay = avgDaily;

      // Next week = avg daily × 7
      final nextWeek = avgDaily * 7;

      // Next month = avg daily × 30
      final nextMonth = avgDaily * 30;

      return PredictionModel(
        nextDaySum:   nextDay,
        nextWeekSum:  nextWeek,
        nextMonthSum: nextMonth,
      );
    } catch (e) {
      return null;
    }
  }

  // ── Category breakdown ────────────────────────────────────────

  Future<Map<String, double>> getCategoryBreakdown() async {
    try {
      final all = await _getAllTransactions();
      final now   = DateTime.now();
      final month = DateTime(now.year, now.month);

      final monthExpenses = all.where((tx) =>
          !tx.isIncome &&
          (tx.date.isAfter(month) || tx.date.isAtSameMomentAs(month)));

      final Map<String, double> breakdown = {};
      for (final tx in monthExpenses) {
        final cat = tx.category ?? 'Other';
        breakdown[cat] = (breakdown[cat] ?? 0) + tx.amount;
      }
      return breakdown;
    } catch (e) {
      return {};
    }
  }

  // ── Smart Insights ────────────────────────────────────────────

  Future<List<SmartInsight>> getSmartInsights() async {
    try {
      final all = await _getAllTransactions();
      final now = DateTime.now();
      final insights = <SmartInsight>[];

      final expenses = all.where((t) => !t.isIncome).toList();
      if (expenses.isEmpty) return insights;

      // This week vs last week
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
      final lastWeekEnd   = thisWeekStart;

      final thisWeekTotal = expenses
          .where((t) => t.date.isAfter(thisWeekStart))
          .fold(0.0, (s, t) => s + t.amount);

      final lastWeekTotal = expenses
          .where((t) =>
              t.date.isAfter(lastWeekStart) &&
              t.date.isBefore(lastWeekEnd))
          .fold(0.0, (s, t) => s + t.amount);

      if (lastWeekTotal > 0) {
        final diff = thisWeekTotal - lastWeekTotal;
        if (diff > 0) {
          insights.add(SmartInsight(
            emoji:       '📈',
            title:       'Spending up this week',
            description: 'You spent ₹${diff.toStringAsFixed(0)} more than last week.',
            isWarning:   true,
          ));
        } else if (diff < 0) {
          insights.add(SmartInsight(
            emoji:       '📉',
            title:       'Great savings this week!',
            description: 'You spent ₹${(-diff).toStringAsFixed(0)} less than last week.',
            isWarning:   false,
          ));
        }
      }

      // Top category this month
      final month = DateTime(now.year, now.month);
      final monthExpenses = expenses.where((tx) =>
          tx.date.isAfter(month) || tx.date.isAtSameMomentAs(month));

      final Map<String, double> catMap = {};
      for (final tx in monthExpenses) {
        final cat = tx.category ?? 'Other';
        catMap[cat] = (catMap[cat] ?? 0) + tx.amount;
      }

      if (catMap.isNotEmpty) {
        final topCat = catMap.entries
            .reduce((a, b) => a.value > b.value ? a : b);
        insights.add(SmartInsight(
          emoji:       '🏆',
          title:       '${topCat.key} is your top spend',
          description: 'You spent ₹${topCat.value.toStringAsFixed(0)} on ${topCat.key} this month.',
          isWarning:   false,
        ));
      }

      // Month projection
      final daysElapsed   = now.day;
      final daysInMonth   = DateTime(now.year, now.month + 1, 0).day;
      final totalThisMonth = expenses
          .where((tx) =>
              tx.date.isAfter(month) || tx.date.isAtSameMomentAs(month))
          .fold(0.0, (s, t) => s + t.amount);

      if (daysElapsed > 0) {
        final projected =
            (totalThisMonth / daysElapsed) * daysInMonth;
        insights.add(SmartInsight(
          emoji:       '📅',
          title:       'Month projection',
          description: 'At this pace you\'ll spend ₹${projected.toStringAsFixed(0)} this month.',
          isWarning:   projected > totalThisMonth * 1.2,
        ));
      }

      return insights;
    } catch (e) {
      return [];
    }
  }
}

/// A single smart insight shown in analytics screen.
class SmartInsight {
  final String emoji;
  final String title;
  final String description;
  final bool isWarning;

  const SmartInsight({
    required this.emoji,
    required this.title,
    required this.description,
    required this.isWarning,
  });
}