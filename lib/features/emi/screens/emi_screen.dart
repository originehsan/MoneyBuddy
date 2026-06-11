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
import '../controllers/emi_controller.dart';
import '../models/emi_model.dart';

class EmiScreen extends StatelessWidget {
  const EmiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmiController>();

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
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(R.w(context, 8)),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.2),
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
                          'EMI Tracker',
                          style: AppTextStyles.headingSmall
                              .copyWith(color: Colors.white),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            controller.resetForm();
                            _showEmiForm(context, controller);
                          },
                          child: Container(
                            padding: EdgeInsets.all(R.w(context, 8)),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.2),
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

                    Gap(R.h(context, 20)),

                    // Total monthly EMI summary
                    Obx(() {
                      final total = controller.totalMonthlyEmi;
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: AppRadius.card,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Monthly EMI',
                                  style: AppTextStyles.labelSmall
                                      .copyWith(color: Colors.white70),
                                ),
                                Text(
                                  AppFormatters.formatCurrency(total),
                                  style: AppTextStyles.moneyMedium
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Active EMIs',
                                  style: AppTextStyles.labelSmall
                                      .copyWith(color: Colors.white70),
                                ),
                                Text(
                                  '${controller.emis.where((e) => !e.isCompleted).length}',
                                  style: AppTextStyles.moneyMedium
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // ── EMI list ──────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmer(context);
              }

              if (controller.emis.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.creditcard,
                        size:  R.w(context, 56),
                        color: AppColors.kTextHint,
                      ),
                      Gap(R.h(context, 16)),
                      Text(
                        'No EMIs tracked',
                        style: AppTextStyles.headingSmall,
                      ),
                      Gap(R.h(context, 8)),
                      Text(
                        'Tap + to add a loan or EMI',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color:     AppColors.kPrimary,
                onRefresh: controller.loadEmis,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl, R.h(context, 16),
                    AppSpacing.xxl, 100,
                  ),
                  itemCount: controller.emis.length,
                  itemBuilder: (_, i) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: R.h(context, 12)),
                      child: _EmiCard(
                        emi:        controller.emis[i],
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
                width: double.infinity, height: R.h(context, 140)),
          ),
        ),
      ),
    );
  }

  void _showEmiForm(BuildContext context, EmiController controller) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _EmiFormSheet(controller: controller),
    );
  }
}

// ── EMI Card ──────────────────────────────────────────────────────

class _EmiCard extends StatelessWidget {
  final EmiModel       emi;
  final EmiController  controller;
  final int            index;

  const _EmiCard({
    required this.emi,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = emi.isCompleted;
    final daysUntil   = emi.daysUntilDue;
    final isDueSoon   = daysUntil <= 7 && !isCompleted;
    final isOverdue   = daysUntil < 0  && !isCompleted;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isOverdue
              ? AppColors.kError.withValues(alpha: 0.3)
              : isDueSoon
                  ? AppColors.kWarning.withValues(alpha: 0.3)
                  : isCompleted
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
                padding: EdgeInsets.all(R.w(context, 8)),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.kSuccessBg
                      : AppColors.kPrimaryTint,
                  borderRadius: AppRadius.tile,
                ),
                child: Icon(
                  _iconData(emi.icon),
                  color: isCompleted
                      ? AppColors.kSuccess
                      : AppColors.kPrimary,
                  size: R.w(context, 18),
                ),
              ),
              Gap(R.w(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emi.name,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isCompleted
                          ? 'Fully paid off!'
                          : isOverdue
                              ? 'Overdue by ${(-daysUntil)} days'
                              : isDueSoon
                                  ? 'Due in $daysUntil days'
                                  : 'Due ${_formatDate(emi.nextDueDate)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isCompleted
                            ? AppColors.kSuccess
                            : isOverdue || isDueSoon
                                ? isOverdue
                                    ? AppColors.kError
                                    : AppColors.kWarning
                                : AppColors.kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.formatCurrencyCompact(emi.emiAmount),
                    style: AppTextStyles.moneyMedium,
                  ),
                  Text(
                    '/month',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              Gap(R.w(context, 8)),
              GestureDetector(
                onTap: () => _showOptions(context),
                child: Icon(
                  CupertinoIcons.ellipsis,
                  size:  R.w(context, 16),
                  color: AppColors.kTextHint,
                ),
              ),
            ],
          ),

          Gap(R.h(context, 12)),

