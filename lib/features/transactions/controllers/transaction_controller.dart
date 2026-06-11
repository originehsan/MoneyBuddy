// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../../core/constants/app_colors.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../../speech/speech_service.dart';

/// Manages transaction list, filtering, search, and add/edit/delete.
class TransactionController extends GetxController {
  final _service = TransactionService();
  final _speechService = SpeechService();
  final _parser = GrammarParser();
  final _evaluator = RealEvaluator();

  // ── List state ────────────────────────────────────────────────
  final isLoading = true.obs;
  final transactions = <TransactionModel>[].obs;
  final filterIndex = 0.obs;
  final errorMessage = ''.obs;

  // ── Search + filter ───────────────────────────────────────────
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final isSearching = false.obs;
  final dateFrom = Rxn<DateTime>();
  final dateTo = Rxn<DateTime>();

  // ── Add/Edit form state ───────────────────────────────────────
  final isSubmitting = false.obs;
  final isExpense = true.obs;
  final amountController = TextEditingController();
  final descController = TextEditingController();
  final selectedDate = DateTime.now().obs;
  final selectedCategory = 'Other'.obs;
  final calculatorResult = ''.obs;

  // ── Edit mode ─────────────────────────────────────────────────
  final isEditMode = false.obs;
  final editingTxId = ''.obs;

  // ── Voice input ───────────────────────────────────────────────
  final isListening = false.obs;
  final voiceText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
    amountController.addListener(_evaluateExpression);
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  // ── Load ──────────────────────────────────────────────────────

  Future<void> loadTransactions() async {
    isLoading.value = true;
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

  // ── Filter + Search + Group ───────────────────────────────────

  List<TransactionModel> get filteredTransactions {
    var list = transactions.toList();

    // Type filter
    switch (filterIndex.value) {
      case 1:
        list = list.where((t) => t.isIncome).toList();
        break;
      case 2:
        list = list.where((t) => !t.isIncome).toList();
        break;
    }

    // Search filter
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list
          .where((t) =>
              t.description.toLowerCase().contains(q) ||
              (t.category?.toLowerCase().contains(q) ?? false) ||
              t.amount.toString().contains(q))
          .toList();
    }

    // Date range filter
    if (dateFrom.value != null) {
      list = list.where((t) => !t.date.isBefore(dateFrom.value!)).toList();
    }
    if (dateTo.value != null) {
      final end = dateTo.value!.add(const Duration(days: 1));
      list = list.where((t) => t.date.isBefore(end)).toList();
    }

    return list;
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    isSearching.value = false;
  }

  void clearDateFilter() {
    dateFrom.value = null;
    dateTo.value = null;
  }

  bool get hasActiveFilter => dateFrom.value != null || dateTo.value != null;

  // ── Calculator ────────────────────────────────────────────────

  void _evaluateExpression() {
    final text = amountController.text.trim();
    if (text.isEmpty || !text.contains(RegExp(r'[+\-*/]'))) {
      calculatorResult.value = '';
      return;
    }
    try {
      final result = _evaluator.evaluate(_parser.parse(text)).toDouble();
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
      } catch (_) {
        return null;
      }
    }
    return double.tryParse(text);
  }

  // ── Voice input ───────────────────────────────────────────────

  Future<void> toggleVoiceInput() async {
    if (isListening.value) {
      await _speechService.stopListening();
      isListening.value = false;

      // Parse the final voice text
      if (voiceText.value.isNotEmpty) {
        final parsed = SpeechService.parse(voiceText.value);
        if (parsed.amount != null) {
          amountController.text = parsed.amount!.toStringAsFixed(0);
        }
        if (parsed.description.isNotEmpty) {
          descController.text = parsed.description;
        }
        isExpense.value = !parsed.isIncome;
        voiceText.value = '';
      }
    } else {
      final available = await _speechService.initialize();
      if (!available) {
        _showError('Microphone not available');
        return;
      }
      isListening.value = true;
      voiceText.value = '';
      await _speechService.startListening(
        onResult: (text) => voiceText.value = text,
        onDone: () {
          isListening.value = false;
          if (voiceText.value.isNotEmpty) {
            final parsed = SpeechService.parse(voiceText.value);
            if (parsed.amount != null) {
              amountController.text = parsed.amount!.toStringAsFixed(0);
            }
            if (parsed.description.isNotEmpty) {
              descController.text = parsed.description;
            }
            isExpense.value = !parsed.isIncome;
            voiceText.value = '';
          }
        },
      );
    }
  }

  // ── Submit (add or edit) ──────────────────────────────────────

  Future<void> submitTransaction() async {
    final amount = resolvedAmount;
    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount');
      return;
    }
    if (descController.text.trim().isEmpty) {
      _showError('Enter a description');
      return;
    }

    isSubmitting.value = true;
    try {
      bool success;
      if (isEditMode.value) {
        success = await _service.editTransaction(
          id: editingTxId.value,
          type: isExpense.value ? 'Expense' : 'Income',
          amount: amount,
          description: descController.text.trim(),
          date: selectedDate.value.toIso8601String(),
          category: selectedCategory.value,
        );
        if (success) _showSuccess('Transaction updated');
      } else {
        success = await _service.addTransaction(
          type: isExpense.value ? 'Expense' : 'Income',
          amount: amount,
          description: descController.text.trim(),
          date: selectedDate.value.toIso8601String(),
          category: selectedCategory.value,
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

  // ── Edit ──────────────────────────────────────────────────────

  void startEdit(TransactionModel tx) {
    isEditMode.value = true;
    editingTxId.value = tx.id;
    isExpense.value = !tx.isIncome;
    amountController.text = tx.amount.toStringAsFixed(0);
    descController.text = tx.description;
    selectedDate.value = tx.date;
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

  // ── Reset ─────────────────────────────────────────────────────

  void _resetForm() {
    isEditMode.value = false;
    editingTxId.value = '';
    amountController.clear();
    descController.clear();
    selectedDate.value = DateTime.now();
    selectedCategory.value = 'Other';
    isExpense.value = true;
    calculatorResult.value = '';
    voiceText.value = '';
    isListening.value = false;
  }

  void resetForm() => _resetForm();

  // ── Snackbars ─────────────────────────────────────────────────

  void _showError(String msg) => Get.snackbar(
        'Error',
        msg,
        backgroundColor: AppColors.kError,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

  void _showSuccess(String msg) => Get.snackbar(
        'Success',
        msg,
        backgroundColor: AppColors.kSuccess,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

  @override
  void onClose() {
    amountController.dispose();
    descController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
