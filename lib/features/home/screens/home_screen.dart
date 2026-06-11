// MoneyBuddy
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:moneybuddy/features/emi/controllers/emi_controller.dart';
import 'package:moneybuddy/features/goal/controllers/goals_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
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
                  // ── Greeting header ──────────────────────────
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
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: () => Get.toNamed(AppRoutes.profile),
                            customBorder: const CircleBorder(),
                            child: _Avatar(name: controller.userName.value),
                          ),
                        ),
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
                      income: controller.stats.value?.totalIncome ?? 0,
                      expense: controller.stats.value?.totalExpense ?? 0,
                    ),
                  )
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0),

                  Gap(R.h(context, 16)),

                  // ── Today's spend card ───────────────────────
                  Obx(() {
                    final today = controller.stats.value?.todaySpend ?? 0;
                    if (today <= 0) return const SizedBox.shrink();
                    return Padding(
                      padding: AppSpacing.horizontalScreen,
                      child: _TodaySpendCard(
                        spent: today,
                        budget: controller.monthlyBudget.value,
                      ),
                    ).animate(delay: 120.ms).fadeIn(duration: 300.ms);
                  }),

                  Gap(R.h(context, 16)),

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
                            icon: CupertinoIcons.sun_max,
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
                            icon: CupertinoIcons.calendar_today,
                            iconColor: AppColors.kInfo,
                            iconBgColor: AppColors.kInfoBg,
                          ),
                        ),
                        Gap(R.w(context, 12)),
                        SizedBox(
                          width: R.w(context, 140),
                          child: StatCard(
                            label: 'Projected',
                            value: AppFormatters.formatCurrencyCompact(
                              controller.stats.value?.averageMonthlyExpense ??
                                  0,
                            ),
                            icon: CupertinoIcons.chart_bar,
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
                    return GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.budget),
                      child: Padding(
                        padding: AppSpacing.horizontalScreen.copyWith(top: 16),
                        child: BudgetProgressBar(
                          spent: controller.stats.value?.totalExpense ?? 0,
                          budget: controller.monthlyBudget.value,
                        ),
                      ),
                    );
                  }),

                  Gap(R.h(context, 20)),

// ── Quick actions — Goals + EMI ──────────────────────────────────
                  Padding(
                    padding: AppSpacing.horizontalScreen,
                    child: Row(
                      children: [
                        Expanded(child: _GoalsMiniCard()),
                        Gap(R.w(context, 12)),
                        Expanded(child: _EmiMiniCard()),
                      ],
                    ),
                  ).animate(delay: 170.ms).fadeIn(duration: 300.ms),

                  Gap(R.h(context, 24)),

// ── Recent transactions ──────────────────────────────────────────
                  Padding(
                    padding: AppSpacing.horizontalScreen,
                    child: SectionHeader(
                      title: AppStrings.recentTx,
                      actionText: AppStrings.seeAll,
                      actionRoute: AppRoutes.transactions,
                    ),
                  ),

                  Gap(R.h(context, 12)),

                  controller.recentTx.isEmpty
                      ? EmptyState(
                          icon: CupertinoIcons.doc_text,
                          title: AppStrings.noTransactions,
                          subtitle: AppStrings.noTxDesc,
                        )
                      : Container(
                          margin: AppSpacing.horizontalScreen,
                          decoration: BoxDecoration(
                            color: AppColors.kCard,
                            borderRadius: AppRadius.card,
                            border: Border.all(
                              color: AppColors.kBorder,
                              width: 0.8,
                            ),
                            boxShadow: AppShadows.card,
                          ),
                          child: ClipRRect(
                            borderRadius: AppRadius.card,
                            child: ListView.separated(
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
                                  title: tx.description,
                                  amount: tx.amount,
                                  type: tx.type,
                                  category: tx.category ?? tx.type,
                                  date: tx.date,
                                )
                                    .animate(delay: (i * 50).ms)
                                    .fadeIn(duration: 250.ms)
                                    .slideX(begin: 0.05, end: 0);
                              },
                            ),
                          ),
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
    return SingleChildScrollView(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            Gap(R.h(context, 20)),
            Row(
              children: [
                ShimmerWidget(
                    width: R.w(context, 120), height: R.h(context, 40)),
                const Spacer(),
                ShimmerWidget(
                    width: R.w(context, 44),
                    height: R.w(context, 44),
                    radius: 22),
              ],
            ),
            Gap(R.h(context, 20)),
            ShimmerWidget(width: double.infinity, height: R.h(context, 160)),
            Gap(R.h(context, 16)),
            ShimmerWidget(width: double.infinity, height: R.h(context, 60)),
            Gap(R.h(context, 16)),
            Row(
              children: [
                Expanded(
                  child: ShimmerWidget(
                      width: double.infinity, height: R.h(context, 110)),
                ),
                Gap(R.w(context, 12)),
                Expanded(
                  child: ShimmerWidget(
                      width: double.infinity, height: R.h(context, 110)),
                ),
                Gap(R.w(context, 12)),
                Expanded(
                  child: ShimmerWidget(
                      width: double.infinity, height: R.h(context, 110)),
                ),
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
      ),
    );
  }
}

