// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles all profile Firebase operations.
/// Covers Auth + Firestore user document updates.
class ProfileService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  DocumentReference get _userDoc =>
      _firestore.collection('users').doc(_uid);

  // ── Balance ───────────────────────────────────────────────────

  Future<bool> updateBalance(double amount) async {
    try {
      await _userDoc.set(
        {'accountBalance': amount},
        SetOptions(merge: true),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Name ──────────────────────────────────────────────────────

  /// Updates display name in both Firebase Auth and Firestore.
  Future<bool> updateName(String name) async {
    try {
      await Future.wait([
        _auth.currentUser!.updateDisplayName(name),
        _userDoc.set({'name': name}, SetOptions(merge: true)),
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Password ──────────────────────────────────────────────────

  /// Changes password — requires recent login (reauthentication).
  /// Returns error message string or null on success.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user  = _auth.currentUser!;
      final email = user.email!;

      // Reauthenticate before sensitive operation
      final credential = EmailAuthProvider.credential(
        email:    email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          return 'Current password is incorrect';
        case 'weak-password':
          return 'New password is too weak';
        case 'requires-recent-login':
          return 'Please log out and log in again before changing password';
        default:
          return e.message ?? 'Failed to change password';
      }
    } catch (_) {
      return 'Something went wrong';
    }
  }

  // ── Delete account ────────────────────────────────────────────

  /// Deletes account — cleans up Firestore data + Firebase Auth.
  /// Requires reauthentication.
  Future<String?> deleteAccount(String currentPassword) async {
    try {
      final user  = _auth.currentUser!;
      final email = user.email!;

      // Reauthenticate
      final credential = EmailAuthProvider.credential(
        email:    email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete Firestore data — transactions + user doc
      final txSnap = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('transactions')
          .get();

      final batch = _firestore.batch();
      for (final doc in txSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_userDoc);
      await batch.commit();

      // Delete Firebase Auth account
      await user.delete();
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          return 'Password is incorrect';
        case 'requires-recent-login':
          return 'Please log out and log in again';
        default:
          return e.message ?? 'Failed to delete account';
      }
    } catch (_) {
      return 'Something went wrong';
    }
  }
}