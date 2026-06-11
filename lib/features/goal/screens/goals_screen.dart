// MoneyBuddy
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/feedback/shimmer_widget.dart';
import '../controllers/goals_controller.dart';
import '../models/goal_model.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GoalsController>();

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
                  AppSpacing.lg, AppSpacing.sm,
                  AppSpacing.lg, R.h(context, 24),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(R.w(context, 8)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadius.tile,
                        ),
                        child: Icon(
                          CupertinoIcons.back,
                          color: Colors.white,
                          size: R.w(context, 18),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Savings Goals',
                      style: AppTextStyles.headingSmall
                          .copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        controller.resetForm();
                        _showAddGoalSheet(context, controller);
                      },
                      child: Container(
                        padding: EdgeInsets.all(R.w(context, 8)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadius.tile,
                        ),
                        child: Icon(
                          CupertinoIcons.add,
                          color: Colors.white,
                          size: R.w(context, 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Goals list ────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmer(context);
              }

              if (controller.goals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.star_circle,
                        size:  R.w(context, 56),
                        color: AppColors.kTextHint,
                      ),
                      Gap(R.h(context, 16)),
                      Text(
                        'No goals yet',
                        style: AppTextStyles.headingSmall,
                      ),
                      Gap(R.h(context, 8)),
                      Text(
                        'Tap + to create your first savings goal',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color:     AppColors.kPrimary,
                onRefresh: controller.loadGoals,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl, R.h(context, 16),
                    AppSpacing.xxl, 100,
                  ),
                  itemCount: controller.goals.length,
                  itemBuilder: (_, i) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: R.h(context, 12)),
                      child: _GoalCard(
                        goal:       controller.goals[i],
                        controller: controller,
                        index:      i,
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalScreen,
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: R.h(context, 12)),
            child: ShimmerWidget(
                width: double.infinity, height: R.h(context, 160)),
          ),
        ),
      ),
    );
  }

  void _showAddGoalSheet(
      BuildContext context, GoalsController controller) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _GoalFormSheet(controller: controller),
    );
  }
}

