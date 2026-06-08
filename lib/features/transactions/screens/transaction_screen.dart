// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
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
              child: Text(
                AppStrings.transactions,
                style: AppTextStyles.headingLarge,
              ),
            ),

            const Gap(16),

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

            const Gap(16),

            // ── Transaction list ───────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return _buildShimmer();

                if (controller.errorMessage.isNotEmpty) {
                  return AppErrorWidget(
                    message: controller.errorMessage.value,
                    onRetry: controller.loadTransactions,
                  );
                }

                final grouped = controller.groupedTransactions;

                if (grouped.isEmpty) {
                  return const EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: AppStrings.noTransactions,
                    subtitle: AppStrings.noTxDesc,
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
                          // Date group header
                          Padding(
                            padding: AppSpacing.horizontalScreen.copyWith(
                              top: 16,
                              bottom: 8,
                            ),
                            child: Text(
                              dateKey,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.kTextSecondary,
                              ),
                            ),
                          ),

                          // Transactions in group
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
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: txList.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: AppColors.kDivider,
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
                                    // ── Edit — pre-fill form and navigate
                                    onEdit: () {
                                      controller.startEdit(tx);
                                      Get.toNamed(AppRoutes.addTransaction);
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

  Widget _buildShimmer() {
    return ListView(
      padding: AppSpacing.horizontalScreen,
      children: List.generate(
        5,
        (i) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: ShimmerWidget(width: double.infinity, height: 68),
        ),
      ),
    );
  }
}

/// Single segmented filter tab pill.
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
                ? AppTextStyles.labelLarge.copyWith(color: AppColors.kPrimary)
                : AppTextStyles.labelMedium,
          ),
        ),
      ),
    );
  }
}