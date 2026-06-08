// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_model.dart';

/// Handles all group Firestore operations.
/// Structure: groups/{groupId}/expenses/{expenseId}
class GroupService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String get _uid   => _auth.currentUser!.uid;
  String get _email => _auth.currentUser!.email ?? '';

  CollectionReference get _groupsCollection =>
      _firestore.collection('groups');

  // ── Get all groups ────────────────────────────────────────────
  // Fetches groups where user is creator OR member

  Future<List<GroupModel>> getGroups() async {
    try {
      // Groups created by user
      final createdSnap = await _groupsCollection
          .where('createdBy', isEqualTo: _uid)
          .get();

      // Groups where user is a member (by email)
      final memberSnap = await _groupsCollection
          .where('members', arrayContains: _email)
          .get();

      // Merge and deduplicate by doc ID
      final allDocs = <String, DocumentSnapshot>{};
      for (final doc in [...createdSnap.docs, ...memberSnap.docs]) {
        allDocs[doc.id] = doc;
      }

      // Fetch expenses for each group
      final groups = <GroupModel>[];
      for (final doc in allDocs.values) {
        final expensesSnap = await _groupsCollection
            .doc(doc.id)
            .collection('expenses')
            .orderBy('date', descending: true)
            .get();
        groups.add(
          GroupModel.fromFirestoreWithExpenses(doc, expensesSnap.docs),
        );
      }

      return groups;
    } catch (_) {
      return [];
    }
  }

  // ── Create group ──────────────────────────────────────────────

  Future<bool> createGroup({
    required String title,
    required String description,
    required List<String> members,
  }) async {
    try {
      // Always include creator email in members list
      final allMembers = [_email, ...members.where((m) => m != _email)];
      await _groupsCollection.add({
        'title':        title,
        'description':  description,
        'createdBy':    _uid,
        'creatorEmail': _email,
        'members':      allMembers,
        'createdAt':    FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Update group ──────────────────────────────────────────────

  Future<bool> updateGroup({
    required String groupId,
    required String title,
    required String description,
    required List<String> members,
  }) async {
    try {
      final allMembers = [_email, ...members.where((m) => m != _email)];
      await _groupsCollection.doc(groupId).update({
        'title':       title,
        'description': description,
        'members':     allMembers,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Delete group ──────────────────────────────────────────────
  // Deletes group + all its expenses (Firestore subcollection cleanup)

  Future<bool> deleteGroup(String groupId) async {
    try {
      // Delete all expenses first
      final expensesSnap = await _groupsCollection
          .doc(groupId)
          .collection('expenses')
          .get();

      final batch = _firestore.batch();
      for (final doc in expensesSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_groupsCollection.doc(groupId));
      await batch.commit();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Add expense ───────────────────────────────────────────────

  Future<bool> addGroupExpense({
    required String groupId,
    required String description,
    required double amount,
    required String date,
  }) async {
    try {
      final groupDoc = await _groupsCollection.doc(groupId).get();
      final data     = groupDoc.data() as Map<String, dynamic>;
      final members  = List<String>.from(data['members'] ?? []);

      // Split equally among all members including initiator
      final share = members.isEmpty ? amount : amount / members.length;

      final splitDetails = members.map((memberEmail) => {
        'memberEmail': memberEmail,
        'share':       share,
        'paid':        memberEmail == _email, // initiator auto-marked paid
      }).toList();

      await _groupsCollection
          .doc(groupId)
          .collection('expenses')
          .add({
        'description':  description,
        'amount':       amount,
        'date':         Timestamp.fromDate(DateTime.parse(date)),
        'initiatedBy':  _email,
        'splitDetails': splitDetails,
        'createdAt':    FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Update expense ────────────────────────────────────────────

  Future<bool> updateGroupExpense({
    required String groupId,
    required String expenseId,
    required String description,
    required double amount,
    required String date,
  }) async {
    try {
      final groupDoc = await _groupsCollection.doc(groupId).get();
      final data     = groupDoc.data() as Map<String, dynamic>;
      final members  = List<String>.from(data['members'] ?? []);

      final share = members.isEmpty ? amount : amount / members.length;

      // Recalculate splits preserving paid status
      final expenseDoc = await _groupsCollection
          .doc(groupId)
          .collection('expenses')
          .doc(expenseId)
          .get();

      final oldSplits = List<Map<String, dynamic>>.from(
        (expenseDoc.data() as Map<String, dynamic>)['splitDetails'] ?? [],
      );

      final oldPaidMap = {
        for (final s in oldSplits)
          s['memberEmail'] as String: s['paid'] as bool,
      };

      final newSplits = members.map((memberEmail) => {
        'memberEmail': memberEmail,
        'share':       share,
        'paid':        oldPaidMap[memberEmail] ?? (memberEmail == _email),
      }).toList();

      await _groupsCollection
          .doc(groupId)
          .collection('expenses')
          .doc(expenseId)
          .update({
        'description':  description,
        'amount':       amount,
        'date':         Timestamp.fromDate(DateTime.parse(date)),
        'splitDetails': newSplits,
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
      await _groupsCollection
          .doc(groupId)
          .collection('expenses')
          .doc(expenseId)
          .delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Mark expense as paid ──────────────────────────────────────

  Future<bool> markAsPaid({
    required String groupId,
    required String expenseId,
    required String memberEmail,
  }) async {
    try {
      final expenseRef = _groupsCollection
          .doc(groupId)
          .collection('expenses')
          .doc(expenseId);

      final expenseDoc = await expenseRef.get();
      final data       = expenseDoc.data() as Map<String, dynamic>;
      final splits     = List<Map<String, dynamic>>.from(
        data['splitDetails'] ?? [],
      );

      final updated = splits.map((split) {
        if (split['memberEmail'] == memberEmail) {
          return {...split, 'paid': true};
        }
        return split;
      }).toList();

      await expenseRef.update({'splitDetails': updated});
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Get group by ID ───────────────────────────────────────────

  Future<GroupModel?> getGroupById(String groupId) async {
    try {
      final groupDoc     = await _groupsCollection.doc(groupId).get();
      final expensesSnap = await _groupsCollection
          .doc(groupId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();
      return GroupModel.fromFirestoreWithExpenses(groupDoc, expensesSnap.docs);
    } catch (_) {
      return null;
    }
  }
}