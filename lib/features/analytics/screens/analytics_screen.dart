// MoneyBuddy
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
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
import '../../../core/theme/app_shadows.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/feedback/error_widget.dart';
import '../../../shared/widgets/feedback/shimmer_widget.dart';
import '../controllers/analytics_controller.dart';
import '../models/prediction_model.dart';

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

                  // ── Category breakdown ────────────────────────
                  Obx(() {
                    if (controller.categoryBreakdown.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: AppSpacing.horizontalScreen,
                      child: _CategoryCard(controller: controller),
                    ).animate(delay: 160.ms).fadeIn(duration: 300.ms);
                  }),

                  Gap(R.h(context, 20)),

                  // ── Smart Insights ───────────────────────────
                  Obx(() {
                    if (controller.smartInsights.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: AppSpacing.horizontalScreen,
                      child: _SmartInsightsCard(controller: controller),
                    ).animate(delay: 175.ms).fadeIn(duration: 300.ms);
                  }),

                  Gap(R.h(context, 20)),

                  // ── Spending Forecast ─────────────────────────
                  Obx(() {
                    if (!controller.shouldShowPrediction) {
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
    return SingleChildScrollView(
      child: Padding(
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
            ShimmerWidget(width: double.infinity, height: R.h(context, 200)),
            Gap(R.h(context, 20)),
            ShimmerWidget(width: double.infinity, height: R.h(context, 180)),
            Gap(R.h(context, 20)),
            ShimmerWidget(width: double.infinity, height: R.h(context, 160)),
            Gap(R.h(context, 20)),
            ShimmerWidget(width: double.infinity, height: R.h(context, 140)),
          ],
        ),
      ),
    );
  }
}

// ── Chart Card ────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final AnalyticsController controller;
  const _ChartCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.currentGraphData;
      final tabIndex = controller.selectedTab.value;

      return Container(
        width: double.infinity,
        height: R.h(context, 240),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.kCard,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.kBorder, width: 0.8),
          boxShadow: AppShadows.card,
        ),
        child: data.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.chart_bar,
                      size: R.w(context, 32),
                      color: AppColors.kTextHint,
                    ),
                    Gap(R.h(context, 8)),
                    Text(
                      'No data yet',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              )
            : tabIndex == 0
                ? _buildLineChart(data, context) // Day = line
                : _buildBarChart(data, context), // Week + Month = bar
      );
    });
  }

  Widget _buildLineChart(List<dynamic> data, BuildContext context) {
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.amount);
    }).toList();

    final maxVal = data.isEmpty
        ? 0.0
        : data.map((d) => d.amount as double).reduce((a, b) => a > b ? a : b);
    final maxY = maxVal <= 0 ? 500.0 : maxVal * 1.2;
    final yInterval = _niceInterval(maxY);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.kDivider,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          // Y axis — left
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  _compactAmount(value),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 9,
                    color: AppColors.kTextHint,
                  ),
                );
              },
            ),
          ),
          // X axis — bottom
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                final label = data[index].label as String;
                // Day: show only 12 AM, 6 AM, 12 PM, 6 PM
                final hour = int.tryParse(label.split(':').first) ?? -1;
                if (hour != -1 && hour % 6 != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    hour == 0
                        ? '12A'
                        : hour == 6
                            ? '6A'
                            : hour == 12
                                ? '12P'
                                : hour == 18
                                    ? '6P'
                                    : label,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 9,
                      color: AppColors.kTextHint,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.kPrimary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) {
                // Only show dot on max value
                final maxSpot = spots.reduce((a, b) => a.y > b.y ? a : b);
                return spot.x == maxSpot.x && spot.y > 0;
              },
              getDotPainter: (spot, pct, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.kPrimary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.kPrimary.withValues(alpha: 0.25),
                  AppColors.kPrimary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.kPrimaryDeep,
            tooltipRoundedRadius: 8,
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
    final maxY = data.isEmpty
        ? 100.0
        : data.map((d) => d.amount as double).reduce((a, b) => a > b ? a : b) *
            1.2;
    final yInterval = _niceInterval(maxY);

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.kDivider,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          // Y axis
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  _compactAmount(value),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 9,
                    color: AppColors.kTextHint,
                  ),
                );
              },
            ),
          ),
          // X axis
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                // Shorten "Week 1" → "W1"
                final raw = data[index].label as String;
                final label =
                    raw.startsWith('Week ') ? 'W${raw.split(' ').last}' : raw;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 9,
                      color: AppColors.kTextHint,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          final isMax = e.value.amount ==
              data.map((d) => d.amount).reduce((a, b) => a > b ? a : b);
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.amount <= 0 ? 2.0 : e.value.amount,
                width: data.length <= 4 ? R.w(context, 32) : R.w(context, 20),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isMax
                      ? [
                          AppColors.kPrimary,
                          AppColors.kPrimary.withValues(alpha: 0.6),
                        ]
                      : [
                          AppColors.kPrimary.withValues(alpha: 0.7),
                          AppColors.kPrimary.withValues(alpha: 0.3),
                        ],
                ),
              ),
            ],
          );
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.kPrimaryDeep,
            tooltipRoundedRadius: 8,
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

  /// Compute a clean interval for Y axis from max value.
  double _niceInterval(double maxY) {
    if (maxY <= 0) return 100;
    final rough = maxY / 4;
    final magnitude =
        (rough == 0) ? 1 : pow(10, (log(rough) / log(10)).floor()).toInt();
    final normalized = rough / magnitude;
    double nice;
    if (normalized < 1.5) {
      nice = 1;
    } else if (normalized < 3) {
      nice = 2;
    } else if (normalized < 7) {
      nice = 5;
    } else {
      nice = 10;
    }
    return (nice * magnitude).toDouble();
  }

  /// Format Y axis value compactly.
  String _compactAmount(double value) {
    if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(0)}L';
    if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(0)}k';
    return '₹${value.toStringAsFixed(0)}';
  }
}

