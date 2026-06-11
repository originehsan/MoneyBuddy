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
import '../controllers/budget_controller.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Column(
        children: [

          // ── Header ──────────────────────────────────────────
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
                    // Back + title + clear all
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
                          'Category Budgets',
                          style: AppTextStyles.headingSmall
                              .copyWith(color: Colors.white),
                        ),
                        const Spacer(),
                        // Add budget button
                        GestureDetector(
                          onTap: () =>
                              _showAddBudgetSheet(context, controller),
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

                    // Overall summary
                    Obx(() {
                      final total  = controller.totalBudget.value;
                      final spent  = controller.totalSpent.value;
                      final pct    = total > 0
                          ? (spent / total).clamp(0.0, 1.0)
                          : 0.0;
                      final isOver = spent > total && total > 0;

                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: AppRadius.card,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Budgeted',
                                      style: AppTextStyles.labelSmall
                                          .copyWith(
                                              color: Colors.white70),
                                    ),
                                    Text(
                                      AppFormatters.formatCurrency(
                                          total),
                                      style: AppTextStyles.moneyMedium
                                          .copyWith(
                                              color: Colors.white),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Spent This Month',
                                      style: AppTextStyles.labelSmall
                                          .copyWith(
                                              color: Colors.white70),
                                    ),
                                    Text(
                                      AppFormatters.formatCurrency(
                                          spent),
                                      style: AppTextStyles.moneyMedium
                                          .copyWith(
                                        color: isOver
                                            ? const Color(0xFFFFCDD2)
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Gap(R.h(context, 12)),
                            ClipRRect(
                              borderRadius: AppRadius.pill,
                              child: LinearProgressIndicator(
                                value:     pct,
                                minHeight: 6,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  isOver
                                      ? const Color(0xFFFF5252)
                                      : Colors.white,
                                ),
                              ),
                            ),
                            Gap(R.h(context, 6)),
                            Text(
                              total > 0
                                  ? isOver
                                      ? 'Over budget by ${AppFormatters.formatCurrencyCompact(spent - total)}'
                                      : '${AppFormatters.formatCurrencyCompact(total - spent)} remaining'
                                  : 'No budgets set yet',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: Colors.white70),
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

          // ── Category list ────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmer(context);
              }

              final active = controller.activeCategories;

              if (active.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.chart_bar_circle,
                        size:  R.w(context, 56),
                        color: AppColors.kTextHint,
                      ),
                      Gap(R.h(context, 16)),
                      Text(
                        'No budgets set',
                        style: AppTextStyles.headingSmall,
                      ),
                      Gap(R.h(context, 8)),
                      Text(
                        'Tap + to set a budget for a category',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color:     AppColors.kPrimary,
                onRefresh: controller.loadData,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    R.h(context, 16),
                    AppSpacing.xxl,
                    100,
                  ),
                  itemCount: active.length,
                  itemBuilder: (_, i) {
                    final cat = active[i];
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: R.h(context, 12)),
                      child: _CategoryBudgetCard(
                        category:   cat,
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
          4,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: R.h(context, 12)),
            child: ShimmerWidget(
                width: double.infinity, height: R.h(context, 100)),
          ),
        ),
      ),
    );
  }

  void _showAddBudgetSheet(
      BuildContext context, BudgetController controller) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _AddBudgetSheet(controller: controller),
    );
  }
}

// ── Category Budget Card ──────────────────────────────────────────

class _CategoryBudgetCard extends StatelessWidget {
  final String           category;
  final BudgetController controller;
  final int              index;

  const _CategoryBudgetCard({
    required this.category,
    required this.controller,
    required this.index,
  });

