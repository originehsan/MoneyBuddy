// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../../core/constants/app_colors.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

/// Manages transaction list state, filtering, and add/delete/edit operations.
class TransactionController extends GetxController {
  final _service   = TransactionService();
  final _parser    = GrammarParser();
  final _evaluator = RealEvaluator();

  // ── List state ────────────────────────────────────────────────
  final isLoading    = true.obs;
  final transactions = <TransactionModel>[].obs;
  final filterIndex  = 0.obs;
  final errorMessage = ''.obs;

  // ── Add/Edit form state ───────────────────────────────────────
  final isSubmitting     = false.obs;
  final isExpense        = true.obs;
  final amountController = TextEditingController();
  final descController   = TextEditingController();
  final selectedDate     = DateTime.now().obs;
  final selectedCategory = 'Other'.obs;
  final calculatorResult = ''.obs;

  // ── Edit mode state ───────────────────────────────────────────
  final isEditMode      = false.obs;
  final editingTxId     = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
    amountController.addListener(_evaluateExpression);
  }

  // ── Load ──────────────────────────────────────────────────────

  Future<void> loadTransactions() async {
    isLoading.value    = true;
    errorMessage.value = '';
    try {
      final list = await _service.getTransactions();
      transactions.value = list;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Filter + Group ────────────────────────────────────────────

  List<TransactionModel> get filteredTransactions {
    switch (filterIndex.value) {
      case 1:  return transactions.where((t) => t.isIncome).toList();
      case 2:  return transactions.where((t) => !t.isIncome).toList();
      default: return transactions;
    }
  }

  Map<String, List<TransactionModel>> get groupedTransactions {
    final map = <String, List<TransactionModel>>{};
    for (final tx in filteredTransactions) {
      final key = _dateKey(tx.date);
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map;
  }

  String _dateKey(DateTime date) {
    final now    = DateTime.now();
    final today  = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff   = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  // ── Calculator ────────────────────────────────────────────────

  void _evaluateExpression() {
    final text = amountController.text.trim();
    if (text.isEmpty || !text.contains(RegExp(r'[+\-*/]'))) {
      calculatorResult.value = ''; return;
    }
    try {
      final result = _evaluator
          .evaluate(_parser.parse(text))
          .toDouble();
      calculatorResult.value = '= ${result.toStringAsFixed(2)}';
    } catch (_) {
      calculatorResult.value = '';
    }
  }

  double? get resolvedAmount {
    final text = amountController.text.trim();
    if (text.isEmpty) return null;
    if (text.contains(RegExp(r'[+\-*/]'))) {
      try {
        return _evaluator.evaluate(_parser.parse(text)).toDouble();
      } catch (_) { return null; }
    }
    return double.tryParse(text);
  }

  // ── Add transaction ───────────────────────────────────────────

  Future<void> submitTransaction() async {
    final amount = resolvedAmount;
    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount'); return;
    }
    if (descController.text.trim().isEmpty) {
      _showError('Enter a description'); return;
    }

    isSubmitting.value = true;
    try {
      bool success;

      if (isEditMode.value) {
        // Edit existing transaction
        success = await _service.editTransaction(
          id:          editingTxId.value,
          type:        isExpense.value ? 'Expense' : 'Income',
          amount:      amount,
          description: descController.text.trim(),
          date:        selectedDate.value.toIso8601String(),
          category:    selectedCategory.value,
        );
        if (success) _showSuccess('Transaction updated');
      } else {
        // Add new transaction
        success = await _service.addTransaction(
          type:        isExpense.value ? 'Expense' : 'Income',
          amount:      amount,
          description: descController.text.trim(),
          date:        selectedDate.value.toIso8601String(),
          category:    selectedCategory.value,
        );
        if (success) _showSuccess('Transaction added');
      }

      if (success) {
        await loadTransactions();
        Get.back();
        _resetForm();
      } else {
        _showError(isEditMode.value
            ? 'Failed to update transaction'
            : 'Failed to add transaction');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Edit — pre-fill form with existing transaction ────────────

  void startEdit(TransactionModel tx) {
    isEditMode.value      = true;
    editingTxId.value     = tx.id;
    isExpense.value       = !tx.isIncome;
    amountController.text = tx.amount.toString();
    descController.text   = tx.description;
    selectedDate.value    = tx.date;
    selectedCategory.value = tx.category ?? 'Other';
  }

  // ── Delete ────────────────────────────────────────────────────

  Future<void> deleteTransaction(String id) async {
    try {
      final success = await _service.deleteTransaction(id);
      if (success) {
        transactions.removeWhere((t) => t.id == id);
        _showSuccess('Transaction deleted');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  // ── Reset form ────────────────────────────────────────────────

  void _resetForm() {
    isEditMode.value       = false;
    editingTxId.value      = '';
    amountController.clear();
    descController.clear();
    selectedDate.value     = DateTime.now();
    selectedCategory.value = 'Other';
    isExpense.value        = true;
    calculatorResult.value = '';
  }

  void resetForm() => _resetForm();

  // ── Snackbars ─────────────────────────────────────────────────

  void _showError(String msg) => Get.snackbar(
    'Error', msg,
    backgroundColor: AppColors.kError,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );

  void _showSuccess(String msg) => Get.snackbar(
    'Success', msg,
    backgroundColor: AppColors.kSuccess,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );

  @override
  void onClose() {
    amountController.dispose();
    descController.dispose();
    super.onClose();
  }
}