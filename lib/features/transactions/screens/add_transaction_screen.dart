// MoneyBuddy
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
                        const SizedBox(width: 36),
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

                    // ── Amount + Mic row ───────────────────────
                    Text(
                      'How much?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Gap(R.h(context, 4)),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.amountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            style: AppTextStyles.displayLarge,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '₹0',
                              hintStyle:
                                  AppTextStyles.displayLarge.copyWith(
                                color: Colors.white38,
                              ),
                              border: InputBorder.none,
                              filled: false,
                            ),
                            cursorColor: Colors.white,
                          ),
                        ),

                        // ── Mic button ─────────────────────────
                        Obx(() => GestureDetector(
                              onTap: controller.toggleVoiceInput,
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                padding: EdgeInsets.all(R.w(context, 10)),
                                decoration: BoxDecoration(
                                  color: controller.isListening.value
                                      ? Colors.red.withValues(alpha: 0.8)
                                      : Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  controller.isListening.value
                                      ? CupertinoIcons.stop_fill
                                      : CupertinoIcons.mic,
                                  color: Colors.white,
                                  size: R.w(context, 20),
                                ),
                              ),
                            )),
                      ],
                    ),

                    // Voice listening indicator
                    Obx(() {
                      if (!controller.isListening.value &&
                          controller.voiceText.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          if (controller.isListening.value)
                            Text(
                              'Listening...',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          if (controller.voiceText.value.isNotEmpty)
                            Text(
                              '"${controller.voiceText.value}"',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white60,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      );
                    }),

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
                      spacing: 8,
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
                            color: AppColors.kInputFill,
                            borderRadius: AppRadius.input,
                            border: Border.all(color: AppColors.kBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.calendar,
                                color: AppColors.kTextHint,
                                size: 18,
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

  Future<void> _pickDate(
    BuildContext context,
    TransactionController controller,
  ) async {
    final date = await showBoardDateTimePicker(
      context: context,
      pickerType: DateTimePickerType.datetime,
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
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today, ${_timeString(date)}';
    }
    return '${date.day}/${date.month}/${date.year}, ${_timeString(date)}';
  }

  String _timeString(DateTime date) {
    final hour   = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
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
          color: isActive ? Colors.white : Colors.transparent,
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