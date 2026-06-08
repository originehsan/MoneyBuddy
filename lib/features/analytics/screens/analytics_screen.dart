// MoneyBuddy
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/feedback/error_widget.dart';
import '../../../shared/widgets/feedback/shimmer_widget.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

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

                  // ── Header ──────────────────────────────────
                  Padding(
                    padding: AppSpacing.horizontalScreen.copyWith(top: 20),
                    child: Text(
                      AppStrings.analytics,
                      style: AppTextStyles.headingLarge,
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  Gap(R.h(context, 20)),

                  // ── Tab selector ─────────────────────────────
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
                              _TabButton(
                                label: AppStrings.day,
                                index: 0,
                                currentIndex: controller.selectedTab.value,
                                onTap: () => controller.selectedTab.value = 0,
                              ),
                              _TabButton(
                                label: AppStrings.week,
                                index: 1,
                                currentIndex: controller.selectedTab.value,
                                onTap: () => controller.selectedTab.value = 1,
                              ),
                              _TabButton(
                                label: AppStrings.month,
                                index: 2,
                                currentIndex: controller.selectedTab.value,
                                onTap: () => controller.selectedTab.value = 2,
                              ),
                            ],
                          ),
                        ),
                      )),

                  Gap(R.h(context, 20)),

                  // ── Chart card ───────────────────────────────
                  Padding(
                    padding: AppSpacing.horizontalScreen,
                    child: _ChartCard(controller: controller),
                  ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

                  Gap(R.h(context, 20)),

                  // ── Summary card ─────────────────────────────
                  Padding(
                    padding: AppSpacing.horizontalScreen,
                    child: _SummaryCard(controller: controller),
                  ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

                  Gap(R.h(context, 20)),

                  // ── Prediction card ──────────────────────────
                  Obx(() {
                    if (controller.prediction.value == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: AppSpacing.horizontalScreen,
                      child: _PredictionCard(controller: controller),
                    ).animate(delay: 200.ms).fadeIn(duration: 300.ms);
                  }),
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
          ShimmerWidget(width: double.infinity, height: R.h(context, 40)),
          Gap(R.h(context, 20)),
          ShimmerWidget(width: double.infinity, height: R.h(context, 44)),
          Gap(R.h(context, 20)),
          ShimmerWidget(width: double.infinity, height: R.h(context, 220)),
          Gap(R.h(context, 20)),
          ShimmerWidget(width: double.infinity, height: R.h(context, 180)),
          Gap(R.h(context, 20)),
          ShimmerWidget(width: double.infinity, height: R.h(context, 160)),
        ],
      ),
    );
  }
}

/// Chart card — Obx wraps build content so it reacts to tab changes.
class _ChartCard extends StatelessWidget {
  final AnalyticsController controller;

  const _ChartCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data     = controller.currentGraphData;
      final tabIndex = controller.selectedTab.value;

      return Container(
        width: double.infinity,
        height: R.h(context, 220),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.kCard,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.kBorder, width: 0.8),
          boxShadow: AppShadows.card,
        ),
        child: data.isEmpty
            ? Center(
                child: Text(
                  'No data available',
                  style: AppTextStyles.bodySmall,
                ),
              )
            : tabIndex == 1
                ? _buildBarChart(data, context)
                : _buildLineChart(data, context),
      );
    });
  }

  Widget _buildLineChart(List<dynamic> data, BuildContext context) {
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.amount);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.kDivider,
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.kPrimary,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.kPrimary.withValues(
                alpha: AppColors.kChartFillOpacity,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.kPrimaryDeep,
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                AppFormatters.formatCurrencyCompact(s.y),
                AppTextStyles.labelSmall.copyWith(color: Colors.white),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<dynamic> data, BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.kDivider,
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.amount,
                color: AppColors.kPrimary,
                width: R.w(context, 16),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.kPrimaryDeep,
            getTooltipItem: (group, _, rod, __) {
              return BarTooltipItem(
                AppFormatters.formatCurrencyCompact(rod.toY),
                AppTextStyles.labelSmall.copyWith(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final AnalyticsController controller;
  const _SummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final stats = controller.stats.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.kBorder, width: 0.8),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaction Summary', style: AppTextStyles.headingSmall),
          Gap(R.h(context, 16)),
          _SummaryRow(
            label: 'Total Saving',
            value: AppFormatters.formatCurrency(controller.totalSaving),
            valueColor: AppColors.kIncome,
          ),
          _SummaryRow(
            label: 'Total Income',
            value: AppFormatters.formatCurrency(stats?.totalIncome ?? 0),
            valueColor: AppColors.kIncome,
          ),
          _SummaryRow(
            label: 'Total Expense',
            value: AppFormatters.formatCurrency(stats?.totalExpense ?? 0),
            valueColor: AppColors.kExpense,
          ),
          _SummaryRow(
            label: 'Daily avg spend',
            value: AppFormatters.formatCurrencyCompact(
              stats?.averageDailyExpense ?? 0,
            ),
          ),
          _SummaryRow(
            label: 'Weekly avg spend',
            value: AppFormatters.formatCurrencyCompact(
              stats?.averageWeeklyExpense ?? 0,
            ),
          ),
          _SummaryRow(
            label: 'Monthly avg spend',
            value: AppFormatters.formatCurrencyCompact(
              stats?.averageMonthlyExpense ?? 0,
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final AnalyticsController controller;
  const _PredictionCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final p = controller.prediction.value!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        gradient: AppColors.kAnalyticsGradient,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.cardMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 20),
              Gap(R.w(context, 8)),
              Text(
                AppStrings.prediction,
                style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
              ),
            ],
          ),
          Gap(R.h(context, 16)),
          _PredictionRow(
            label: AppStrings.nextDay,
            value: AppFormatters.formatCurrency(p.nextDaySum),
          ),
          _PredictionRow(
            label: AppStrings.nextWeek,
            value: AppFormatters.formatCurrency(p.nextWeekSum),
          ),
          _PredictionRow(
            label: AppStrings.nextMonth,
            value: AppFormatters.formatCurrency(p.nextMonthSum),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: R.h(context, 10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.bodyMedium),
              Text(
                value,
                style: AppTextStyles.moneyMedium.copyWith(
                  color: valueColor ?? AppColors.kTextPrimary,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.kDivider),
      ],
    );
  }
}

class _PredictionRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _PredictionRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: R.h(context, 10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              Text(
                value,
                style: AppTextStyles.moneyMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _TabButton({
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
          padding: EdgeInsets.symmetric(vertical: R.h(context, 8)),
          decoration: BoxDecoration(
            color: isActive ? AppColors.kCard : Colors.transparent,
            borderRadius: AppRadius.pill,
            boxShadow: isActive ? AppShadows.card : [],
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