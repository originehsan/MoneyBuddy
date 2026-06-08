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
import '../controllers/group_controller.dart';

class AddGroupTransactionScreen extends StatelessWidget {
  const AddGroupTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupController>();
    final groupTitle = Get.arguments?['groupTitle'] as String? ?? 'Group';
    final groupId = Get.arguments?['groupId'] as String? ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (groupId.isNotEmpty && !controller.isExpenseEditMode.value) {
        controller.selectedGroupId.value = groupId;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.kBalanceGradient,
              borderRadius: AppRadius.topBar,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  R.h(context, AppSpacing.xxl),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.resetExpenseForm();
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
                              controller.isExpenseEditMode.value
                                  ? 'Edit Expense'
                                  : AppStrings.addExpense,
                              style: AppTextStyles.headingSmall.copyWith(
                                color: Colors.white,
                              ),
                            )),
                        const Spacer(),
                        SizedBox(width: R.w(context, 36)),
                      ],
                    ),

                    Gap(R.h(context, 16)),

                    Text(
                      groupTitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),

                    Gap(R.h(context, 12)),

                    // Amount field
                    TextField(
                      controller: controller.expenseAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '₹0',
                        hintStyle: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white38,
                        ),
                        border: InputBorder.none,
                        filled: false,
                      ),
                      cursorColor: Colors.white,
                    ),

                    Gap(R.h(context, 8)),
                  ],
                ),
              ),
            ),
          ),

          // ── Form ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                R.h(context, 24),
                AppSpacing.xxl,
                R.h(context, 100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: AppStrings.description,
                    hint: 'What was this expense for?',
                    controller: controller.expenseDescController,
                  ).animate().fadeIn(duration: 300.ms),
                  Gap(R.h(context, 20)),
                  Text(AppStrings.date, style: AppTextStyles.inputLabel),
                  Gap(R.h(context, 8)),
                  Obx(() => GestureDetector(
                        onTap: () => _pickDate(context, controller),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: R.h(context, AppSpacing.md),
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
                                size: R.w(context, 18),
                              ),
                              Gap(R.w(context, 8)),
                              Text(
                                _formatDate(controller.selectedDate.value),
                                style: AppTextStyles.inputValue,
                              ),
                            ],
                          ),
                        ),
                      )).animate(delay: 50.ms).fadeIn(duration: 300.ms),
                  Gap(R.h(context, 28)),
                  Obx(() => PrimaryButton(
                        text: controller.isExpenseEditMode.value
                            ? 'Update Expense'
                            : AppStrings.addExpense,
                        onPressed: controller.submitGroupExpense,
                        isLoading: controller.isExpenseSubmitting.value,
                      )).animate(delay: 100.ms).fadeIn(duration: 300.ms),
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
    GroupController controller,
  ) async {
    final date = await showBoardDateTimePicker(
      context: context,
      pickerType: DateTimePickerType.datetime,
      initialDate: controller.selectedDate.value,
      options: const BoardDateTimeOptions(
        languages: BoardPickerLanguages(
          today: 'Today',
          tomorrow: 'Tomorrow',
          now: 'Now',
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
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
