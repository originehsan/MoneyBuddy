// MoneyBuddy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/emi_model.dart';

class EmiService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _emisCollection =>
      _firestore.collection('users').doc(_uid).collection('emis');

  Future<List<EmiModel>> getEmis() async {
    try {
      final snap = await _emisCollection
          .orderBy('startDate', descending: false)
          .get();
      return snap.docs.map(EmiModel.fromFirestore).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> createEmi({
    required String   name,
    required String   icon,
    required double   totalAmount,
    required double   emiAmount,
    required int      totalMonths,
    required DateTime startDate,
    double?           interestRate,
  }) async {
    try {
      await _emisCollection.add({
        'name':         name,
        'icon':         icon,
        'totalAmount':  totalAmount,
        'emiAmount':    emiAmount,
        'totalMonths':  totalMonths,
        'paidMonths':   0,
        'startDate':    Timestamp.fromDate(startDate),
        if (interestRate != null) 'interestRate': interestRate,
        'createdAt':    FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateEmi({
    required String   id,
    required String   name,
    required String   icon,
    required double   totalAmount,
    required double   emiAmount,
    required int      totalMonths,
    required DateTime startDate,
    double?           interestRate,
  }) async {
    try {
      await _emisCollection.doc(id).update({
        'name':        name,
        'icon':        icon,
        'totalAmount': totalAmount,
        'emiAmount':   emiAmount,
        'totalMonths': totalMonths,
        'startDate':   Timestamp.fromDate(startDate),
        if (interestRate != null) 'interestRate': interestRate,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markMonthPaid(String id, int currentPaid) async {
    try {
      await _emisCollection.doc(id).update({
        'paidMonths': currentPaid + 1,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteEmi(String id) async {
    try {
      await _emisCollection.doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}