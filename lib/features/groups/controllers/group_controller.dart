// MoneyBuddy
 import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneybuddy/core/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

class GroupController extends GetxController {
  final _service = GroupService();

  // ── List state ────────────────────────────────────────────────
  final isLoading    = true.obs;
  final groups       = <GroupModel>[].obs;
  final errorMessage = ''.obs;

  // ── Group form ────────────────────────────────────────────────
  final titleController = TextEditingController();
  final descController  = TextEditingController();
  final isSubmitting    = false.obs;
  final isEditMode      = false.obs;
  final editingGroupId  = ''.obs;

  final memberNameControllers = <TextEditingController>[
    TextEditingController(),
  ].obs;

  // ── Expense form ──────────────────────────────────────────────
  final expenseAmountController = TextEditingController();
  final expenseDescController   = TextEditingController();
  final selectedDate            = DateTime.now().obs;
  final selectedGroupId         = ''.obs;
  final isExpenseSubmitting     = false.obs;
  final isExpenseEditMode       = false.obs;
  final editingExpenseId        = ''.obs;

  final selectedPaidBy    = Rxn<GroupMember>();
  final selectedSplitWith = <GroupMember>[].obs;

  // ── Current user info ─────────────────────────────────────────
  String get _currentEmail =>
      FirebaseAuth.instance.currentUser?.email ?? '';
  String get _currentName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'You';

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
      groups.value = await _service.getGroups();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Member management ─────────────────────────────────────────

  void addMemberField() {
    if (memberNameControllers.length < 10) {
      memberNameControllers.add(TextEditingController());
    }
  }

  void removeMemberField(int index) {
    if (memberNameControllers.length > 1) {
      memberNameControllers[index].dispose();
      memberNameControllers.removeAt(index);
    }
  }

  // ── Create / Update group ─────────────────────────────────────