// ── Goal Card ─────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final GoalModel        goal;
  final GoalsController  controller;
  final int              index;

  const _GoalCard({
    required this.goal,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = goal.isCompleted;
    final daysLeft    = goal.daysLeft;
    final isOverdue   = daysLeft < 0 && !isCompleted;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isCompleted
              ? AppColors.kSuccess.withValues(alpha: 0.3)
              : AppColors.kBorder,
          width: 0.8,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(R.w(context, 10)),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.kSuccessBg
                      : AppColors.kPrimaryTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconData(goal.icon),
                  color: isCompleted
                      ? AppColors.kSuccess
                      : AppColors.kPrimary,
                  size: R.w(context, 20),
                ),
              ),
              Gap(R.w(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isCompleted
                          ? 'Goal achieved!'
                          : isOverdue
                              ? 'Overdue by ${(-daysLeft)} days'
                              : '$daysLeft days left',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isCompleted
                            ? AppColors.kSuccess
                            : isOverdue
                                ? AppColors.kError
                                : AppColors.kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 3-dot options
              GestureDetector(
                onTap: () => _showOptions(context),
                child: Icon(
                  CupertinoIcons.ellipsis,
                  size:  R.w(context, 18),
                  color: AppColors.kTextHint,
                ),
              ),
            ],
          ),

          Gap(R.h(context, 16)),

          // ── Circular progress + amounts ──────────────────────
          Row(
            children: [
              // Circular progress
              SizedBox(
                width:  R.w(context, 80),
                height: R.w(context, 80),
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: goal.progress,
                        strokeWidth: 6,
                        backgroundColor:
                            AppColors.kSurface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted
                              ? AppColors.kSuccess
                              : AppColors.kPrimary,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(goal.progress * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: R.sp(context, 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Gap(R.w(context, 16)),

              // Amounts + deadline
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AmountRow(
                      label: 'Saved',
                      value: AppFormatters.formatCurrencyCompact(
                          goal.savedAmount),
                      color: AppColors.kSuccess,
                    ),
                    Gap(R.h(context, 4)),
                    _AmountRow(
                      label: 'Target',
                      value: AppFormatters.formatCurrencyCompact(
                          goal.targetAmount),
                      color: AppColors.kTextPrimary,
                    ),
                    Gap(R.h(context, 4)),
                    _AmountRow(
                      label: 'Remaining',
                      value: AppFormatters.formatCurrencyCompact(
                          goal.remaining),
                      color: AppColors.kExpense,
                    ),
                    if (!isCompleted &&
                        goal.dailySavingsNeeded > 0) ...[
                      Gap(R.h(context, 4)),
                      _AmountRow(
                        label: 'Save/day',
                        value: AppFormatters.formatCurrencyCompact(
                            goal.dailySavingsNeeded),
                        color: AppColors.kInfo,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (!isCompleted) ...[
            Gap(R.h(context, 16)),
            // Add money button
            SizedBox(
              width:  double.infinity,
              height: R.h(context, 44),
              child: ElevatedButton.icon(
                onPressed: () => _showAddMoneySheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimary,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.buttonLarge),
                ),
                icon: Icon(
                  CupertinoIcons.plus_circle,
                  size: R.w(context, 16),
                ),
                label: Text(
                  'Add Money',
                  style: AppTextStyles.buttonSmall,
                ),
              ),
            ),
          ] else ...[
            Gap(R.h(context, 12)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: R.h(context, 8)),
              decoration: BoxDecoration(
                color:        AppColors.kSuccessBg,
                borderRadius: AppRadius.pill,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: AppColors.kSuccess,
                    size:  R.w(context, 16),
                  ),
                  Gap(R.w(context, 6)),
                  Text(
                    'Goal Achieved!',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.kSuccess,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: EdgeInsets.all(R.w(context, 16)),
          decoration: const BoxDecoration(
            color:        AppColors.kCard,
            borderRadius: AppRadius.modal,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(R.h(context, 8)),
              Center(
                child: Container(
                  width:  R.w(context, 40),
                  height: 4,
                  decoration: const BoxDecoration(
                    color:        AppColors.kBorder,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              Gap(R.h(context, 16)),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(
                    CupertinoIcons.pencil,
                    color: AppColors.kTextPrimary,
                  ),
                  title: Text(
                    'Edit Goal',
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () {
                    Get.back();
                    controller.startEdit(goal);
                    showModalBottomSheet(
                      context:            context,
                      isScrollControlled: true,
                      backgroundColor:    Colors.transparent,
                      builder: (_) => _GoalFormSheet(
                          controller: controller),
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: AppColors.kDivider),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(
                    CupertinoIcons.trash,
                    color: AppColors.kError,
                  ),
                  title: Text(
                    'Delete Goal',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.kError,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    controller.deleteGoal(goal.id);
                  },
                ),
              ),
              Gap(R.h(context, 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMoneySheet(BuildContext context) {
    controller.addMoneyController.clear();
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _AddMoneySheet(
        goal:       goal,
        controller: controller,
      ),
    );
  }

  IconData _iconData(String icon) {
    switch (icon) {
      case 'house':         return CupertinoIcons.house_fill;
      case 'car':           return CupertinoIcons.car_fill;
      case 'airplane':      return CupertinoIcons.airplane;
      case 'bag':           return CupertinoIcons.bag_fill;
      case 'gift':          return CupertinoIcons.gift_fill;
      case 'heart':         return CupertinoIcons.heart_fill;
      case 'graduationcap': return CupertinoIcons.book_fill;
      case 'phone':         return CupertinoIcons.phone_fill;
      case 'laptop':        return CupertinoIcons.device_laptop;
      default:              return CupertinoIcons.star_fill;
    }
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _AmountRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(
          value,
          style: AppTextStyles.moneySmall.copyWith(color: color),
        ),
      ],
    );
  }
}

// ── Goal Form Sheet ───────────────────────────────────────────────

class _GoalFormSheet extends StatelessWidget {
  final GoalsController controller;
  const _GoalFormSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(R.w(context, 16)),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl, AppSpacing.lg,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + R.h(context, 24),
      ),
      decoration: const BoxDecoration(
        color:        AppColors.kCard,
        borderRadius: AppRadius.modal,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize:      MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width:  R.w(context, 40),
                height: 4,
                decoration: const BoxDecoration(
                  color:        AppColors.kBorder,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            Gap(R.h(context, 20)),
            Obx(() => Text(
                  controller.isEditMode.value
                      ? 'Edit Goal'
                      : 'New Savings Goal',
                  style: AppTextStyles.headingSmall,
                )),
            Gap(R.h(context, 20)),

            // Title
            Text('Goal Name', style: AppTextStyles.inputLabel),
            Gap(R.h(context, 8)),
            TextField(
              controller: controller.titleController,
              autofocus:  true,
              style:      AppTextStyles.inputValue,
              decoration: _inputDecoration('e.g. New Bike, Europe Trip'),
              cursorColor: AppColors.kPrimary,
            ),

            Gap(R.h(context, 16)),

            // Target amount
            Text('Target Amount', style: AppTextStyles.inputLabel),
            Gap(R.h(context, 8)),
            TextField(
              controller:   controller.amountController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              style:        AppTextStyles.inputValue,
              decoration:   _inputDecoration('₹50,000'),
              cursorColor:  AppColors.kPrimary,
            ),

            Gap(R.h(context, 16)),

            // Deadline
            Text('Target Date', style: AppTextStyles.inputLabel),
            Gap(R.h(context, 8)),
            Obx(() => GestureDetector(
                  onTap: () => _pickDate(context, controller),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical:   R.h(context, 14),
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
                          size:  R.w(context, 18),
                        ),
                        Gap(R.w(context, 8)),
                        Text(
                          _formatDate(
                              controller.selectedDeadline.value),
                          style: AppTextStyles.inputValue,
                        ),
                      ],
                    ),
                  ),
                )),

            Gap(R.h(context, 16)),

            // Icon picker
            Text('Icon', style: AppTextStyles.inputLabel),
            Gap(R.h(context, 8)),
            Obx(() => Wrap(
                  spacing:    8,
                  runSpacing: 8,
                  children: GoalsController.icons.map((icon) {
                    final isSelected =
                        controller.selectedIcon.value == icon;
                    return GestureDetector(
                      onTap: () =>
                          controller.selectedIcon.value = icon,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.all(R.w(context, 10)),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.kPrimary
                              : AppColors.kPrimaryTint,
                          borderRadius: AppRadius.tile,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.kPrimary
                                : AppColors.kPrimary
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          _iconData(icon),
                          size: R.w(context, 20),
                          color: isSelected
                              ? Colors.white
                              : AppColors.kPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                )),

            Gap(R.h(context, 24)),

            // Submit
            Obx(() => SizedBox(
                  width:  double.infinity,
                  height: R.h(context, 52),
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submitGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kPrimary,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonLarge),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          )
                        : Text(
                            controller.isEditMode.value
                                ? 'Update Goal'
                                : 'Create Goal',
                            style: AppTextStyles.buttonPrimary,
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(
      BuildContext context, GoalsController controller) async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: controller.selectedDeadline.value,
      firstDate:   DateTime.now().add(const Duration(days: 1)),
      lastDate:    DateTime.now().add(const Duration(days: 3650)),
      builder:     (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppColors.kPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) controller.selectedDeadline.value = picked;
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText:  hint,
    hintStyle: AppTextStyles.inputHint,
    filled:    true,
    fillColor: AppColors.kInputFill,
    border: const OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: AppColors.kBorder),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide:
          BorderSide(color: AppColors.kBorderActive, width: 1.5),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: AppColors.kBorder),
    ),
  );

  IconData _iconData(String icon) {
    switch (icon) {
      case 'house':         return CupertinoIcons.house_fill;
      case 'car':           return CupertinoIcons.car_fill;
      case 'airplane':      return CupertinoIcons.airplane;
      case 'bag':           return CupertinoIcons.bag_fill;
      case 'gift':          return CupertinoIcons.gift_fill;
      case 'heart':         return CupertinoIcons.heart_fill;
      case 'graduationcap': return CupertinoIcons.book_fill;
      case 'phone':         return CupertinoIcons.phone_fill;
      case 'laptop':        return CupertinoIcons.device_laptop;
      default:              return CupertinoIcons.star_fill;
    }
  }
}

// ── Add Money Sheet ───────────────────────────────────────────────

class _AddMoneySheet extends StatelessWidget {
  final GoalModel        goal;
  final GoalsController  controller;

  const _AddMoneySheet({
    required this.goal,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(R.w(context, 16)),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl, AppSpacing.lg,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + R.h(context, 24),
      ),
      decoration: const BoxDecoration(
        color:        AppColors.kCard,
        borderRadius: AppRadius.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width:  R.w(context, 40),
              height: 4,
              decoration: const BoxDecoration(
                color:        AppColors.kBorder,
                borderRadius: AppRadius.pill,
              ),
            ),
          ),
          Gap(R.h(context, 20)),
          Text('Add Money', style: AppTextStyles.headingSmall),
          Gap(R.h(context, 4)),
          Text(
            'How much are you adding to "${goal.title}"?',
            style: AppTextStyles.bodySmall,
          ),
          Gap(R.h(context, 20)),
          TextField(
            controller:   controller.addMoneyController,
            autofocus:    true,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true),
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.kTextPrimary,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText:  '₹0',
              hintStyle: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.kTextHint),
              filled:    true,
              fillColor: AppColors.kInputFill,
              border: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: AppColors.kBorder),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(
                    color: AppColors.kBorderActive, width: 1.5),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: AppColors.kBorder),
              ),
            ),
            cursorColor: AppColors.kPrimary,
          ),
          Gap(R.h(context, 8)),
          Text(
            '${AppFormatters.formatCurrencyCompact(goal.remaining)} still needed',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.kTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(R.h(context, 20)),
          SizedBox(
            width:  double.infinity,
            height: R.h(context, 52),
            child: ElevatedButton(
              onPressed: () => controller.addMoney(goal.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.buttonLarge),
              ),
              child: Text(
                'Add Money',
                style: AppTextStyles.buttonPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}