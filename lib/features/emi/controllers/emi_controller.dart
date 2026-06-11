// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../models/emi_model.dart';
import '../services/emi_service.dart';

class EmiController extends GetxController {
  final _service = EmiService();

  final isLoading    = true.obs;
  final emis         = <EmiModel>[].obs;
  final errorMessage = ''.obs;

  // Form state
  final nameController         = TextEditingController();
  final totalAmountController  = TextEditingController();
  final emiAmountController    = TextEditingController();
  final totalMonthsController  = TextEditingController();
  final interestController     = TextEditingController();
  final selectedIcon           = 'creditcard'.obs;
  final selectedStartDate      = DateTime.now().obs;
  final isSubmitting           = false.obs;
  final isEditMode             = false.obs;
  final editingEmiId           = ''.obs;

  static const icons = [
    'creditcard', 'house', 'car', 'briefcase',
    'phone', 'laptop', 'heart', 'star',
  ];

  @override
  void onInit() {
    super.onInit();
    loadEmis();
  }

  Future<void> loadEmis() async {
    isLoading.value    = true;
    errorMessage.value = '';
    try {
      emis.value = await _service.getEmis();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  double get totalMonthlyEmi =>
      emis.where((e) => !e.isCompleted)
          .fold(0.0, (acc, e) => acc + e.emiAmount);

  Future<void> submitEmi() async {
    final name        = nameController.text.trim();
    final totalAmount = double.tryParse(
        totalAmountController.text.trim());
    final emiAmount   = double.tryParse(
        emiAmountController.text.trim());
    final months      = int.tryParse(
        totalMonthsController.text.trim());
    final interest    = double.tryParse(
        interestController.text.trim());

    if (name.isEmpty) {
      _showError('Enter EMI name'); return;
    }
    if (totalAmount == null || totalAmount <= 0) {
      _showError('Enter total loan amount'); return;
    }
    if (emiAmount == null || emiAmount <= 0) {
      _showError('Enter monthly EMI amount'); return;
    }
    if (months == null || months <= 0) {
      _showError('Enter loan tenure in months'); return;
    }

    isSubmitting.value = true;
    try {
      bool success;
      if (isEditMode.value) {
        success = await _service.updateEmi(
          id:           editingEmiId.value,
          name:         name,
          icon:         selectedIcon.value,
          totalAmount:  totalAmount,
          emiAmount:    emiAmount,
          totalMonths:  months,
          startDate:    selectedStartDate.value,
          interestRate: interest,
        );
        if (success) _showSuccess('EMI updated');
      } else {
        success = await _service.createEmi(
          name:         name,
          icon:         selectedIcon.value,
          totalAmount:  totalAmount,
          emiAmount:    emiAmount,
          totalMonths:  months,
          startDate:    selectedStartDate.value,
          interestRate: interest,
        );
        if (success) _showSuccess('EMI added');
      }

      if (success) {
        await loadEmis();
        Get.back();
        _resetForm();
      } else {
        _showError('Failed to save EMI');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> markMonthPaid(EmiModel emi) async {
    if (emi.isCompleted) return;
    try {
      final success = await _service.markMonthPaid(
          emi.id, emi.paidMonths);
      if (success) {
        await loadEmis();
        _showSuccess('Month marked as paid');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> deleteEmi(String id) async {
    try {
      final success = await _service.deleteEmi(id);
      if (success) {
        emis.removeWhere((e) => e.id == id);
        _showSuccess('EMI deleted');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void startEdit(EmiModel emi) {
    isEditMode.value              = true;
    editingEmiId.value            = emi.id;
    nameController.text           = emi.name;
    totalAmountController.text    = emi.totalAmount.toStringAsFixed(0);
    emiAmountController.text      = emi.emiAmount.toStringAsFixed(0);
    totalMonthsController.text    = emi.totalMonths.toString();
    interestController.text       =
        emi.interestRate?.toStringAsFixed(1) ?? '';
    selectedIcon.value            = emi.icon;
    selectedStartDate.value       = emi.startDate;
  }

  void _resetForm() {
    isEditMode.value           = false;
    editingEmiId.value         = '';
    nameController.clear();
    totalAmountController.clear();
    emiAmountController.clear();
    totalMonthsController.clear();
    interestController.clear();
    selectedIcon.value         = 'creditcard';
    selectedStartDate.value    = DateTime.now();
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
    nameController.dispose();
    totalAmountController.dispose();
    emiAmountController.dispose();
    totalMonthsController.dispose();
    interestController.dispose();
    super.onClose();
  }
}