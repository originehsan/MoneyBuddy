// MoneyBuddy
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/secure_storage.dart';
import '../../auth/services/auth_service.dart';
import '../../budget/budget_service.dart';
import '../../transactions/services/transaction_service.dart';
import '../services/profile_service.dart';

/// Manages profile screen state — name, balance, password,
/// budget, export, logout, delete account.
class ProfileController extends GetxController {
  final _profileService = ProfileService();
  final _authService    = AuthService();

  final userName  = ''.obs;
  final userEmail = ''.obs;
  final isLoading = false.obs;

  // ── Form controllers ──────────────────────────────────────────
  final amountController          = TextEditingController();
  final budgetController          = TextEditingController();
  final nameController            = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController     = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final deletePasswordController  = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    userName.value  = user?.displayName ??
        await SecureStorage.getUserName() ?? 'User';
    userEmail.value = user?.email ??
        await SecureStorage.getUserEmail() ?? '';
  }

  String get initials {
    final name = userName.value.trim();
    if (name.isEmpty) return 'MB';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  // ── Update balance ────────────────────────────────────────────

  Future<void> updateBalance() async {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount'); return;
    }
    isLoading.value = true;
    try {
      final success = await _profileService.updateBalance(amount);
      if (success) {
        _showSuccess('Balance updated');
        amountController.clear();
        Get.back();
      } else {
        _showError('Failed to update balance');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Update name ───────────────────────────────────────────────

  Future<void> updateName() async {
    final name = nameController.text.trim();
    if (name.isEmpty) { _showError('Enter your name'); return; }
    if (name.length < 2) { _showError('Name too short'); return; }

    isLoading.value = true;
    try {
      final success = await _profileService.updateName(name);
      if (success) {
        userName.value = name;
        _showSuccess('Name updated');
        nameController.clear();
        Get.back();
      } else {
        _showError('Failed to update name');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Change password ───────────────────────────────────────────

  Future<void> changePassword() async {
    final current = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (current.isEmpty) { _showError('Enter current password'); return; }
    if (newPass.length < 8) {
      _showError('New password must be at least 8 characters'); return;
    }
    if (newPass != confirm) { _showError('Passwords do not match'); return; }
    if (current == newPass) {
      _showError('New password must be different'); return;
    }

    isLoading.value = true;
    try {
      final error = await _profileService.changePassword(
        currentPassword: current,
        newPassword:     newPass,
      );
      if (error == null) {
        _showSuccess('Password changed successfully');
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        Get.back();
      } else {
        _showError(error);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Budget ────────────────────────────────────────────────────

  Future<void> saveBudget() async {
    final amount = double.tryParse(budgetController.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Enter a valid budget amount'); return;
    }
    await BudgetService.saveBudget(amount);
    _showSuccess('Budget saved');
    budgetController.clear();
    Get.back();
  }

  Future<void> clearBudget() async {
    await BudgetService.clearBudget();
    _showSuccess('Budget cleared');
    Get.back();
  }

  // ── Export CSV ────────────────────────────────────────────────

  Future<void> exportCsv() async {
    isLoading.value = true;
    try {
      final transactions = await TransactionService().getTransactions();
      if (transactions.isEmpty) {
        _showError('No transactions to export'); return;
      }
      // Build CSV string
      final buffer = StringBuffer();
      buffer.writeln('Date,Type,Category,Description,Amount');
      for (final tx in transactions) {
        buffer.writeln(
          '${tx.date.toIso8601String()},'
          '${tx.type},'
          '${tx.category ?? ""},'
          '"${tx.description}",'
          '${tx.amount}',
        );
      }
      _showSuccess('Export ready — ${transactions.length} transactions');
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Delete account ────────────────────────────────────────────

  Future<void> deleteAccount() async {
    final password = deletePasswordController.text.trim();
    if (password.isEmpty) { _showError('Enter your password'); return; }

    isLoading.value = true;
    try {
      final error = await _profileService.deleteAccount(password);
      if (error == null) {
        deletePasswordController.clear();
        Get.offAllNamed(AppRoutes.loginRegister);
      } else {
        _showError(error);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────

  Future<void> logout() async => _authService.logout();

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
    budgetController.dispose();
    nameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    deletePasswordController.dispose();
    super.onClose();
  }
}