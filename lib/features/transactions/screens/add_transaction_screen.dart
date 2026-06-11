// MoneyBuddy
import 'dart:io';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/misc/category_chip.dart';
import '../../../features/receipt_scanner/receipt_scanner_service.dart';
import '../controllers/transaction_controller.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  static const _expenseCategories = [
    'Food', 'Transport', 'Shopping', 'Bills',
    'Health', 'Travel', 'Education', 'Entertainment',
    'Rent', 'EMI', 'Other',
  ];

  static const _incomeCategories = [
    'Salary', 'Freelance', 'Investment',
    'Bonus', 'Rental', 'Income',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.kBalanceGradient,
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(AppRadius.xxl),
                bottomRight: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    // ── Top row ────────────────────────────────
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.resetForm();
                            Get.back();
                          },
                          child: Container(
                            padding: EdgeInsets.all(R.w(context, 8)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: AppRadius.tile,
                            ),
                            child: Icon(
                              CupertinoIcons.xmark,
                              color: Colors.white,
                              size: R.w(context, 20),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Obx(() => Text(
                              controller.isEditMode.value
                                  ? 'Edit Transaction'
                                  : AppStrings.addTransaction,
                              style: AppTextStyles.headingSmall.copyWith(
                                color: Colors.white,
                              ),
                            )),
                        const Spacer(),
                        // ── Camera button ──────────────────────
                        GestureDetector(
                          onTap: () =>
                              _showScanOptions(context, controller),
                          child: Container(
                            padding: EdgeInsets.all(R.w(context, 8)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: AppRadius.tile,
                            ),
                            child: Icon(
                              CupertinoIcons.camera,
                              color: Colors.white,
                              size: R.w(context, 20),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Gap(R.h(context, 20)),

                    // ── Income / Expense toggle ─────────────────
                    Obx(() => Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ToggleTab(
                                label:    'Expense',
                                isActive: controller.isExpense.value,
                                onTap: () =>
                                    controller.isExpense.value = true,
                              ),
                              _ToggleTab(
                                label:    'Income',
                                isActive: !controller.isExpense.value,
                                onTap: () =>
                                    controller.isExpense.value = false,
                              ),
                            ],
                          ),
                        )),

                    Gap(R.h(context, 16)),

                    // ── Amount ─────────────────────────────────
                    Text(
                      'How much?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Gap(R.h(context, 4)),

                    TextField(
                      controller: controller.amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: AppTextStyles.displayLarge,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '₹0',
                        hintStyle: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white38,
                        ),
                        border:  InputBorder.none,
                        filled:  false,
                      ),
                      cursorColor: Colors.white,
                    ),

                    // Calculator result
                    Obx(() =>
                        controller.calculatorResult.value.isNotEmpty
                            ? Text(
                                controller.calculatorResult.value,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              )
                            : const SizedBox.shrink()),

                    Gap(R.h(context, 8)),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom form ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxl,
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Description
                  AppTextField(
                    label:      AppStrings.description,
                    hint:       'What was this for?',
                    controller: controller.descController,
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0),

                  const Gap(20),

                  // Category
                  Text('Category', style: AppTextStyles.inputLabel),
                  const Gap(10),
                  Obx(() {
                    final cats = controller.isExpense.value
                        ? _expenseCategories
                        : _incomeCategories;
                    return Wrap(
                      spacing:    8,
                      runSpacing: 8,
                      children: cats.map((cat) => CategoryChip(
                            category: cat,
                            selected: controller.selectedCategory.value
                                == cat,
                            onTap: () =>
                                controller.selectedCategory.value = cat,
                          )).toList(),
                    );
                  }).animate(delay: 50.ms).fadeIn(duration: 300.ms),

                  const Gap(20),

                  // Date picker
                  Text(AppStrings.date, style: AppTextStyles.inputLabel),
                  const Gap(8),
                  Obx(() => GestureDetector(
                        onTap: () => _pickDate(context, controller),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical:   AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color:        AppColors.kInputFill,
                            borderRadius: AppRadius.input,
                            border: Border.all(color: AppColors.kBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.calendar,
                                color: AppColors.kTextHint,
                                size:  18,
                              ),
                              const Gap(8),
                              Text(
                                _formatDate(
                                    controller.selectedDate.value),
                                style: AppTextStyles.inputValue,
                              ),
                            ],
                          ),
                        ),
                      )).animate(delay: 100.ms).fadeIn(duration: 300.ms),

                  const Gap(28),

                  // Submit button
                  Obx(() => PrimaryButton(
                        text: controller.isEditMode.value
                            ? 'Update Transaction'
                            : 'Add Transaction',
                        onPressed: controller.submitTransaction,
                        isLoading: controller.isSubmitting.value,
                      ))
                      .animate(delay: 150.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scan Options Sheet ────────────────────────────────────────

  void _showScanOptions(
      BuildContext context, TransactionController controller) {
    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color:        AppColors.kCard,
          borderRadius: AppRadius.modal,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: const BoxDecoration(
                    color:        AppColors.kBorder,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color:        AppColors.kPrimaryTint,
                        borderRadius: AppRadius.tile,
                      ),
                      child: const Icon(
                        CupertinoIcons.camera,
                        color: AppColors.kPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scan Receipt',
                            style: AppTextStyles.headingSmall),
                        Text(
                          'Auto-fill amount from receipt',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.kDivider),

              // Camera option
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical:   4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color:        AppColors.kPrimaryTint,
                      borderRadius: AppRadius.tile,
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      color: AppColors.kPrimary,
                      size: 18,
                    ),
                  ),
                  title: Text('Take Photo',
                      style: AppTextStyles.labelLarge),
                  subtitle: Text('Use camera to scan receipt',
                      style: AppTextStyles.bodySmall),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    color: AppColors.kTextHint,
                    size: 16,
                  ),
                  onTap: () {
                    Get.back();
                    _scanFromCamera(context, controller);
                  },
                ),
              ),

              const Divider(
                  height: 1,
                  indent: AppSpacing.lg + 44,
                  color: AppColors.kDivider),

              // Gallery option
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical:   4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.kInfo.withValues(alpha: 0.1),
                      borderRadius: AppRadius.tile,
                    ),
                    child: Icon(
                      CupertinoIcons.photo,
                      color: AppColors.kInfo,
                      size: 18,
                    ),
                  ),
                  title: Text('Choose from Gallery',
                      style: AppTextStyles.labelLarge),
                  subtitle: Text('Pick existing receipt photo',
                      style: AppTextStyles.bodySmall),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    color: AppColors.kTextHint,
                    size: 16,
                  ),
                  onTap: () {
                    Get.back();
                    _scanFromGallery(context, controller);
                  },
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Scanner logic ─────────────────────────────────────────────

  Future<void> _scanFromCamera(
      BuildContext context, TransactionController controller) async {
    final file = await ReceiptScannerService.pickFromCamera();
    if (file == null) return;
    if (context.mounted) _processFile(context, controller, file);
  }

  Future<void> _scanFromGallery(
      BuildContext context, TransactionController controller) async {
    final file = await ReceiptScannerService.pickFromGallery();
    if (file == null) return;
    if (context.mounted) _processFile(context, controller, file);
  }

  Future<void> _processFile(
    BuildContext context,
    TransactionController controller,
    File file,
  ) async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.kPrimary),
      ),
      barrierDismissible: false,
    );

    final result = await ReceiptScannerService.scanReceipt(file);
    Get.back();

    if (result == null) {
      Get.snackbar(
        'Scan Failed',
        'Could not read receipt. Try a clearer photo.',
        backgroundColor: AppColors.kError,
        colorText:       Colors.white,
        snackPosition:   SnackPosition.BOTTOM,
        margin:          const EdgeInsets.all(16),
        borderRadius:    12,
      );
      return;
    }

    if (result.amount != null) {
      controller.amountController.text =
          result.amount!.toStringAsFixed(0);
    }
    if (result.description.isNotEmpty) {
      controller.descController.text = result.description;
    }

    Get.snackbar(
      'Receipt Scanned',
      result.amount != null
          ? 'Found ₹${result.amount!.toStringAsFixed(0)}'
            ' — ${result.description}'
          : 'Description filled. Enter amount manually.',
      backgroundColor: AppColors.kSuccess,
      colorText:       Colors.white,
      snackPosition:   SnackPosition.BOTTOM,
      margin:          const EdgeInsets.all(16),
      borderRadius:    12,
      duration:        const Duration(seconds: 3),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  Future<void> _pickDate(
    BuildContext context,
    TransactionController controller,
  ) async {
    final date = await showBoardDateTimePicker(
      context:     context,
      pickerType:  DateTimePickerType.datetime,
      initialDate: controller.selectedDate.value,
      options: const BoardDateTimeOptions(
        languages: BoardPickerLanguages(
          today:    'Today',
          tomorrow: 'Tomorrow',
          now:      'Now',
        ),
      ),
    );
    if (date != null) controller.selectedDate.value = date;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day   == now.day &&
        date.month == now.month &&
        date.year  == now.year) {
      return 'Today, ${_timeString(date)}';
    }
    return '${date.day}/${date.month}/${date.year},'
        ' ${_timeString(date)}';
  }

  String _timeString(DateTime date) {
    final hour   = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

// ── Toggle Tab ────────────────────────────────────────────────────

class _ToggleTab extends StatelessWidget {
  final String       label;
  final bool         isActive;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color:        isActive ? Colors.white : Colors.transparent,
          borderRadius: AppRadius.pill,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: isActive ? AppColors.kPrimary : Colors.white70,
          ),
        ),
      ),
    );
  }
}