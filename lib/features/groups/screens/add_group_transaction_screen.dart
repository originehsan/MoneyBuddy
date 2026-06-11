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
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/group_controller.dart';
import '../models/group_model.dart';

class AddGroupTransactionScreen extends StatelessWidget {
  const AddGroupTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupController>();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final groupTitle = args['groupTitle'] as String? ?? 'Group';
    final groupId = args['groupId'] as String? ?? '';
    final group = controller.groups.firstWhereOrNull((g) => g.id == groupId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (groupId.isNotEmpty && !controller.isExpenseEditMode.value) {
        controller.selectedGroupId.value = groupId;
        if (controller.selectedPaidBy.value == null) {
          final g = controller.groups.firstWhereOrNull((g) => g.id == groupId);
          if (g != null) controller.initExpenseDefaults(g);
        }
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
                    // Back + title
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
                              style: AppTextStyles.headingSmall
                                  .copyWith(color: Colors.white),
                            )),
                        const Spacer(),
                        SizedBox(width: R.w(context, 36)),
                      ],
                    ),

                    Gap(R.h(context, 8)),

                    Text(
                      groupTitle,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white70),
                    ),

                    Gap(R.h(context, 12)),

                    // ── Amount + Mic ──────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.expenseAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: AppTextStyles.displayLarge,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '₹0',
                              hintStyle: AppTextStyles.displayLarge
                                  .copyWith(color: Colors.white38),
                              border: InputBorder.none,
                              filled: false,
                            ),
                            cursorColor: Colors.white,
                          ),
                        ),

                        // ── Mic button ────────────────────────
                        Padding(
                          padding: EdgeInsets.only(right: R.w(context, 8)),
                          child: Obx(() => GestureDetector(
                                onTap: controller.toggleVoiceInput,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: R.w(context, 44),
                                  height: R.w(context, 44),
                                  decoration: BoxDecoration(
                                    color: controller.isListening.value
                                        ? Colors.red.withValues(alpha: 0.85)
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
                        ),
                      ],
                    ),

                    // Voice status
                    Obx(() {
                      if (!controller.isListening.value &&
                          controller.voiceText.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.only(bottom: R.h(context, 4)),
                        child: Text(
                          controller.isListening.value
                              ? 'Listening...'
                              : '"${controller.voiceText.value}"',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),

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
                R.h(context, 20),
                AppSpacing.xxl,
                R.h(context, 100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  AppTextField(
                    label: AppStrings.description,
                    hint: 'What was this expense for?',
                    controller: controller.expenseDescController,
                  ).animate().fadeIn(duration: 300.ms),

                  Gap(R.h(context, 20)),

                  // ── Who paid? ────────────────────────────────
                  Text('Who paid?', style: AppTextStyles.inputLabel),
                  Gap(R.h(context, 8)),
                  Obx(() => GestureDetector(
                        onTap: () {
                          final g = controller.groups
                              .firstWhereOrNull((g) => g.id == groupId);
                          if (g != null) {
                            _showWhoPaidSheet(context, controller, g);
                          }
                        },
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
                                CupertinoIcons.person,
                                color: AppColors.kTextHint,
                                size: R.w(context, 18),
                              ),
                              Gap(R.w(context, 8)),
                              Expanded(
                                child: Text(
                                  controller
                                          .selectedPaidBy.value?.displayName ??
                                      'Select who paid',
                                  style: controller.selectedPaidBy.value != null
                                      ? AppTextStyles.inputValue
                                      : AppTextStyles.inputHint,
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_down,
                                color: AppColors.kTextHint,
                                size: R.w(context, 14),
                              ),
                            ],
                          ),
                        ),
                      )).animate(delay: 50.ms).fadeIn(duration: 300.ms),

                  Gap(R.h(context, 20)),

                  // ── Split between ────────────────────────────
                  Text('Split between', style: AppTextStyles.inputLabel),
                  Gap(R.h(context, 8)),
                  Obx(() {
                    final selected = controller.selectedSplitWith;

                    // Show all names joined
                    final label = selected.isEmpty
                        ? 'Select members'
                        : selected.length == 1
                            ? selected.first.displayName
                            : selected.map((m) => m.displayName).join(', ');

                    // Live per-person preview
                    final amount = double.tryParse(
                        controller.expenseAmountController.text.trim());
                    final perPerson = amount != null && selected.isNotEmpty
                        ? amount / selected.length
                        : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final g = controller.groups
                                .firstWhereOrNull((g) => g.id == groupId);
                            if (g != null) {
                              _showSplitBetweenSheet(context, controller, g);
                            }
                          },
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
                                  CupertinoIcons.person_3,
                                  color: AppColors.kTextHint,
                                  size: R.w(context, 18),
                                ),
                                Gap(R.w(context, 8)),
                                Expanded(
                                  child: Text(
                                    label,
                                    style: selected.isEmpty
                                        ? AppTextStyles.inputHint
                                        : AppTextStyles.inputValue,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.chevron_down,
                                  color: AppColors.kTextHint,
                                  size: R.w(context, 14),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Per-person preview
                        if (perPerson > 0) ...[
                          Gap(R.h(context, 6)),
                          Text(
                            '${AppFormatters.formatCurrency(perPerson)} per person',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.kPrimary,
                            ),
                          ),
                        ],
                      ],
                    );
                  }).animate(delay: 75.ms).fadeIn(duration: 300.ms),

                  Gap(R.h(context, 20)),

                  // ── Date ─────────────────────────────────────
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
                      )).animate(delay: 100.ms).fadeIn(duration: 300.ms),

                  Gap(R.h(context, 28)),

                  // Submit
                  Obx(() => PrimaryButton(
                        text: controller.isExpenseEditMode.value
                            ? 'Update Expense'
                            : AppStrings.addExpense,
                        onPressed: controller.submitGroupExpense,
                        isLoading: controller.isExpenseSubmitting.value,
                      )).animate(delay: 125.ms).fadeIn(duration: 300.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Who Paid Bottom Sheet ─────────────────────────────────────

  void _showWhoPaidSheet(
    BuildContext context,
    GroupController controller,
    GroupModel group,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: EdgeInsets.all(R.w(context, 16)),
          decoration: const BoxDecoration(
            color: AppColors.kCard,
            borderRadius: AppRadius.modal,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(R.h(context, 8)),
              Center(
                child: Container(
                  width: R.w(context, 40),
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.kBorder,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  R.h(context, 16),
                  AppSpacing.lg,
                  R.h(context, 8),
                ),
                child: Text('Who paid?', style: AppTextStyles.headingSmall),
              ),
              ...group.members.map((member) {
                return Obx(() {
                  final isSelected =
                      controller.selectedPaidBy.value?.displayName ==
                          member.displayName;
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Container(
                        width: R.w(context, 36),
                        height: R.w(context, 36),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.kPrimary
                              : AppColors.kPrimaryTint,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            member.initials,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.kPrimary,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        member.displayName,
                        style: AppTextStyles.bodyMedium,
                      ),
                      trailing: isSelected
                          ? Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: AppColors.kPrimary,
                              size: R.w(context, 20),
                            )
                          : null,
                      onTap: () {
                        controller.selectedPaidBy.value = member;
                        Get.back();
                      },
                    ),
                  );
                });
              }),
              Gap(R.h(context, 16)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Split Between Bottom Sheet ────────────────────────────────

  void _showSplitBetweenSheet(
    BuildContext context,
    GroupController controller,
    GroupModel group,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: EdgeInsets.all(R.w(context, 16)),
          decoration: const BoxDecoration(
            color: AppColors.kCard,
            borderRadius: AppRadius.modal,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(R.h(context, 8)),
              Center(
                child: Container(
                  width: R.w(context, 40),
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.kBorder,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  R.h(context, 16),
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Split between', style: AppTextStyles.headingSmall),
                    GestureDetector(
                      onTap: () {
                        if (controller.selectedSplitWith.length ==
                            group.members.length) {
                          controller.selectedSplitWith.clear();
                        } else {
                          controller.selectedSplitWith.value =
                              List.from(group.members);
                        }
                      },
                      child: Obx(() => Text(
                            controller.selectedSplitWith.length ==
                                    group.members.length
                                ? 'Clear all'
                                : 'Select all',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.kPrimary,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
              Gap(R.h(context, 8)),
              ...group.members.map((member) {
                return Obx(() {
                  final isSelected = controller.selectedSplitWith
                      .any((m) => m.displayName == member.displayName);

                  final amount = double.tryParse(
                    controller.expenseAmountController.text.trim(),
                  );
                  final count = controller.selectedSplitWith.length;
                  final perPerson =
                      amount != null && count > 0 ? amount / count : 0.0;

                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Container(
                        width: R.w(context, 36),
                        height: R.w(context, 36),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.kPrimary
                              : AppColors.kPrimaryTint,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            member.initials,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.kPrimary,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        member.displayName,
                        style: AppTextStyles.bodyMedium,
                      ),
                      subtitle: isSelected && perPerson > 0
                          ? Text(
                              AppFormatters.formatCurrency(perPerson),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.kPrimary,
                              ),
                            )
                          : null,
                      trailing: Checkbox(
                        value: isSelected,
                        activeColor: AppColors.kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (_) {
                          if (isSelected) {
                            controller.selectedSplitWith.removeWhere(
                                (m) => m.displayName == member.displayName);
                          } else {
                            controller.selectedSplitWith.add(member);
                          }
                        },
                      ),
                      onTap: () {
                        if (isSelected) {
                          controller.selectedSplitWith.removeWhere(
                              (m) => m.displayName == member.displayName);
                        } else {
                          controller.selectedSplitWith.add(member);
                        }
                      },
                    ),
                  );
                });
              }),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  R.h(context, 16),
                  AppSpacing.lg,
                  R.h(context, 16),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: R.h(context, 48),
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kPrimary,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonLarge),
                    ),
                    child: Text('Confirm', style: AppTextStyles.buttonPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    return '${date.day}/${date.month}/${date.year},'
        ' ${_timeString(date)}';
  }

  String _timeString(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
