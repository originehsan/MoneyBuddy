// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../models/goal_model.dart';
import '../services/goals_service.dart';

class GoalsController extends GetxController {
  final _service = GoalsService();

  final isLoading    = true.obs;
  final goals        = <GoalModel>[].obs;
  final errorMessage = ''.obs;

  // ── Form state ────────────────────────────────────────────────
  final titleController  = TextEditingController();
  final amountController = TextEditingController();
  final addMoneyController = TextEditingController();
  final selectedIcon     = 'star'.obs;
  final selectedDeadline = DateTime.now()
      .add(const Duration(days: 90)).obs;
  final isSubmitting     = false.obs;
  final isEditMode       = false.obs;
  final editingGoalId    = ''.obs;

  static const icons = [
    'star', 'house', 'car', 'airplane', 'bag',
    'gift', 'heart', 'graduationcap', 'phone', 'laptop',
  ];

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  Future<void> loadGoals() async {
    isLoading.value    = true;
    errorMessage.value = '';
    try {
      goals.value = await _service.getGoals();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Create / Update ───────────────────────────────────────────

  Future<void> submitGoal() async {
    final title  = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim());

    if (title.isEmpty)  { _showError('Enter a goal name'); return; }
    if (amount == null || amount <= 0) {
      _showError('Enter a valid target amount'); return;
    }

    isSubmitting.value = true;
    try {
      bool success;
      if (isEditMode.value) {
        success = await _service.updateGoal(
          id:           editingGoalId.value,
          title:        title,
          icon:         selectedIcon.value,
          targetAmount: amount,
          deadline:     selectedDeadline.value,
        );
        if (success) _showSuccess('Goal updated');
      } else {
        success = await _service.createGoal(
          title:        title,
          icon:         selectedIcon.value,
          targetAmount: amount,
          deadline:     selectedDeadline.value,
        );
        if (success) _showSuccess('Goal created');
      }

      if (success) {
        await loadGoals();
        Get.back();
        _resetForm();
      } else {
        _showError('Failed to save goal');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Add money ─────────────────────────────────────────────────

  Future<void> addMoney(String goalId) async {
    final amount = double.tryParse(addMoneyController.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount'); return;
    }
    try {
      final success = await _service.addMoney(goalId, amount);
      if (success) {
        _showSuccess('₹${amount.toStringAsFixed(0)} added');
        addMoneyController.clear();
        await loadGoals();
        Get.back();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  // ── Delete ────────────────────────────────────────────────────

  Future<void> deleteGoal(String id) async {
    try {
      final success = await _service.deleteGoal(id);
      if (success) {
        goals.removeWhere((g) => g.id == id);
        _showSuccess('Goal deleted');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  // ── Start edit ────────────────────────────────────────────────

  void startEdit(GoalModel goal) {
    isEditMode.value       = true;
    editingGoalId.value    = goal.id;
    titleController.text   = goal.title;
    amountController.text  = goal.targetAmount.toStringAsFixed(0);
    selectedIcon.value     = goal.icon;
    selectedDeadline.value = goal.deadline;
  }

  void _resetForm() {
    isEditMode.value       = false;
    editingGoalId.value    = '';
    titleController.clear();
    amountController.clear();
    selectedIcon.value     = 'star';
    selectedDeadline.value =
        DateTime.now().add(const Duration(days: 90));
  }

  void resetForm() => _resetForm();

  void _showError(String msg) => Get.snackbar(
    'Error', msg,
    backgroundColor: AppColors.kError,
    colorText:       Colors.white,
    snackPosition:   SnackPosition.BOTTOM,
  );

  void _showSuccess(String msg) => Get.snackbar(
    'Success', msg,
    backgroundColor: AppColors.kSuccess,
    colorText:       Colors.white,
    snackPosition:   SnackPosition.BOTTOM,
  );

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    addMoneyController.dispose();
    super.onClose();
  }
}