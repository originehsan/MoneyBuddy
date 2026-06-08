// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_model.dart';

/// Handles all group Firestore operations.
/// Collection: groups/{groupId}
class GroupService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String get _uid   => _auth.currentUser!.uid;
  String get _email => _auth.currentUser!.email ?? '';

  CollectionReference get _groupsCollection =>
      _firestore.collection('groups');

  // ── Get groups ────────────────────────────────────────────────

  /// Fetches all groups where current user is creator or member.
  Future<List<GroupModel>> getGroups() async {
    try {
      final snapshot = await _groupsCollection
          .where('createdBy', isEqualTo: _uid)
          .get();

      return snapshot.docs
          .map((doc) => GroupModel.fromFirestore(doc))
          .toList();
    } catch (e) {
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
      await _groupsCollection.add({
        'title':       title,
        'description': description,
        'createdBy':   _uid,
        'creatorEmail': _email,
        'members':     members,
        'createdAt':   FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
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
      // Get group members for split calculation
      final groupDoc = await _groupsCollection.doc(groupId).get();
      final members  = List<String>.from(
        (groupDoc.data() as Map<String, dynamic>)['members'] ?? [],
      );

      // Calculate equal split excluding initiator
      final otherMembers = members
          .where((m) => m != _email)
          .toList();
      final share = otherMembers.isEmpty
          ? amount
          : amount / (otherMembers.length + 1);

      final splitDetails = otherMembers.map((memberEmail) => {
        'memberEmail': memberEmail,
        'share':       share,
        'paid':        false,
      }).toList();

      await _groupsCollection
          .doc(groupId)
          .collection('expenses')
          .add({
        'description':   description,
        'amount':        amount,
        'date':          Timestamp.fromDate(DateTime.parse(date)),
        'initiatedBy':   _email,
        'splitDetails':  splitDetails,
        'createdAt':     FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Get group with expenses ───────────────────────────────────

  Future<GroupModel?> getGroupById(String groupId) async {
    try {
      final groupDoc     = await _groupsCollection.doc(groupId).get();
      final expensesSnap = await _groupsCollection
          .doc(groupId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      return GroupModel.fromFirestoreWithExpenses(groupDoc, expensesSnap.docs);
    } catch (e) {
      return null;
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

      // Update paid status for this member
      final updated = splits.map((split) {
        if (split['memberEmail'] == memberEmail) {
          return {...split, 'paid': true};
        }
        return split;
      }).toList();

      await expenseRef.update({'splitDetails': updated});
      return true;
    } catch (e) {
      return false;
    }
  }
}