  Color get _barColor {
    if (controller.isOverBudget(category))  return AppColors.kError;
    if (controller.isNearBudget(category))  return AppColors.kWarning;
    return AppColors.kPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final budget    = controller.budgetFor(category);
    final spent     = controller.spentFor(category);
    final remaining = controller.remainingFor(category);
    final progress  = controller.progressFor(category);
    final isOver    = controller.isOverBudget(category);
    final isNear    = controller.isNearBudget(category);
    final hasBudget = budget > 0;

    return GestureDetector(
      onTap: () => _showEditSheet(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.kCard,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isOver
                ? AppColors.kError.withValues(alpha: 0.3)
                : isNear
                    ? AppColors.kWarning.withValues(alpha: 0.3)
                    : AppColors.kBorder,
            width: 0.8,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category icon
                Container(
                  padding: EdgeInsets.all(R.w(context, 8)),
                  decoration: BoxDecoration(
                    color: isOver
                        ? AppColors.kErrorBg
                        : AppColors.kPrimaryTint,
                    borderRadius: AppRadius.tile,
                  ),
                  child: Icon(
                    _categoryIcon(category),
                    color: isOver
                        ? AppColors.kError
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
                        category,
                        style: AppTextStyles.labelLarge,
                      ),
                      if (hasBudget)
                        Text(
                          isOver
                              ? 'Over by ${AppFormatters.formatCurrencyCompact(spent - budget)}'
                              : '${AppFormatters.formatCurrencyCompact(remaining)} left',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isOver
                                ? AppColors.kError
                                : isNear
                                    ? AppColors.kWarning
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
                      AppFormatters.formatCurrencyCompact(spent),
                      style: AppTextStyles.moneyMedium.copyWith(
                        color: isOver
                            ? AppColors.kError
                            : AppColors.kTextPrimary,
                      ),
                    ),
                    if (hasBudget)
                      Text(
                        'of ${AppFormatters.formatCurrencyCompact(budget)}',
                        style: AppTextStyles.bodySmall,
                      ),
                  ],
                ),
                Gap(R.w(context, 8)),
                // 3 dot menu
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

            if (hasBudget) ...[
              Gap(R.h(context, 12)),
              ClipRRect(
                borderRadius: AppRadius.pill,
                child: LinearProgressIndicator(
                  value:      progress,
                  minHeight:  6,
                  backgroundColor: AppColors.kSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                ),
              ),
              Gap(R.h(context, 6)),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% used',
                style: AppTextStyles.labelSmall.copyWith(
                  color: _barColor,
                ),
              ),
            ] else ...[
              Gap(R.h(context, 8)),
              Text(
                'Tap to set a budget',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.kTextHint,
                ),
              ),
            ],
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 60))
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.1, end: 0),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _SetBudgetSheet(
        category:   category,
        controller: controller,
        initial:    controller.budgetFor(category),
      ),
    );
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
                    'Edit Budget',
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () {
                    Get.back();
                    _showEditSheet(context);
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
                    'Clear Budget',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.kError,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    controller.clearCategoryBudget(category);
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

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':          return CupertinoIcons.cart;
      case 'transport':     return CupertinoIcons.car;
      case 'shopping':      return CupertinoIcons.bag;
      case 'bills':         return CupertinoIcons.doc_text;
      case 'health':        return CupertinoIcons.heart;
      case 'travel':        return CupertinoIcons.airplane;
      case 'education':     return CupertinoIcons.book;
      case 'entertainment': return CupertinoIcons.film;
      case 'rent':          return CupertinoIcons.house;
      case 'emi':           return CupertinoIcons.creditcard;
      default:              return CupertinoIcons.square_grid_2x2;
    }
  }
}

// ── Set Budget Sheet ──────────────────────────────────────────────

class _SetBudgetSheet extends StatefulWidget {
  final String           category;
  final BudgetController controller;
  final double           initial;

  const _SetBudgetSheet({
    required this.category,
    required this.controller,
    required this.initial,
  });

  @override
  State<_SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends State<_SetBudgetSheet> {
  late final TextEditingController _amountController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initial > 0
          ? widget.initial.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(R.w(context, 16)),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
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
          Text(
            'Set ${widget.category} Budget',
            style: AppTextStyles.headingSmall,
          ),
          Gap(R.h(context, 4)),
          Text(
            'How much do you want to spend on ${widget.category} this month?',
            style: AppTextStyles.bodySmall,
          ),
          Gap(R.h(context, 20)),
          TextField(
            controller:   _amountController,
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
                color: AppColors.kTextHint,
              ),
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
          Gap(R.h(context, 20)),
          SizedBox(
            width:  double.infinity,
            height: R.h(context, 52),
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.buttonLarge),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Save Budget',
                      style: AppTextStyles.buttonPrimary),
            ),
          ),
          if (widget.initial > 0) ...[
            Gap(R.h(context, 8)),
            Center(
              child: TextButton(
                onPressed: _clear,
                child: Text(
                  'Clear Budget',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: AppColors.kTextHint,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error', 'Enter a valid amount',
        backgroundColor: AppColors.kError,
        colorText:       Colors.white,
        snackPosition:   SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _saving = true);
    await widget.controller.saveCategoryBudget(
        widget.category, amount);
    setState(() => _saving = false);
    Get.back();
  }

  Future<void> _clear() async {
    await widget.controller.clearCategoryBudget(widget.category);
    Get.back();
  }
}

// ── Add Budget Sheet (category selector) ─────────────────────────

class _AddBudgetSheet extends StatefulWidget {
  final BudgetController controller;
  const _AddBudgetSheet({required this.controller});

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final unbudgeted = widget.controller.unbudgetedCategories;

    return Container(
      margin: EdgeInsets.all(R.w(context, 16)),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
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
          Text('Choose Category', style: AppTextStyles.headingSmall),
          Gap(R.h(context, 4)),
          Text(
            'Select a category to set a budget for.',
            style: AppTextStyles.bodySmall,
          ),
          Gap(R.h(context, 16)),
          if (unbudgeted.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: R.h(context, 16)),
              child: Text(
                'All categories have budgets set.',
                style: AppTextStyles.bodySmall,
              ),
            )
          else
            Wrap(
              spacing:    8,
              runSpacing: 8,
              children: unbudgeted.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.kPrimary
                          : AppColors.kPrimaryTint,
                      borderRadius: AppRadius.pill,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.kPrimary
                            : AppColors.kPrimary
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.kPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          Gap(R.h(context, 20)),
          SizedBox(
            width:  double.infinity,
            height: R.h(context, 52),
            child: ElevatedButton(
              onPressed: _selectedCategory == null
                  ? null
                  : () {
                      Get.back();
                      showModalBottomSheet(
                        context:            context,
                        isScrollControlled: true,
                        backgroundColor:    Colors.transparent,
                        builder: (_) => _SetBudgetSheet(
                          category:   _selectedCategory!,
                          controller: widget.controller,
                          initial:    0,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                disabledBackgroundColor:
                    AppColors.kPrimary.withValues(alpha: 0.4),
                elevation: 0,
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.buttonLarge),
              ),
              child: Text('Next',
                  style: AppTextStyles.buttonPrimary),
            ),
          ),
        ],
      ),
    );
  }
}