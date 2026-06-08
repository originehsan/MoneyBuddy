// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

/// Manages group list, create group form, and add expense form state.
class GroupController extends GetxController {
  final _service = GroupService();

  final isLoading    = true.obs;
  final groups       = <GroupModel>[].obs;
  final errorMessage = ''.obs;

  final titleController = TextEditingController();
  final descController  = TextEditingController();
  final isSubmitting    = false.obs;

  final memberControllers = <TextEditingController>[
    TextEditingController(),
  ].obs;

  final expenseAmountController = TextEditingController();
  final expenseDescController   = TextEditingController();
  final selectedDate            = DateTime.now().obs;
  final selectedGroupId         = ''.obs;
  final isExpenseSubmitting     = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    isLoading.value    = true;
    errorMessage.value = '';
    try {
      final list = await _service.getGroups();
      groups.value = list;
      if (list.isNotEmpty) {
        selectedGroupId.value = list.first.id;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void addMember() {
    if (memberControllers.length < 4) {
      memberControllers.add(TextEditingController());
    }
  }

  void removeMember(int index) {
    if (memberControllers.length > 1) {
      memberControllers[index].dispose();
      memberControllers.removeAt(index);
    }
  }

  Future<void> createGroup() async {
    final title       = titleController.text.trim();
    final description = descController.text.trim();
    final members     = memberControllers
        .map((c) => c.text.trim())
        .where((m) => m.isNotEmpty)
        .toList();

    if (title.isEmpty || description.isEmpty || members.isEmpty) {
      _showError('Please fill all fields'); return;
    }

    isSubmitting.value = true;
    try {
      final success = await _service.createGroup(
        title:       title,
        description: description,
        members:     members,
      );

      if (success) {
        _showSuccess('Group created successfully');
        await loadGroups();
        Get.back();
        _resetCreateForm();
      } else {
        _showError('Failed to create group');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetCreateForm() {
    titleController.clear();
    descController.clear();
    for (final c in memberControllers) { c.dispose(); }
    memberControllers.assignAll([TextEditingController()]);
  }

  Future<void> addGroupExpense() async {
    final amount      = double.tryParse(expenseAmountController.text.trim());
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
      final success = await _service.addGroupExpense(
        groupId:     selectedGroupId.value,
        description: description,
        amount:      amount,
        date:        selectedDate.value.toIso8601String(),
      );

      if (success) {
        _showSuccess('Expense added');
        await loadGroups();
        Get.back();
        _resetExpenseForm();
      } else {
        _showError('Failed to add expense');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isExpenseSubmitting.value = false;
    }
  }

  Future<void> markAsPaid({
    required String groupId,
    required String expenseId,
    required String memberEmail,
  }) async {
    try {
      await _service.markAsPaid(
        groupId:     groupId,
        expenseId:   expenseId,
        memberEmail: memberEmail,
      );
      _showSuccess('Marked as paid');
      await loadGroups();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _resetExpenseForm() {
    expenseAmountController.clear();
    expenseDescController.clear();
    selectedDate.value = DateTime.now();
  }

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