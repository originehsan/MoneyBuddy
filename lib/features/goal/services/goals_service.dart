// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal_model.dart';

class GoalsService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _goalsCollection =>
      _firestore.collection('users').doc(_uid).collection('goals');

  // ── Read ──────────────────────────────────────────────────────

  Future<List<GoalModel>> getGoals() async {
    try {
      final snap = await _goalsCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map(GoalModel.fromFirestore).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Create ────────────────────────────────────────────────────

  Future<bool> createGoal({
    required String   title,
    required String   icon,
    required double   targetAmount,
    required DateTime deadline,
  }) async {
    try {
      await _goalsCollection.add({
        'title':        title,
        'icon':         icon,
        'targetAmount': targetAmount,
        'savedAmount':  0.0,
        'deadline':     Timestamp.fromDate(deadline),
        'createdAt':    FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Update ────────────────────────────────────────────────────

  Future<bool> updateGoal({
    required String   id,
    required String   title,
    required String   icon,
    required double   targetAmount,
    required DateTime deadline,
  }) async {
    try {
      await _goalsCollection.doc(id).update({
        'title':        title,
        'icon':         icon,
        'targetAmount': targetAmount,
        'deadline':     Timestamp.fromDate(deadline),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Add money to goal ─────────────────────────────────────────

  Future<bool> addMoney(String id, double amount) async {
    try {
      final doc  = await _goalsCollection.doc(id).get();
      final data = doc.data() as Map<String, dynamic>;
      final current = (data['savedAmount'] as num?)?.toDouble() ?? 0.0;
      await _goalsCollection.doc(id).update({
        'savedAmount': current + amount,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Delete ────────────────────────────────────────────────────

  Future<bool> deleteGoal(String id) async {
    try {
      await _goalsCollection.doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}