// ── Today's Spend Card ─────────────────────────────────────────────

class _TodaySpendCard extends StatelessWidget {
  final double spent;
  final double budget;

  const _TodaySpendCard({required this.spent, required this.budget});

  @override
  Widget build(BuildContext context) {
    final dailyBudget = budget > 0 ? budget / 30 : 0.0;
    final isOverDaily = dailyBudget > 0 && spent > dailyBudget;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: R.w(context, 16),
        vertical: R.h(context, 12),
      ),
      decoration: BoxDecoration(
        color: isOverDaily ? AppColors.kErrorBg : AppColors.kPrimaryTint,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isOverDaily
              ? AppColors.kError.withValues(alpha: 0.3)
              : AppColors.kPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(R.w(context, 8)),
            decoration: BoxDecoration(
              color: isOverDaily
                  ? AppColors.kError.withValues(alpha: 0.1)
                  : AppColors.kPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOverDaily
                  ? CupertinoIcons.exclamationmark_circle
                  : CupertinoIcons.sun_max,
              color: isOverDaily ? AppColors.kError : AppColors.kPrimary,
              size: R.w(context, 18),
            ),
          ),

          Gap(R.w(context, 12)),

          // Label + amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Today\'s spend',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isOverDaily
                        ? AppColors.kExpenseText
                        : AppColors.kPrimaryMid,
                  ),
                ),
                Text(
                  AppFormatters.formatCurrency(spent),
                  style: AppTextStyles.moneyMedium.copyWith(
                    color: isOverDaily ? AppColors.kError : AppColors.kPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Budget remaining
          if (dailyBudget > 0)
            Flexible(
              child: Text(
                isOverDaily
                    ? 'Over limit'
                    : '${AppFormatters.formatCurrencyCompact(dailyBudget - spent)} left',
                style: AppTextStyles.labelSmall.copyWith(
                  color:
                      isOverDaily ? AppColors.kError : AppColors.kTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Avatar ─────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'MB';

    return Container(
      width: R.w(context, 44),
      height: R.w(context, 44),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.kPrimary, width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.kPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Goals Mini Card ───────────────────────────────────────────────

class _GoalsMiniCard extends StatelessWidget {
  const _GoalsMiniCard();

  @override
  Widget build(BuildContext context) {
    // Safe find — controller may not be ready
    GoalsController? ctrl;
    try {
      ctrl = Get.find<GoalsController>();
    } catch (_) {}
    if (ctrl == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.goals),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.kCard,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.kBorder, width: 0.8),
          boxShadow: AppShadows.card,
        ),
        child: Obx(() {
          // Loading state
          if (ctrl!.isLoading.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniCardHeader(
                  icon: CupertinoIcons.star_circle_fill,
                  color: AppColors.kWarning,
                  label: 'Goals',
                ),
                Gap(R.h(context, 8)),
                ShimmerWidget(width: double.infinity, height: R.h(context, 40)),
              ],
            );
          }

          final goals = ctrl.goals;
          final active = goals.where((g) => !g.isCompleted).toList();
          final achieved = goals.where((g) => g.isCompleted).toList();

          // No goals created yet
          if (goals.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniCardHeader(
                  icon: CupertinoIcons.star_circle_fill,
                  color: AppColors.kWarning,
                  label: 'Goals',
                ),
                Gap(R.h(context, 10)),
                Text(
                  'No goals yet',
                  style: AppTextStyles.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap(R.h(context, 4)),
                Text(
                  'Tap to start saving',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            );
          }

          // All goals achieved
          if (active.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniCardHeader(
                  icon: CupertinoIcons.star_circle_fill,
                  color: AppColors.kSuccess,
                  label: 'Goals',
                ),
                Gap(R.h(context, 10)),
                Text(
                  '${achieved.length} achieved!',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.kSuccess,
                  ),
                ),
                Gap(R.h(context, 4)),
                Text(
                  'All goals done 🎉',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            );
          }

          // Show nearest deadline goal
          active.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
          final nearest = active.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniCardHeader(
                icon: CupertinoIcons.star_circle_fill,
                color: AppColors.kWarning,
                label: 'Goals',
              ),
              Gap(R.h(context, 10)),
              Text(
                nearest.title,
                style: AppTextStyles.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(R.h(context, 6)),
              ClipRRect(
                borderRadius: AppRadius.pill,
                child: LinearProgressIndicator(
                  value: nearest.progress,
                  minHeight: 4,
                  backgroundColor: AppColors.kSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.kWarning,
                  ),
                ),
              ),
              Gap(R.h(context, 4)),
              Text(
                nearest.isCompleted
                    ? 'Achieved!'
                    : '${(nearest.progress * 100).toStringAsFixed(0)}%'
                        ' · ${nearest.daysLeft}d left',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.kWarning,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── EMI Mini Card ─────────────────────────────────────────────────

class _EmiMiniCard extends StatelessWidget {
  const _EmiMiniCard();

  @override
  Widget build(BuildContext context) {
    EmiController? ctrl;
    try {
      ctrl = Get.find<EmiController>();
    } catch (_) {}
    if (ctrl == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.emi),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.kCard,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.kBorder, width: 0.8),
          boxShadow: AppShadows.card,
        ),
        child: Obx(() {
          if (ctrl!.isLoading.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniCardHeader(
                  icon: CupertinoIcons.creditcard_fill,
                  color: AppColors.kInfo,
                  label: 'EMI',
                ),
                Gap(R.h(context, 8)),
                ShimmerWidget(width: double.infinity, height: R.h(context, 40)),
              ],
            );
          }

          final emis = ctrl.emis;
          final active = emis.where((e) => !e.isCompleted).toList();

          // No EMIs added
          if (emis.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniCardHeader(
                  icon: CupertinoIcons.creditcard_fill,
                  color: AppColors.kInfo,
                  label: 'EMI',
                ),
                Gap(R.h(context, 10)),
                Text(
                  'No EMIs yet',
                  style: AppTextStyles.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap(R.h(context, 4)),
                Text(
                  'Tap to track loans',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            );
          }

          // All EMIs completed — hide card
          if (active.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniCardHeader(
                  icon: CupertinoIcons.creditcard_fill,
                  color: AppColors.kSuccess,
                  label: 'EMI',
                ),
                Gap(R.h(context, 10)),
                Text(
                  'All paid off!',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.kSuccess,
                  ),
                ),
                Gap(R.h(context, 4)),
                Text(
                  'No active loans',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            );
          }

          // Show next due EMI
          active.sort((a, b) => a.daysUntilDue.compareTo(b.daysUntilDue));
          final next = active.first;
          final days = next.daysUntilDue;
          final isOverdue = days < 0;
          final isDueSoon = days >= 0 && days <= 7;
          final statusColor = isOverdue
              ? AppColors.kError
              : isDueSoon
                  ? AppColors.kWarning
                  : AppColors.kInfo;
          final statusText = isOverdue
              ? 'Overdue ${(-days)}d'
              : days == 0
                  ? 'Due today'
                  : 'Due in ${days}d';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniCardHeader(
                icon: CupertinoIcons.creditcard_fill,
                color: statusColor,
                label: 'EMI',
              ),
              Gap(R.h(context, 10)),
              Text(
                next.name,
                style: AppTextStyles.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(R.h(context, 4)),
              Text(
                '${AppFormatters.formatCurrencyCompact(next.emiAmount)}/mo',
                style: AppTextStyles.moneySmall.copyWith(
                  color: AppColors.kTextPrimary,
                ),
              ),
              Gap(R.h(context, 4)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: R.w(context, 6),
                  vertical: R.h(context, 2),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Mini Card Header ──────────────────────────────────────────────

class _MiniCardHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _MiniCardHeader({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: R.w(context, 16)),
        Gap(R.w(context, 6)),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: color),
        ),
        const Spacer(),
        Icon(
          CupertinoIcons.chevron_right,
          size: R.w(context, 12),
          color: AppColors.kTextHint,
        ),
      ],
    );
  }
}
