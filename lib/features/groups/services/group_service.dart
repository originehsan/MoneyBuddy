// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_model.dart';

class GroupService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String get _uid   => _auth.currentUser!.uid;
  String get _email => _auth.currentUser!.email ?? '';

  CollectionReference get _groups => _firestore.collection('groups');

  // ── Get all groups ────────────────────────────────────────────

  Future<List<GroupModel>> getGroups() async {
    try {
      final snap = await _groups
          .where('createdBy', isEqualTo: _uid)
          .get();

      final groups = <GroupModel>[];
      for (final doc in snap.docs) {
        final expensesSnap = await _groups
            .doc(doc.id)
            .collection('expenses')
            .orderBy('date', descending: true)
            .get();
        groups.add(GroupModel.fromFirestoreWithExpenses(
            doc, expensesSnap.docs));
      }
      return groups;
    } catch (_) {
      return [];
    }
  }

  // ── Create group ──────────────────────────────────────────────

  Future<bool> createGroup({
    required String             title,
    required String             description,
    required List<GroupMember>  members,
    required String             creatorName,
  }) async {
    try {
      // Creator always first member
      final creator = GroupMember(name: creatorName, email: _email);
      final allMembers = [
        creator,
        ...members.where((m) => m.email != _email),
      ];

      await _groups.add({
        'title':        title,
        'description':  description,
        'createdBy':    _uid,
        'creatorEmail': _email,
        'members':      allMembers.map((m) => m.toMap()).toList(),
        'createdAt':    FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Update group ──────────────────────────────────────────────

  Future<bool> updateGroup({
    required String            groupId,
    required String            title,
    required String            description,
    required List<GroupMember> members,
  }) async {
    try {
      await _groups.doc(groupId).update({
        'title':       title,
        'description': description,
        'members':     members.map((m) => m.toMap()).toList(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Delete group ──────────────────────────────────────────────

  Future<bool> deleteGroup(String groupId) async {
    try {
      final expensesSnap = await _groups
          .doc(groupId)
          .collection('expenses')
          .get();

      final batch = _firestore.batch();
      for (final doc in expensesSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_groups.doc(groupId));
      await batch.commit();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Add expense ───────────────────────────────────────────────

  Future<bool> addGroupExpense({
    required String          groupId,
    required String          description,
    required double          amount,
    required String          paidBy,       // email
    required String          paidByName,   // display name
    required List<GroupMember> splitBetween, // who shares this
    required String          date,
  }) async {
    try {
      final count        = splitBetween.length;
      final perPerson    = count > 0 ? amount / count : amount;

      // Settlements = everyone except paidBy
      final settlements = splitBetween
          .where((m) => m.email != paidBy)
          .map((m) => Settlement(
                name:   m.displayName,
                email:  m.email,
                amount: perPerson,
                paid:   false,
              ).toMap())
          .toList();

      await _groups
          .doc(groupId)
          .collection('expenses')
          .add({
        'description':   description,
        'amount':        amount,
        'paidBy':        paidBy,
        'paidByName':    paidByName,
        'splitBetween':  splitBetween.map((m) => m.email).toList(),
        'perPersonShare': perPerson,
        'settlements':   settlements,
        'date':          Timestamp.fromDate(DateTime.parse(date)),
        'createdAt':     FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Update expense ────────────────────────────────────────────

  Future<bool> updateGroupExpense({
    required String            groupId,
    required String            expenseId,
    required String            description,
    required double            amount,
    required String            paidBy,
    required String            paidByName,
    required List<GroupMember> splitBetween,
    required String            date,
  }) async {
    try {
      // Get old settlements to preserve paid status
      final expDoc = await _groups
          .doc(groupId)
          .collection('expenses')
          .doc(expenseId)
          .get();

      final oldSettlements = ((expDoc.data()
              as Map<String, dynamic>)['settlements'] as List<dynamic>? ??
          [])
          .map((s) => Settlement.fromMap(s as Map<String, dynamic>))
          .toList();

      final oldPaidMap = {
        for (final s in oldSettlements) s.email: s.paid,
      };

      final count     = splitBetween.length;
      final perPerson = count > 0 ? amount / count : amount;

      final settlements = splitBetween
          .where((m) => m.email != paidBy)
          .map((m) => Settlement(
                name:   m.displayName,
                email:  m.email,
                amount: perPerson,
                paid:   oldPaidMap[m.email] ?? false,
              ).toMap())
          .toList();

      await _groups
          .doc(groupId)
          .collection('expenses')
          .doc(expenseId)
          .update({
        'description':   description,
        'amount':        amount,
        'paidBy':        paidBy,
        'paidByName':    paidByName,
        'splitBetween':  splitBetween.map((m) => m.email).toList(),
        'perPersonShare': perPerson,
        'settlements':   settlements,
        'date':          Timestamp.fromDate(DateTime.parse(date)),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Delete expense ────────────────────────────────────────────

  Future<bool> deleteExpense({
    required String groupId,
    required String expenseId,
  }) async {
    try {
      await _groups
          .doc(groupId)
          .collection('expenses')
          .doc(expenseId)
          .delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Mark settlement as paid ───────────────────────────────────

  Future<bool> markSettlementPaid({
    required String groupId,
    required String expenseId,
    required String memberEmail,
  }) async {
    try {
      final ref = _groups
          .doc(groupId)
          .collection('expenses')
          .doc(expenseId);

      final doc  = await ref.get();
      final data = doc.data() as Map<String, dynamic>;
      final settlements = List<Map<String, dynamic>>.from(
          data['settlements'] ?? []);

      final updated = settlements.map((s) {
        if (s['email'] == memberEmail) {
          return {...s, 'paid': true};
        }
        return s;
      }).toList();

      await ref.update({'settlements': updated});
      return true;
    } catch (_) {
      return false;
    }
  }
}