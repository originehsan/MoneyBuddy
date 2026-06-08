// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/cards/balance_card.dart';
import '../../../shared/widgets/cards/stat_card.dart';
import '../../../shared/widgets/feedback/empty_state.dart';
import '../../../shared/widgets/feedback/error_widget.dart';
import '../../../shared/widgets/feedback/shimmer_widget.dart';
import '../../../shared/widgets/misc/section_header.dart';
import '../../../shared/widgets/misc/transaction_tile.dart';
import '../../../shared/widgets/misc/budget_progress_bar.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) return _buildShimmer(context);
          if (controller.errorMessage.isNotEmpty) {
            return AppErrorWidget(
              message: controller.errorMessage.value,
              onRetry: controller.loadData,
            );
          }
          return RefreshIndicator(
            color: AppColors.kPrimary,
            onRefresh: controller.loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Greeting header ─────────────────────────
                  Padding(
                    padding: AppSpacing.horizontalScreen.copyWith(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${controller.greeting.value},',
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              controller.userName.value,
                              style: AppTextStyles.headingMedium,
                            ),
                          ],
                        ),
                        _Avatar(name: controller.userName.value),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.1, end: 0),

                  Gap(R.h(context, 20)),

                  // ── Balance card ─────────────────────────────
                  Padding(
                    padding: AppSpacing.horizontalScreen,
                    child: BalanceCard(
                      balance: controller.stats.value?.remainingBalance ?? 0,
                      income:  controller.stats.value?.totalIncome      ?? 0,
                      expense: controller.stats.value?.totalExpense      ?? 0,
                    ),
                  )
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0),

                  Gap(R.h(context, 20)),

                  // ── Stat cards ───────────────────────────────
                  SizedBox(
                    height: R.h(context, 110),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: AppSpacing.horizontalScreen,
                      children: [
                        SizedBox(
                          width: R.w(context, 140),
                          child: StatCard(
                            label: 'Daily avg',
                            value: AppFormatters.formatCurrencyCompact(
                              controller.stats.value?.averageDailyExpense ?? 0,
                            ),
                            icon: Icons.today_rounded,
                          ),
                        ),
                        Gap(R.w(context, 12)),
                        SizedBox(
                          width: R.w(context, 140),
                          child: StatCard(
                            label: 'Weekly avg',
                            value: AppFormatters.formatCurrencyCompact(
                              controller.stats.value?.averageWeeklyExpense ?? 0,
                            ),
                            icon: Icons.date_range_rounded,
                            iconColor: AppColors.kInfo,
                            iconBgColor: AppColors.kInfoBg,
                          ),
                        ),
                        Gap(R.w(context, 12)),
                        SizedBox(
                          width: R.w(context, 140),
                          child: StatCard(
                            label: 'Monthly avg',
                            value: AppFormatters.formatCurrencyCompact(
                              controller.stats.value?.averageMonthlyExpense ?? 0,
                            ),
                            icon: Icons.calendar_month_rounded,
                            iconColor: AppColors.kWarning,
                            iconBgColor: AppColors.kWarningBg,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

                  // ── Budget progress bar ──────────────────────
                  Obx(() {
                    if (controller.monthlyBudget.value <= 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: AppSpacing.horizontalScreen.copyWith(top: 20),
                      child: BudgetProgressBar(
                        spent:  controller.stats.value?.totalExpense ?? 0,
                        budget: controller.monthlyBudget.value,
                      ),
                    );
                  }),

                  Gap(R.h(context, 24)),

                  // ── Recent transactions ──────────────────────
                  Padding(
                    padding: AppSpacing.horizontalScreen,
                    child: SectionHeader(
                      title:       AppStrings.recentTx,
                      actionText:  AppStrings.seeAll,
                      actionRoute: AppRoutes.transactions,
                    ),
                  ),

                  Gap(R.h(context, 12)),

                  controller.recentTx.isEmpty
                      ? const EmptyState(
                          icon:     Icons.receipt_long_rounded,
                          title:    AppStrings.noTransactions,
                          subtitle: AppStrings.noTxDesc,
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.recentTx.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: AppColors.kDivider,
                          ),
                          itemBuilder: (_, i) {
                            final tx = controller.recentTx[i];
                            return TransactionTile(
                              title:    tx.description,
                              amount:   tx.amount,
                              type:     tx.type,
                              category: tx.category ?? tx.type,
                              date:     tx.date,
                            )
                                .animate(delay: (i * 50).ms)
                                .fadeIn(duration: 250.ms)
                                .slideX(begin: 0.05, end: 0);
                          },
                        ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          Gap(R.h(context, 20)),
          Row(
            children: [
              ShimmerWidget(width: R.w(context, 120), height: R.h(context, 40)),
              const Spacer(),
              ShimmerWidget(width: R.w(context, 44), height: R.w(context, 44), radius: 22),
            ],
          ),
          Gap(R.h(context, 20)),
          ShimmerWidget(width: double.infinity, height: R.h(context, 160)),
          Gap(R.h(context, 20)),
          Row(
            children: [
              Expanded(child: ShimmerWidget(width: double.infinity, height: R.h(context, 110))),
              Gap(R.w(context, 12)),
              Expanded(child: ShimmerWidget(width: double.infinity, height: R.h(context, 110))),
              Gap(R.w(context, 12)),
              Expanded(child: ShimmerWidget(width: double.infinity, height: R.h(context, 110))),
            ],
          ),
          Gap(R.h(context, 24)),
          ShimmerWidget(width: double.infinity, height: R.h(context, 68)),
          Gap(R.h(context, 8)),
          ShimmerWidget(width: double.infinity, height: R.h(context, 68)),
          Gap(R.h(context, 8)),
          ShimmerWidget(width: double.infinity, height: R.h(context, 68)),
        ],
      ),
    );
  }
}

/// Initials avatar shown next to greeting.
class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'MB';

    return Container(
      width:  R.w(context, 44),
      height: R.w(context, 44),
      decoration: BoxDecoration(
        color:  AppColors.kPrimaryLight,
        shape:  BoxShape.circle,
        border: Border.all(color: AppColors.kPrimary, width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.labelLarge.copyWith(
            color:      AppColors.kPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}