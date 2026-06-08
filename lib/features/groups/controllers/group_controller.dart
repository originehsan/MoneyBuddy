// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

/// Manages all group state — list, create, edit, delete,
/// expenses CRUD, mark as paid.
class GroupController extends GetxController {
  final _service = GroupService();

  // ── List state ────────────────────────────────────────────────
  final isLoading    = true.obs;
  final groups       = <GroupModel>[].obs;
  final errorMessage = ''.obs;

  // ── Group form state ──────────────────────────────────────────
  final titleController = TextEditingController();
  final descController  = TextEditingController();
  final isSubmitting    = false.obs;
  final isEditMode      = false.obs;
  final editingGroupId  = ''.obs;

  final memberControllers = <TextEditingController>[
    TextEditingController(),
  ].obs;

  // ── Expense form state ────────────────────────────────────────
  final expenseAmountController = TextEditingController();
  final expenseDescController   = TextEditingController();
  final selectedDate            = DateTime.now().obs;
  final selectedGroupId         = ''.obs;
  final isExpenseSubmitting     = false.obs;
  final isExpenseEditMode       = false.obs;
  final editingExpenseId        = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  // ── Load ──────────────────────────────────────────────────────

  Future<void> loadGroups() async {
    isLoading.value    = true;
    errorMessage.value = '';
    try {
      final list = await _service.getGroups();
      groups.value = list;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Member field management ───────────────────────────────────

  void addMember() {
    if (memberControllers.length < 10) {
      memberControllers.add(TextEditingController());
    }
  }

  void removeMember(int index) {
    if (memberControllers.length > 1) {
      memberControllers[index].dispose();
      memberControllers.removeAt(index);
    }
  }

  // ── Start edit group — pre-fill form ─────────────────────────

  void startEditGroup(GroupModel group) {
    isEditMode.value     = true;
    editingGroupId.value = group.id;
    titleController.text = group.title;
    descController.text  = group.description;

    // Pre-fill member controllers (excluding creator email)
    for (final c in memberControllers) { c.dispose(); }
    final otherMembers = group.members
        .where((m) => m.email != group.members.first.email)
        .map((m) => m.email)
        .toList();

    if (otherMembers.isEmpty) {
      memberControllers.assignAll([TextEditingController()]);
    } else {
      memberControllers.assignAll(
        otherMembers.map((e) => TextEditingController(text: e)).toList(),
      );
    }
  }

  // ── Create or Update group ────────────────────────────────────

  Future<void> submitGroup() async {
    final title       = titleController.text.trim();
    final description = descController.text.trim();
    final members     = memberControllers
        .map((c) => c.text.trim())
        .where((m) => m.isNotEmpty)
        .toList();

    if (title.isEmpty) { _showError('Enter a group name'); return; }
    if (description.isEmpty) { _showError('Enter a description'); return; }
    if (members.isEmpty) { _showError('Add at least one member'); return; }

    isSubmitting.value = true;
    try {
      bool success;
      if (isEditMode.value) {
        success = await _service.updateGroup(
          groupId:     editingGroupId.value,
          title:       title,
          description: description,
          members:     members,
        );
        if (success) _showSuccess('Group updated');
      } else {
        success = await _service.createGroup(
          title:       title,
          description: description,
          members:     members,
        );
        if (success) _showSuccess('Group created');
      }

      if (success) {
        await loadGroups();
        Get.back();
        _resetGroupForm();
      } else {
        _showError(isEditMode.value
            ? 'Failed to update group'
            : 'Failed to create group');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Delete group ──────────────────────────────────────────────

  Future<void> deleteGroup(String groupId) async {
    try {
      final success = await _service.deleteGroup(groupId);
      if (success) {
        groups.removeWhere((g) => g.id == groupId);
        _showSuccess('Group deleted');
      } else {
        _showError('Failed to delete group');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  // ── Start edit expense ────────────────────────────────────────

  void startEditExpense(GroupTransaction expense, String groupId) {
    isExpenseEditMode.value  = true;
    editingExpenseId.value   = expense.id;
    selectedGroupId.value    = groupId;
    expenseAmountController.text = expense.amount.toString();
    expenseDescController.text   = expense.description;
    selectedDate.value           = expense.date;
  }

  // ── Add or Update expense ─────────────────────────────────────

  Future<void> submitGroupExpense() async {
    final amount      = double.tryParse(
        expenseAmountController.text.trim());
    final description = expenseDescController.text.trim();

    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount'); return;
    }
    if (description.isEmpty) {
      _showError('Enter a description'); return;
    }
    if (selectedGroupId.value.isEmpty) {
      _showError('No group selected'); return;
    }

    isExpenseSubmitting.value = true;
    try {
      bool success;
      if (isExpenseEditMode.value) {
        success = await _service.updateGroupExpense(
          groupId:     selectedGroupId.value,
          expenseId:   editingExpenseId.value,
          description: description,
          amount:      amount,
          date:        selectedDate.value.toIso8601String(),
        );
        if (success) _showSuccess('Expense updated');
      } else {
        success = await _service.addGroupExpense(
          groupId:     selectedGroupId.value,
          description: description,
          amount:      amount,
          date:        selectedDate.value.toIso8601String(),
        );
        if (success) _showSuccess('Expense added');
      }

      if (success) {
        await loadGroups();
        Get.back();
        _resetExpenseForm();
      } else {
        _showError(isExpenseEditMode.value
            ? 'Failed to update expense'
            : 'Failed to add expense');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isExpenseSubmitting.value = false;
    }
  }

  // ── Delete expense ────────────────────────────────────────────

  Future<void> deleteExpense({
    required String groupId,
    required String expenseId,
  }) async {
    try {
      final success = await _service.deleteExpense(
        groupId:   groupId,
        expenseId: expenseId,
      );
      if (success) {
        await loadGroups();
        _showSuccess('Expense deleted');
      } else {
        _showError('Failed to delete expense');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  // ── Mark as paid ──────────────────────────────────────────────

  Future<void> markAsPaid({
    required String groupId,
    required String expenseId,
    required String memberEmail,
  }) async {
    try {
      final success = await _service.markAsPaid(
        groupId:     groupId,
        expenseId:   expenseId,
        memberEmail: memberEmail,
      );
      if (success) {
        await loadGroups();
        _showSuccess('Marked as paid');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  // ── Reset forms ───────────────────────────────────────────────

  void _resetGroupForm() {
    isEditMode.value     = false;
    editingGroupId.value = '';
    titleController.clear();
    descController.clear();
    for (final c in memberControllers) { c.dispose(); }
    memberControllers.assignAll([TextEditingController()]);
  }

  void _resetExpenseForm() {
    isExpenseEditMode.value  = false;
    editingExpenseId.value   = '';
    expenseAmountController.clear();
    expenseDescController.clear();
    selectedDate.value = DateTime.now();
  }

  void resetGroupForm()   => _resetGroupForm();
  void resetExpenseForm() => _resetExpenseForm();

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
    titleController.dispose();
    descController.dispose();
    expenseAmountController.dispose();
    expenseDescController.dispose();
    for (final c in memberControllers) { c.dispose(); }
    super.onClose();
  }
}