// MoneyBuddy
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
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/feedback/empty_state.dart';
import '../../../shared/widgets/feedback/error_widget.dart';
import '../../../shared/widgets/feedback/shimmer_widget.dart';
import '../../../shared/widgets/misc/transaction_tile.dart';
import '../controllers/transaction_controller.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ─────────────────────────────────────────
            Padding(
              padding: AppSpacing.horizontalScreen.copyWith(top: 20),
              child: Row(
                children: [
                  Text(
                    AppStrings.transactions,
                    style: AppTextStyles.headingLarge,
                  ),
                  const Spacer(),
                  // Search toggle
                  Obx(() => GestureDetector(
                        onTap: () {
                          if (controller.isSearching.value) {
                            controller.clearSearch();
                          } else {
                            controller.isSearching.value = true;
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(R.w(context, 8)),
                          decoration: BoxDecoration(
                            color: controller.isSearching.value
                                ? AppColors.kPrimaryTint
                                : AppColors.kSurface,
                            borderRadius: AppRadius.tile,
                          ),
                          child: Icon(
                            CupertinoIcons.search,
                            color: controller.isSearching.value
                                ? AppColors.kPrimary
                                : AppColors.kTextHint,
                            size: R.w(context, 18),
                          ),
                        ),
                      )),
                  Gap(R.w(context, 8)),
                  // Date filter toggle
                  Obx(() => GestureDetector(
                        onTap: () => _showDateFilter(context, controller),
                        child: Container(
                          padding: EdgeInsets.all(R.w(context, 8)),
                          decoration: BoxDecoration(
                            color: controller.hasActiveFilter
                                ? AppColors.kPrimaryTint
                                : AppColors.kSurface,
                            borderRadius: AppRadius.tile,
                          ),
                          child: Icon(
                            CupertinoIcons.slider_horizontal_3,
                            color: controller.hasActiveFilter
                                ? AppColors.kPrimary
                                : AppColors.kTextHint,
                            size: R.w(context, 18),
                          ),
                        ),
                      )),
                ],
              ),
            ),

            // ── Search bar ──────────────────────────────────────
            Obx(() {
              if (!controller.isSearching.value) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: AppSpacing.horizontalScreen.copyWith(top: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.kSurface,
                    borderRadius: AppRadius.input,
                    border: Border.all(color: AppColors.kBorder),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: R.w(context, 12)),
                        child: Icon(
                          CupertinoIcons.search,
                          color: AppColors.kTextHint,
                          size: R.w(context, 16),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller.searchController,
                          autofocus: true,
                          style: AppTextStyles.inputValue,
                          decoration: InputDecoration(
                            hintText: 'Search transactions...',
                            hintStyle: AppTextStyles.inputHint,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: R.h(context, 12)),
                          ),
                          cursorColor: AppColors.kPrimary,
                        ),
                      ),
                      Obx(() => controller.searchQuery.value.isNotEmpty
                          ? GestureDetector(
                              onTap: () =>
                                  controller.searchController.clear(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: R.w(context, 12)),
                                child: Icon(
                                  CupertinoIcons.xmark_circle_fill,
                                  color: AppColors.kTextHint,
                                  size: R.w(context, 16),
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1);
            }),

            // ── Active date filter chip ─────────────────────────
            Obx(() {
              if (!controller.hasActiveFilter) return const SizedBox.shrink();
              final from = controller.dateFrom.value;
              final to   = controller.dateTo.value;
              final label = from != null && to != null
                  ? '${from.day}/${from.month} – ${to.day}/${to.month}'
                  : from != null
                      ? 'From ${from.day}/${from.month}'
                      : 'To ${to!.day}/${to.month}';
              return Padding(
                padding: AppSpacing.horizontalScreen.copyWith(top: 8),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.w(context, 10),
                        vertical:   R.h(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryTint,
                        borderRadius: AppRadius.pill,
                        border: Border.all(
                          color: AppColors.kPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size:  R.w(context, 12),
                            color: AppColors.kPrimary,
                          ),
                          Gap(R.w(context, 4)),
                          Text(
                            label,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.kPrimary,
                            ),
                          ),
                          Gap(R.w(context, 4)),
                          GestureDetector(
                            onTap: controller.clearDateFilter,
                            child: Icon(
                              CupertinoIcons.xmark,
                              size:  R.w(context, 10),
                              color: AppColors.kPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            Gap(R.h(context, 12)),

            // ── Filter tabs ────────────────────────────────────
            Obx(() => Padding(
                  padding: AppSpacing.horizontalScreen,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.kSurface,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Row(
                      children: [
                        _FilterTab(
                          label: 'All',
                          index: 0,
                          currentIndex: controller.filterIndex.value,
                          onTap: () => controller.filterIndex.value = 0,
                        ),
                        _FilterTab(
                          label: 'Income',
                          index: 1,
                          currentIndex: controller.filterIndex.value,
                          onTap: () => controller.filterIndex.value = 1,
                        ),
                        _FilterTab(
                          label: 'Expense',
                          index: 2,
                          currentIndex: controller.filterIndex.value,
                          onTap: () => controller.filterIndex.value = 2,
                        ),
                      ],
                    ),
                  ),
                )),

            Gap(R.h(context, 12)),

            // ── Transaction list ───────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return _buildShimmer(context);

                if (controller.errorMessage.isNotEmpty) {
                  return AppErrorWidget(
                    message: controller.errorMessage.value,
                    onRetry: controller.loadTransactions,
                  );
                }

                final grouped = controller.groupedTransactions;

                if (grouped.isEmpty) {
                  return EmptyState(
                    icon:     CupertinoIcons.doc_text,
                    title:    controller.searchQuery.value.isNotEmpty
                        ? 'No results found'
                        : AppStrings.noTransactions,
                    subtitle: controller.searchQuery.value.isNotEmpty
                        ? 'Try a different search term'
                        : AppStrings.noTxDesc,
                  );
                }

                return RefreshIndicator(
                  color: AppColors.kPrimary,
                  onRefresh: controller.loadTransactions,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: grouped.keys.length,
                    itemBuilder: (_, groupIndex) {
                      final dateKey = grouped.keys.elementAt(groupIndex);
                      final txList  = grouped[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Date group header — pill style ────
                          Padding(
                            padding: AppSpacing.horizontalScreen.copyWith(
                              top: 16, bottom: 8,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: R.w(context, 10),
                                vertical:   R.h(context, 4),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.kSurface,
                                borderRadius: AppRadius.pill,
                              ),
                              child: Text(
                                dateKey,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.kTextSecondary,
                                ),
                              ),
                            ),
                          ),

                          // ── Transactions ──────────────────────
                          Container(
                            margin: AppSpacing.horizontalScreen,
                            decoration: BoxDecoration(
                              color: AppColors.kCard,
                              borderRadius: AppRadius.card,
                              border: Border.all(
                                color: AppColors.kBorder,
                                width: 0.8,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: AppRadius.card,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount: txList.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: AppColors.kDivider,
                                  indent: 60,
                                ),
                                itemBuilder: (_, i) {
                                  final tx = txList[i];
                                  return TransactionTile(
                                    title:    tx.description,
                                    amount:   tx.amount,
                                    type:     tx.type,
                                    category: tx.category ?? tx.type,
                                    date:     tx.date,
                                    onDelete: () =>
                                        controller.deleteTransaction(tx.id),
                                    onEdit: () {
                                      controller.startEdit(tx);
                                      Get.toNamed(
                                          AppRoutes.addTransaction);
                                    },
                                  )
                                      .animate(
                                        delay: Duration(
                                          milliseconds:
                                              groupIndex * 30 + i * 20,
                                        ),
                                      )
                                      .fadeIn(duration: 250.ms)
                                      .slideX(begin: 0.05, end: 0);
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return ListView(
      padding: AppSpacing.horizontalScreen,
      children: List.generate(
        5,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: R.h(context, 8)),
          child: ShimmerWidget(
              width: double.infinity, height: R.h(context, 68)),
        ),
      ),
    );
  }

  void _showDateFilter(
      BuildContext context, TransactionController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DateFilterSheet(controller: controller),
    );
  }
}

// ── Date Filter Bottom Sheet ──────────────────────────────────────

class _DateFilterSheet extends StatefulWidget {
  final TransactionController controller;
  const _DateFilterSheet({required this.controller});

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _from = widget.controller.dateFrom.value;
    _to   = widget.controller.dateTo.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(R.w(context, 16)),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl, AppSpacing.lg,
        AppSpacing.xxl, R.h(context, 24),
      ),
      decoration: const BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Gap(R.h(context, 20)),
          Text('Filter by Date', style: AppTextStyles.headingSmall),
          Gap(R.h(context, 20)),

          // Quick filters
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickFilter(
                label: 'Today',
                onTap: () {
                  final now = DateTime.now();
                  setState(() {
                    _from = DateTime(now.year, now.month, now.day);
                    _to   = _from;
                  });
                },
              ),
              _QuickFilter(
                label: 'This Week',
                onTap: () {
                  final now = DateTime.now();
                  setState(() {
                    _from = now.subtract(Duration(days: now.weekday - 1));
                    _to   = now;
                  });
                },
              ),
              _QuickFilter(
                label: 'This Month',
                onTap: () {
                  final now = DateTime.now();
                  setState(() {
                    _from = DateTime(now.year, now.month, 1);
                    _to   = now;
                  });
                },
              ),
              _QuickFilter(
                label: 'Last Month',
                onTap: () {
                  final now = DateTime.now();
                  final last = DateTime(now.year, now.month - 1, 1);
                  setState(() {
                    _from = last;
                    _to   = DateTime(now.year, now.month, 0);
                  });
                },
              ),
            ],
          ),

          Gap(R.h(context, 20)),

          // From date
          _DateRow(
            label: 'From',
            date:  _from,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _from ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.kPrimary,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _from = picked);
            },
          ),

          Gap(R.h(context, 12)),

          // To date
          _DateRow(
            label: 'To',
            date:  _to,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _to ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.kPrimary,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _to = picked);
            },
          ),

          Gap(R.h(context, 24)),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: R.h(context, 48),
                  child: OutlinedButton(
                    onPressed: () {
                      widget.controller.clearDateFilter();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.kBorder),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonLarge),
                    ),
                    child: Text('Clear',
                        style: AppTextStyles.buttonSecondary),
                  ),
                ),
              ),
              Gap(R.w(context, 12)),
              Expanded(
                child: SizedBox(
                  height: R.h(context, 48),
                  child: ElevatedButton(
                    onPressed: () {
                      widget.controller.dateFrom.value = _from;
                      widget.controller.dateTo.value   = _to;
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kPrimary,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonLarge),
                    ),
                    child: Text('Apply',
                        style: AppTextStyles.buttonPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickFilter extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickFilter({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.w(context, 12),
          vertical:   R.h(context, 6),
        ),
        decoration: BoxDecoration(
          color: AppColors.kPrimaryTint,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: AppColors.kPrimary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.kPrimary,
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DateRow({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.w(context, 16),
          vertical:   R.h(context, 12),
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
              size: R.w(context, 16),
            ),
            Gap(R.w(context, 8)),
            Text(
              '$label:  ',
              style: AppTextStyles.inputLabel,
            ),
            Text(
              date != null
                  ? '${date!.day}/${date!.month}/${date!.year}'
                  : 'Select date',
              style: AppTextStyles.inputValue.copyWith(
                color: date != null
                    ? AppColors.kTextPrimary
                    : AppColors.kTextHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Tab ────────────────────────────────────────────────────

class _FilterTab extends StatelessWidget {
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.kCard : Colors.transparent,
            borderRadius: AppRadius.pill,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: isActive
                ? AppTextStyles.labelLarge.copyWith(
                    color: AppColors.kPrimary)
                : AppTextStyles.labelMedium,
          ),
        ),
      ),
    );
  }
}