// MoneyBuddy
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/utils/formatters.dart';

/// Monthly budget progress bar shown on the home screen.
class BudgetProgressBar extends StatelessWidget {
  final double spent;
  final double budget;

  const BudgetProgressBar({
    super.key,
    required this.spent,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final percent  = budget > 0
        ? (spent / budget).clamp(0.0, 1.0)
        : 0.0;
    final isWarn   = percent >= 0.8 && percent < 1.0;
    final isOver   = percent >= 1.0;
    final barColor = isOver
        ? AppColors.kError
        : isWarn
            ? AppColors.kWarning
            : AppColors.kPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Monthly Budget', style: AppTextStyles.labelLarge),
            Text(
              '${AppFormatters.formatCurrencyCompact(spent)} / '
              '${AppFormatters.formatCurrencyCompact(budget)}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.pill,
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: AppColors.kSurface,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        if (isWarn || isOver) ...[
          const SizedBox(height: 4),
          Text(
            isOver
                ? 'Budget exceeded!'
                : 'You have used '
                  '${(percent * 100).toStringAsFixed(0)}% of your budget',
            style: AppTextStyles.labelSmall.copyWith(color: barColor),
          ),
        ],
      ],
    );
  }
}