// ── Summary Card ──────────────────────────────────────────────────

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
          Text('This Month', style: AppTextStyles.headingSmall),
          Gap(R.h(context, 16)),
          _SummaryRow(
            icon: CupertinoIcons.arrow_down_circle_fill,
            iconColor: AppColors.kIncome,
            label: 'Total Income',
            value: AppFormatters.formatCurrency(stats?.totalIncome ?? 0),
            valueColor: AppColors.kIncome,
          ),
          _SummaryRow(
            icon: CupertinoIcons.arrow_up_circle_fill,
            iconColor: AppColors.kExpense,
            label: 'Total Expense',
            value: AppFormatters.formatCurrency(stats?.totalExpense ?? 0),
            valueColor: AppColors.kExpense,
          ),
          _SummaryRow(
            icon: CupertinoIcons.briefcase_fill,
            iconColor: AppColors.kPrimary,
            label: 'Net Savings',
            value: AppFormatters.formatCurrency(controller.totalSaving),
            valueColor: controller.totalSaving >= 0
                ? AppColors.kIncome
                : AppColors.kExpense,
          ),
          _SummaryRow(
            icon: CupertinoIcons.sun_max_fill,
            iconColor: AppColors.kInfo,
            label: 'Daily avg',
            value: AppFormatters.formatCurrencyCompact(
                stats?.averageDailyExpense ?? 0),
          ),
          _SummaryRow(
            icon: CupertinoIcons.calendar_today,
            iconColor: AppColors.kWarning,
            label: 'Weekly avg',
            value: AppFormatters.formatCurrencyCompact(
                stats?.averageWeeklyExpense ?? 0),
          ),
          _SummaryRow(
            icon: CupertinoIcons.chart_bar_fill,
            iconColor: AppColors.kCatEntertain,
            label: 'Monthly projection',
            value: AppFormatters.formatCurrencyCompact(
                stats?.averageMonthlyExpense ?? 0),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ── Category Breakdown Card ───────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final AnalyticsController controller;
  const _CategoryCard({required this.controller});

  // Category colors for pie chart segments
  static const _segmentColors = [
    AppColors.kPrimary,
    AppColors.kInfo,
    AppColors.kWarning,
    AppColors.kCatEntertain,
    AppColors.kExpense,
  ];

  @override
  Widget build(BuildContext context) {
    final categories = controller.topCategories;
    final total = categories.fold(0.0, (acc, e) => acc + e.value);

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
          Text('Spending by Category', style: AppTextStyles.headingSmall),
          Gap(R.h(context, 20)),

          // ── Pie chart + legend ──────────────────────────────
          Row(
            children: [
              // Pie chart
              SizedBox(
                width: R.w(context, 120),
                height: R.w(context, 120),
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: R.w(context, 28),
                    sections: categories.asMap().entries.map((e) {
                      final color =
                          _segmentColors[e.key % _segmentColors.length];
                      final pct =
                          total > 0 ? (e.value.value / total * 100) : 0.0;
                      return PieChartSectionData(
                        color: color,
                        value: e.value.value,
                        title: '${pct.toStringAsFixed(0)}%',
                        radius: R.w(context, 30),
                        titleStyle: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: R.sp(context, 8),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Gap(R.w(context, 20)),

              // Legend
              Expanded(
                child: Column(
                  children: categories.asMap().entries.map((e) {
                    final color = _segmentColors[e.key % _segmentColors.length];
                    final pct = total > 0 ? (e.value.value / total * 100) : 0.0;
                    return Padding(
                      padding: EdgeInsets.only(bottom: R.h(context, 8)),
                      child: Row(
                        children: [
                          Container(
                            width: R.w(context, 10),
                            height: R.w(context, 10),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Gap(R.w(context, 8)),
                          Expanded(
                            child: Text(
                              e.value.key,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          Gap(R.h(context, 16)),
          const Divider(height: 1, color: AppColors.kDivider),
          Gap(R.h(context, 12)),

          // ── Category rows ───────────────────────────────────
          ...categories.asMap().entries.map((e) {
            final color = _segmentColors[e.key % _segmentColors.length];
            final pct = total > 0 ? (e.value.value / total) : 0.0;
            return Padding(
              padding: EdgeInsets.only(bottom: R.h(context, 10)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.value.key,
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        AppFormatters.formatCurrencyCompact(e.value.value),
                        style: AppTextStyles.moneySmall.copyWith(
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  Gap(R.h(context, 4)),
                  ClipRRect(
                    borderRadius: AppRadius.pill,
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 4,
                      backgroundColor: AppColors.kSurface,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Smart Insights Card ───────────────────────────────────────────

class _SmartInsightsCard extends StatelessWidget {
  final AnalyticsController controller;
  const _SmartInsightsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              const Icon(
                CupertinoIcons.lightbulb,
                color: AppColors.kWarning,
                size: 18,
              ),
              Gap(R.w(context, 8)),
              Text('Smart Insights', style: AppTextStyles.headingSmall),
            ],
          ),
          Gap(R.h(context, 12)),
          ...controller.smartInsights.map(
            (insight) => _InsightRow(insight: insight),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final SmartInsight insight;
  const _InsightRow({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(context, 12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(R.w(context, 6)),
            decoration: BoxDecoration(
              color: insight.isWarning
                  ? AppColors.kWarningBg
                  : AppColors.kSuccessBg,
              borderRadius: AppRadius.tile,
            ),
            child: Icon(
              insight.icon,
              color:
                  insight.isWarning ? AppColors.kWarning : AppColors.kSuccess,
              size: R.w(context, 16),
            ),
          ),
          Gap(R.w(context, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title, style: AppTextStyles.labelLarge),
                Gap(R.h(context, 2)),
                Text(insight.description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Prediction Card ───────────────────────────────────────────────

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
              const Icon(
                CupertinoIcons.waveform_path_ecg,
                color: Colors.white,
                size: 20,
              ),
              Gap(R.w(context, 8)),
              Text(
                'Spending Forecast',
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              _ConfidenceBadge(confidence: p.confidence),
            ],
          ),
          Gap(R.h(context, 4)),
          Text(
            controller.predictionSubtitle,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white60,
            ),
          ),
          Gap(R.h(context, 16)),
          _PredictionRow(
            icon: CupertinoIcons.sun_max,
            label: 'Tomorrow',
            value: AppFormatters.formatCurrency(p.nextDaySum),
          ),
          _PredictionRow(
            icon: CupertinoIcons.calendar_today,
            label: 'Next 7 days',
            value: AppFormatters.formatCurrency(p.nextWeekSum),
          ),
          _PredictionRow(
            icon: CupertinoIcons.calendar,
            label: 'Next 30 days',
            value: AppFormatters.formatCurrency(p.nextMonthSum),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final PredictionConfidence confidence;
  const _ConfidenceBadge({required this.confidence});

  Color get _color {
    switch (confidence) {
      case PredictionConfidence.high:
        return const Color(0xFF22C55E);
      case PredictionConfidence.medium:
        return const Color(0xFFF59E0B);
      case PredictionConfidence.low:
        return const Color(0xFFFF6B35);
      default:
        return Colors.white38;
    }
  }

  String get _label {
    switch (confidence) {
      case PredictionConfidence.high:
        return 'High';
      case PredictionConfidence.medium:
        return 'Medium';
      case PredictionConfidence.low:
        return 'Low';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppRadius.pill,
        border: Border.all(
          color: _color.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            _label,
            style: AppTextStyles.labelSmall
                .copyWith(color: Colors.white, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _SummaryRow({
    required this.icon,
    required this.iconColor,
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
            children: [
              Icon(icon, color: iconColor, size: R.w(context, 16)),
              Gap(R.w(context, 10)),
              Expanded(
                child: Text(label, style: AppTextStyles.bodyMedium),
              ),
              Text(
                value,
                style: AppTextStyles.moneyMedium.copyWith(
                  color: valueColor ?? AppColors.kTextPrimary,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            color: AppColors.kDivider,
            indent: 26,
          ),
      ],
    );
  }
}

class _PredictionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _PredictionRow({
    required this.icon,
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
            children: [
              Icon(icon, color: Colors.white60, size: R.w(context, 16)),
              Gap(R.w(context, 8)),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
              Text(
                value,
                style: AppTextStyles.moneyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
      ],
    );
  }
}

// ── Tab Button ────────────────────────────────────────────────────

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
