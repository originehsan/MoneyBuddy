// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../../transactions/models/transaction_model.dart';
import '../models/graph_model.dart';
import '../models/prediction_model.dart';

/// Computes all analytics data locally from Firestore transactions.
class AnalyticsService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _txCollection =>
      _firestore.collection('users').doc(_uid).collection('transactions');

  Future<List<TransactionModel>> _getAllTransactions() async {
    final snapshot =
        await _txCollection.orderBy('date', descending: true).get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  // ── Graph 1 — Today by hour ───────────────────────────────────

  Future<List<GraphModel>> getGraph1() async {
    try {
      final all = await _getAllTransactions();
      final now = DateTime.now();

      final todayExpenses = all
          .where((t) =>
              !t.isIncome &&
              t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day)
          .toList();

      return List.generate(24, (hour) {
        final amount = todayExpenses
            .where((t) => t.date.hour == hour)
            .fold(0.0, (acc, t) => acc + t.amount);
        return GraphModel(
          amount: amount,
          label: '${hour.toString().padLeft(2, '0')}:00',
          type: 'day',
        );
      });
    } catch (_) {
      return [];
    }
  }

  // ── Graph 2 — Last 7 days ─────────────────────────────────────

  Future<List<GraphModel>> getGraph2() async {
    try {
      final all = await _getAllTransactions();
      final now = DateTime.now();
      const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      return List.generate(7, (i) {
        final day = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: 6 - i));

        final amount = all
            .where((t) =>
                !t.isIncome &&
                t.date.year == day.year &&
                t.date.month == day.month &&
                t.date.day == day.day)
            .fold(0.0, (acc, t) => acc + t.amount);

        return GraphModel(
          amount: amount,
          label: dayLabels[day.weekday - 1],
          type: 'week',
        );
      });
    } catch (_) {
      return [];
    }
  }

  // ── Graph 3 — Last 4 weeks ────────────────────────────────────

  Future<List<GraphModel>> getGraph3() async {
    try {
      final all = await _getAllTransactions();
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final result = <GraphModel>[];
      for (int i = 3; i >= 0; i--) {
        final weekEnd = todayStart.subtract(Duration(days: i * 7));
        final weekStart = weekEnd.subtract(const Duration(days: 7));

        final amount = all
            .where((t) =>
                !t.isIncome &&
                !t.date.isBefore(weekStart) &&
                t.date.isBefore(weekEnd))
            .fold(0.0, (acc, t) => acc + t.amount);

        result.add(GraphModel(
          amount: amount,
          label: 'Week ${4 - i}',
          type: 'month',
        ));
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  // ── Spending Forecast ─────────────────────────────────────────

  Future<PredictionModel?> getPrediction() async {
    try {
      final all = await _getAllTransactions();
      if (all.isEmpty) return null;

      final now = DateTime.now();
      final todayLocal = DateTime(now.year, now.month, now.day);
      final windowStart = todayLocal.subtract(const Duration(days: 29));

      final recentExpenses = all.where((t) {
        if (t.isIncome) return false;
        final txDate = DateTime(t.date.year, t.date.month, t.date.day);
        return !txDate.isAfter(todayLocal) && !txDate.isBefore(windowStart);
      }).toList();

      if (recentExpenses.isEmpty) return PredictionModel.zero;

      final oldest = recentExpenses
          .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
          .reduce((a, b) => a.isBefore(b) ? a : b);

      final daysWithData = todayLocal.difference(oldest).inDays + 1;
      final clampedDays = daysWithData.clamp(1, 30);

      if (clampedDays < 3) {
        final rawTotal = recentExpenses.fold(0.0, (acc, t) => acc + t.amount);
        final rawAvg = rawTotal / clampedDays;
        return PredictionModel(
          nextDaySum: rawAvg,
          nextWeekSum: rawAvg * 7,
          nextMonthSum: rawAvg * 30,
          daysOfData: clampedDays,
          confidence: PredictionConfidence.insufficient,
        );
      }

      final amounts = recentExpenses.map((t) => t.amount).toList()..sort();
      final trimCount = (amounts.length * 0.05).floor();
      final trimmed = trimCount > 0
          ? amounts.sublist(0, amounts.length - trimCount)
          : amounts;

      final trimmedTotal = trimmed.fold(0.0, (acc, a) => acc + a);
      final avgDaily = trimmedTotal / clampedDays;

      final confidence = clampedDays >= 14
          ? PredictionConfidence.high
          : clampedDays >= 7
              ? PredictionConfidence.medium
              : PredictionConfidence.low;

      return PredictionModel(
        nextDaySum: avgDaily,
        nextWeekSum: avgDaily * 7,
        nextMonthSum: avgDaily * 30,
        daysOfData: clampedDays,
        confidence: confidence,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Category breakdown ────────────────────────────────────────

  Future<Map<String, double>> getCategoryBreakdown() async {
    try {
      final all = await _getAllTransactions();
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final nextMonth = DateTime(now.year, now.month + 1, 1);

      final monthExpenses = all.where((tx) =>
          !tx.isIncome &&
          !tx.date.isBefore(monthStart) &&
          tx.date.isBefore(nextMonth));

      final Map<String, double> breakdown = {};
      for (final tx in monthExpenses) {
        final cat = tx.category ?? 'Other';
        breakdown[cat] = (breakdown[cat] ?? 0) + tx.amount;
      }
      return breakdown;
    } catch (_) {
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

      final todayStart = DateTime(now.year, now.month, now.day);
      final thisWeekStart =
          todayStart.subtract(Duration(days: now.weekday - 1));
      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
      final lastWeekEnd = thisWeekStart;

      final thisWeekTotal = expenses
          .where((t) => !t.date.isBefore(thisWeekStart))
          .fold(0.0, (acc, t) => acc + t.amount);

      final lastWeekTotal = expenses
          .where((t) =>
              !t.date.isBefore(lastWeekStart) && t.date.isBefore(lastWeekEnd))
          .fold(0.0, (acc, t) => acc + t.amount);

      // Week over week comparison
      if (lastWeekTotal > 0) {
        final diff = thisWeekTotal - lastWeekTotal;
        if (diff > 0) {
          insights.add(SmartInsight(
            iconType: InsightIcon.trendUp,
            title: 'Spending up this week',
            description:
                'You spent ₹${diff.toStringAsFixed(0)} more than last week.',
            isWarning: true,
          ));
        } else if (diff < 0) {
          insights.add(SmartInsight(
            iconType: InsightIcon.trendDown,
            title: 'Great savings this week',
            description:
                'You spent ₹${(-diff).toStringAsFixed(0)} less than last week.',
            isWarning: false,
          ));
        }
      }

      // Top category this month
      final monthStart = DateTime(now.year, now.month, 1);
      final nextMonth = DateTime(now.year, now.month + 1, 1);

      final monthExpenses = expenses.where(
          (tx) => !tx.date.isBefore(monthStart) && tx.date.isBefore(nextMonth));

      final Map<String, double> catMap = {};
      for (final tx in monthExpenses) {
        final cat = tx.category ?? 'Other';
        catMap[cat] = (catMap[cat] ?? 0) + tx.amount;
      }

      if (catMap.isNotEmpty) {
        final topCat =
            catMap.entries.reduce((a, b) => a.value > b.value ? a : b);
        insights.add(SmartInsight(
          iconType: InsightIcon.topCategory,
          title: '${topCat.key} is your top spend',
          description:
              'You spent ₹${topCat.value.toStringAsFixed(0)} on ${topCat.key} this month.',
          isWarning: false,
        ));
      }

      // Month projection
      final daysElapsed = now.day;
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final totalThisMonth = expenses
          .where((tx) =>
              !tx.date.isBefore(monthStart) && tx.date.isBefore(nextMonth))
          .fold(0.0, (acc, t) => acc + t.amount);

      if (daysElapsed > 0 && totalThisMonth > 0) {
        final projected = (totalThisMonth / daysElapsed) * daysInMonth;
        insights.add(SmartInsight(
          iconType: InsightIcon.projection,
          title: 'Month projection',
          description:
              'At this pace you\'ll spend ₹${projected.toStringAsFixed(0)} this month.',
          isWarning: projected > totalThisMonth * 1.2,
        ));
      }

      return insights;
    } catch (_) {
      return [];
    }
  }
}

// ── SmartInsight model ────────────────────────────────────────────

enum InsightIcon {
  trendUp,
  trendDown,
  topCategory,
  projection,
}

/// A single smart insight shown on the analytics screen.
class SmartInsight {
  final InsightIcon iconType;
  final String title;
  final String description;
  final bool isWarning;

  const SmartInsight({
    required this.iconType,
    required this.title,
    required this.description,
    required this.isWarning,
  });

  IconData get icon {
    switch (iconType) {
      case InsightIcon.trendUp:
        return CupertinoIcons.arrow_up_right_circle_fill;
      case InsightIcon.trendDown:
        return CupertinoIcons.arrow_down_left_circle_fill;
      case InsightIcon.topCategory:
        return CupertinoIcons.tag_fill;
      case InsightIcon.projection:
        return CupertinoIcons.waveform_path_ecg;
    }
  }
}
