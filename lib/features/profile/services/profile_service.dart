// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles profile Firestore operations.
class ProfileService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  DocumentReference get _userDoc =>
      _firestore.collection('users').doc(_uid);

  /// Updates account balance in Firestore.
  Future<bool> updateBalance(double amount) async {
    try {
      await _userDoc.set(
        {'accountBalance': amount},
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Updates display name in Firebase Auth.
  Future<bool> updateName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name);
      return true;
    } catch (e) {
      return false;
    }
  }
}