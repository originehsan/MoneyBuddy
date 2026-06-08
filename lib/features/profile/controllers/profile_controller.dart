// MoneyBuddy
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../features/auth/services/auth_service.dart';
import '../services/profile_service.dart';
import '../../budget/budget_service.dart';
import '../../export/csv_export_service.dart';
import '../../transactions/services/transaction_service.dart';

/// Manages profile screen state.
class ProfileController extends GetxController {
  final _profileService = ProfileService();
  final _authService    = AuthService();

  final userName         = ''.obs;
  final userEmail        = ''.obs;
  final isLoading        = false.obs;
  final amountController = TextEditingController();
  final budgetController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    // Load from Firebase Auth first — most accurate
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

  // ── Balance ───────────────────────────────────────────────────

  Future<void> updateBalance() async {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount'); return;
    }

    isLoading.value = true;
    try {
      final success = await _profileService.updateBalance(amount);
      if (success) {
        _showSuccess('Balance updated successfully');
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
  }

  // ── Export ────────────────────────────────────────────────────

  Future<void> exportCsv() async {
    try {
      final transactions = await TransactionService().getTransactions();
      await CsvExportService.export(transactions);
    } catch (e) {
      _showError(e.toString());
    }
  }

  // ── Logout ────────────────────────────────────────────────────

  void showLogoutDialog() {
    Get.bottomSheet(
      _LogoutSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  Future<void> logout() async => _authService.logout();

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
    super.onClose();
  }
}

class _LogoutSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Logout?', style: Get.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to logout?',
            style: Get.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.kPrimary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: Get.textTheme.labelLarge?.copyWith(
                      color: AppColors.kPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kError,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Logout',
                    style: Get.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}