          // ── Progress ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${emi.paidMonths}/${emi.totalMonths} months paid',
                style: AppTextStyles.labelSmall,
              ),
              Text(
                '${(emi.progress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isCompleted
                      ? AppColors.kSuccess
                      : AppColors.kPrimary,
                ),
              ),
            ],
          ),
          Gap(R.h(context, 6)),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value:      emi.progress,
              minHeight:  6,
              backgroundColor: AppColors.kSurface,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? AppColors.kSuccess : AppColors.kPrimary,
              ),
            ),
          ),

          Gap(R.h(context, 12)),

          // ── Amount summary ───────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SummaryChip(
                  label: 'Paid',
                  value: AppFormatters.formatCurrencyCompact(
                      emi.totalPaid),
                  color: AppColors.kSuccess,
                ),
              ),
              Gap(R.w(context, 8)),
              Expanded(
                child: _SummaryChip(
                  label: 'Remaining',
                  value: AppFormatters.formatCurrencyCompact(
                      emi.totalRemaining),
                  color: AppColors.kExpense,
                ),
              ),
              Gap(R.w(context, 8)),
              Expanded(
                child: _SummaryChip(
                  label: 'Total',
                  value: AppFormatters.formatCurrencyCompact(
                      emi.totalAmount),
                  color: AppColors.kTextPrimary,
                ),
              ),
            ],
          ),

          if (!isCompleted) ...[
            Gap(R.h(context, 12)),
            SizedBox(
              width:  double.infinity,
              height: R.h(context, 40),
              child: ElevatedButton.icon(
                onPressed: () => controller.markMonthPaid(emi),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimary,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.buttonLarge),
                ),
                icon: Icon(
                  CupertinoIcons.checkmark_circle,
                  size: R.w(context, 16),
                ),
                label: Text(
                  'Mark This Month Paid',
                  style: AppTextStyles.buttonSmall,
                ),
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
                    'Edit EMI',
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () {
                    Get.back();
                    controller.startEdit(emi);
                    showModalBottomSheet(
                      context:            context,
                      isScrollControlled: true,
                      backgroundColor:    Colors.transparent,
                      builder: (_) => _EmiFormSheet(
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
                    'Delete EMI',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.kError,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    controller.deleteEmi(emi.id);
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

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  IconData _iconData(String icon) {
    switch (icon) {
      case 'house':      return CupertinoIcons.house_fill;
      case 'car':        return CupertinoIcons.car_fill;
      case 'briefcase':  return CupertinoIcons.briefcase_fill;
      case 'phone':      return CupertinoIcons.phone_fill;
      case 'laptop':     return CupertinoIcons.device_laptop;
      case 'heart':      return CupertinoIcons.heart_fill;
      case 'star':       return CupertinoIcons.star_fill;
      default:           return CupertinoIcons.creditcard_fill;
    }
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.w(context, 8),
        vertical:   R.h(context, 6),
      ),
      decoration: BoxDecoration(
        color:        AppColors.kSurface,
        borderRadius: AppRadius.tile,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.moneySmall.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

// ── EMI Form Sheet ────────────────────────────────────────────────

class _EmiFormSheet extends StatelessWidget {
  final EmiController controller;
  const _EmiFormSheet({required this.controller});

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
          mainAxisSize:       MainAxisSize.min,
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
                      ? 'Edit EMI'
                      : 'Add EMI / Loan',
                  style: AppTextStyles.headingSmall,
                )),
            Gap(R.h(context, 20)),

            // Name
            Text('Loan Name', style: AppTextStyles.inputLabel),
            Gap(R.h(context, 8)),
            _buildField(
              context,
              controller:  controller.nameController,
              hint:        'e.g. Home Loan, Bike EMI',
              autofocus:   true,
            ),

            Gap(R.h(context, 16)),

            // Total amount
            Text('Total Loan Amount',
                style: AppTextStyles.inputLabel),
            Gap(R.h(context, 8)),
            _buildField(
              context,
              controller:  controller.totalAmountController,
              hint:        '₹5,00,000',
              isNumber:    true,
            ),

            Gap(R.h(context, 16)),

            // EMI amount
            Text('Monthly EMI', style: AppTextStyles.inputLabel),
            Gap(R.h(context, 8)),
            _buildField(
              context,
              controller: controller.emiAmountController,
              hint:       '₹8,500',
              isNumber:   true,
            ),

            Gap(R.h(context, 16)),

            // Tenure
            Text('Tenure (months)', style: AppTextStyles.inputLabel),
            Gap(R.h(context, 8)),
            _buildField(
              context,
              controller: controller.totalMonthsController,
              hint:       '36',
              isNumber:   true,
              isInt:      true,
            ),

            Gap(R.h(context, 16)),

            // Interest rate (optional)
            Text('Interest Rate % (optional)',
                style: AppTextStyles.inputLabel),
            Gap(R.h(context, 8)),
            _buildField(
              context,
              controller: controller.interestController,
              hint:       '8.5',
              isNumber:   true,
            ),

            Gap(R.h(context, 16)),

            // Start date
            Text('Start Date', style: AppTextStyles.inputLabel),
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
                              controller.selectedStartDate.value),
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
                  children: EmiController.icons.map((icon) {
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

            Obx(() => SizedBox(
                  width:  double.infinity,
                  height: R.h(context, 52),
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submitEmi,
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
                                ? 'Update EMI'
                                : 'Add EMI',
                            style: AppTextStyles.buttonPrimary,
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    bool autofocus = false,
    bool isNumber  = false,
    bool isInt     = false,
  }) {
    return TextField(
      controller:   controller,
      autofocus:    autofocus,
      keyboardType: isNumber
          ? isInt
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: AppTextStyles.inputValue,
      decoration: InputDecoration(
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
      ),
      cursorColor: AppColors.kPrimary,
    );
  }

  Future<void> _pickDate(
      BuildContext context, EmiController controller) async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: controller.selectedStartDate.value,
      firstDate:   DateTime(2020),
      lastDate:    DateTime.now(),
      builder:     (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppColors.kPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) controller.selectedStartDate.value = picked;
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  IconData _iconData(String icon) {
    switch (icon) {
      case 'house':      return CupertinoIcons.house_fill;
      case 'car':        return CupertinoIcons.car_fill;
      case 'briefcase':  return CupertinoIcons.briefcase_fill;
      case 'phone':      return CupertinoIcons.phone_fill;
      case 'laptop':     return CupertinoIcons.device_laptop;
      case 'heart':      return CupertinoIcons.heart_fill;
      case 'star':       return CupertinoIcons.star_fill;
      default:           return CupertinoIcons.creditcard_fill;
    }
  }
}