  Future<void> submitGroup() async {
    final title       = titleController.text.trim();
    final description = descController.text.trim();
    final names       = memberNameControllers
        .map((c) => c.text.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    if (title.isEmpty) {
      _showError('Enter a group name'); return;
    }
    if (description.isEmpty) {
      _showError('Enter a description'); return;
    }
    if (names.isEmpty) {
      _showError('Add at least one member'); return;
    }

    final members = names
        .map((n) => GroupMember(name: n, email: ''))
        .toList();

    isSubmitting.value = true;
    try {
      bool success;
      final wasEdit = isEditMode.value;

      if (wasEdit) {
        final currentGroup = groups.firstWhere(
            (g) => g.id == editingGroupId.value,
            orElse: () => groups.first);
        final creator = currentGroup.members.isNotEmpty
            ? currentGroup.members.first
            : GroupMember(name: _currentName, email: _currentEmail);

        success = await _service.updateGroup(
          groupId:     editingGroupId.value,
          title:       title,
          description: description,
          members:     [creator, ...members],
        );
        if (success) _showSuccess('Group updated');
      } else {
        success = await _service.createGroup(
          title:       title,
          description: description,
          members:     members,
          creatorName: _currentName,
        );
        if (success) _showSuccess('Group created');
      }

      if (success) {
        await loadGroups();
        _resetGroupForm();

        if (!wasEdit) {
          Get.until(
              (route) => route.settings.name == AppRoutes.main);
          if (groups.isNotEmpty) {
            final newGroup = groups.first;
            Get.toNamed(
              AppRoutes.groupDetail,
              arguments: {
                'groupId':    newGroup.id,
                'groupTitle': newGroup.title,
              },
            );
          }
        } else {
          Get.back();
        }
      } else {
        _showError(wasEdit
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

  // ── Start edit group ──────────────────────────────────────────

  void startEditGroup(GroupModel group) {
    isEditMode.value     = true;
    editingGroupId.value = group.id;
    titleController.text = group.title;
    descController.text  = group.description;

    for (final c in memberNameControllers) { c.dispose(); }
    final others = group.members.skip(1).toList();
    if (others.isEmpty) {
      memberNameControllers.assignAll([TextEditingController()]);
    } else {
      memberNameControllers.assignAll(
        others.map((m) =>
            TextEditingController(text: m.displayName)).toList(),
      );
    }
  }

  // ── Expense defaults ──────────────────────────────────────────

  void initExpenseDefaults(GroupModel group) {
    final currentMember = group.members.firstWhereOrNull(
          (m) => m.email == _currentEmail) ??
        (group.members.isNotEmpty
            ? group.members.first
            : GroupMember(
                name: _currentName, email: _currentEmail));

    selectedPaidBy.value    = currentMember;
    selectedSplitWith.value = List.from(group.members);
  }

  // ── Submit expense ────────────────────────────────────────────

  Future<void> submitGroupExpense() async {
    final amount = double.tryParse(
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
    if (selectedPaidBy.value == null) {
      _showError('Select who paid'); return;
    }
    if (selectedSplitWith.isEmpty) {
      _showError('Select at least one person to split with');
      return;
    }

    isExpenseSubmitting.value = true;
    try {
      bool success;
      final wasEdit = isExpenseEditMode.value;

      if (wasEdit) {
        success = await _service.updateGroupExpense(
          groupId:      selectedGroupId.value,
          expenseId:    editingExpenseId.value,
          description:  description,
          amount:       amount,
          paidBy:       selectedPaidBy.value!.email,
          paidByName:   selectedPaidBy.value!.displayName,
          splitBetween: selectedSplitWith,
          date:         selectedDate.value.toIso8601String(),
        );
        if (success) _showSuccess('Expense updated');
      } else {
        success = await _service.addGroupExpense(
          groupId:      selectedGroupId.value,
          description:  description,
          amount:       amount,
          paidBy:       selectedPaidBy.value!.email,
          paidByName:   selectedPaidBy.value!.displayName,
          splitBetween: selectedSplitWith,
          date:         selectedDate.value.toIso8601String(),
        );
        if (success) _showSuccess('Expense added');
      }

      if (success) {
        loadGroups();
        _resetExpenseForm();
        Get.back();
      } else {
        _showError(wasEdit
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
          groupId: groupId, expenseId: expenseId);
      if (success) {
        loadGroups();
        _showSuccess('Expense deleted');
      } else {
        _showError('Failed to delete expense');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  // ── Start edit expense ────────────────────────────────────────

  void startEditExpense(GroupExpense expense, GroupModel group) {
    isExpenseEditMode.value      = true;
    editingExpenseId.value       = expense.id;
    selectedGroupId.value        = group.id;
    expenseAmountController.text = expense.amount.toStringAsFixed(0);
    expenseDescController.text   = expense.description;
    selectedDate.value           = expense.date;

    selectedPaidBy.value = group.members.firstWhere(
      (m) => m.email == expense.paidBy,
      orElse: () => group.members.first,
    );

    selectedSplitWith.value = group.members
        .where((m) => expense.splitBetween.contains(m.email))
        .toList();
    if (selectedSplitWith.isEmpty) {
      selectedSplitWith.value = List.from(group.members);
    }
  }

  // ── Mark settlement paid ──────────────────────────────────────

  Future<void> markSettlementPaid({
    required String groupId,
    required String expenseId,
    required String memberEmail,
  }) async {
    final groupIndex =
        groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1) {
      final expenseIndex = groups[groupIndex]
          .expenses
          .indexWhere((e) => e.id == expenseId);
      if (expenseIndex != -1) {
        final updatedSettlements = groups[groupIndex]
            .expenses[expenseIndex]
            .settlements
            .map((s) => s.email == memberEmail
                ? Settlement(
                    name:   s.name,
                    email:  s.email,
                    amount: s.amount,
                    paid:   true,
                  )
                : s)
            .toList();

        final updatedExpense = GroupExpense(
          id:           expenseId,
          description:  groups[groupIndex]
              .expenses[expenseIndex].description,
          amount:       groups[groupIndex]
              .expenses[expenseIndex].amount,
          date:         groups[groupIndex]
              .expenses[expenseIndex].date,
          paidBy:       groups[groupIndex]
              .expenses[expenseIndex].paidBy,
          paidByName:   groups[groupIndex]
              .expenses[expenseIndex].paidByName,
          splitBetween: groups[groupIndex]
              .expenses[expenseIndex].splitBetween,
          perPersonShare: groups[groupIndex]
              .expenses[expenseIndex].perPersonShare,
          settlements: updatedSettlements,
        );

        final updatedExpenses = List<GroupExpense>.from(
            groups[groupIndex].expenses);
        updatedExpenses[expenseIndex] = updatedExpense;

        final updatedGroup = GroupModel(
          id:           groups[groupIndex].id,
          title:        groups[groupIndex].title,
          description:  groups[groupIndex].description,
          createdBy:    groups[groupIndex].createdBy,
          creatorEmail: groups[groupIndex].creatorEmail,
          members:      groups[groupIndex].members,
          expenses:     updatedExpenses,
        );

        groups[groupIndex] = updatedGroup;
        groups.refresh();
      }
    }

    try {
      await _service.markSettlementPaid(
        groupId:     groupId,
        expenseId:   expenseId,
        memberEmail: memberEmail,
      );
      _showSuccess('Marked as paid');
    } catch (e) {
      _showError('Failed to update');
      loadGroups();
    }
  }

  // ── Balances computation ──────────────────────────────────────

  List<DebtSummary> computeBalances(GroupModel group) {
    final net = <String, double>{};

    for (final member in group.members) {
      net[member.displayName] = 0.0;
    }

    for (final expense in group.expenses) {
      final paidByName = expense.paidByName.isNotEmpty
          ? expense.paidByName
          : expense.paidBy;

      for (final s in expense.settlements) {
        if (!s.paid) {
          final name = s.name.isNotEmpty ? s.name : s.email;
          net[paidByName] = (net[paidByName] ?? 0) + s.amount;
          net[name]       = (net[name] ?? 0) - s.amount;
        }
      }
    }

    final debts     = <DebtSummary>[];
    final creditors = net.entries
        .where((e) => e.value > 0.5)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final debtors = net.entries
        .where((e) => e.value < -0.5)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    var ci = 0;
    var di = 0;
    final creditorAmounts =
        creditors.map((e) => e.value).toList();
    final debtorAmounts =
        debtors.map((e) => e.value.abs()).toList();

    while (ci < creditors.length && di < debtors.length) {
      final settle = creditorAmounts[ci] < debtorAmounts[di]
          ? creditorAmounts[ci]
          : debtorAmounts[di];

      debts.add(DebtSummary(
        from:   debtors[di].key,
        to:     creditors[ci].key,
        amount: settle,
      ));

      creditorAmounts[ci] -= settle;
      debtorAmounts[di]   -= settle;

      if (creditorAmounts[ci] < 0.5) ci++;
      if (debtorAmounts[di]   < 0.5) di++;
    }

    return debts;
  }

  // ── Reset forms ───────────────────────────────────────────────

  void _resetGroupForm() {
    isEditMode.value     = false;
    editingGroupId.value = '';
    titleController.clear();
    descController.clear();
    for (final c in memberNameControllers) { c.dispose(); }
    memberNameControllers.assignAll([TextEditingController()]);
  }

  void _resetExpenseForm() {
    isExpenseEditMode.value      = false;
    editingExpenseId.value       = '';
    expenseAmountController.clear();
    expenseDescController.clear();
    selectedDate.value           = DateTime.now();
    selectedPaidBy.value         = null;
    selectedSplitWith.value      = [];
  }

  void resetGroupForm()   => _resetGroupForm();
  void resetExpenseForm() => _resetExpenseForm();

  // ── Snackbars ─────────────────────────────────────────────────

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
    descController.dispose();
    expenseAmountController.dispose();
    expenseDescController.dispose();
    for (final c in memberNameControllers) { c.dispose(); }
    super.onClose();
  }
}

class DebtSummary {
  final String from;
  final String to;
  final double amount;

  const DebtSummary({
    required this.from,
    required this.to,
    required this.amount,
  });
}