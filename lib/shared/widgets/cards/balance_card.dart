// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:animated_digit/animated_digit.dart';
import 'package:moneybuddy/core/utils/responsive.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/utils/formatters.dart';

/// Hero balance card shown at the top of the home screen.
/// Displays total balance with an animated roll-up effect,
/// plus income and expense summary rows.
class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        gradient: AppColors.kBalanceGradient,
        borderRadius: AppRadius.cardLarge,
        boxShadow: AppShadows.cardMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.kTextOnDarkMuted,
              )),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              // Scale down font for small screens or large amounts
              final fontSize = R.sp(context, 32);
              return AnimatedDigitWidget(
                value: balance,
                textStyle: AppTextStyles.displayLarge.copyWith(
                  fontSize: fontSize,
                ),
                enableSeparator: true,
                fractionDigits: 2,
                prefix: '₹',
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Income',
                  amount: income,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.kPrimaryLight,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatItem(
                  label: 'Expense',
                  amount: expense,
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFFFFCDD2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Income or expense stat row inside the balance card.
class _StatItem extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppRadius.tile,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.kTextOnDarkMuted,
                    )),
                Text(
                  AppFormatters.formatCurrencyCompact(amount),
                  style: AppTextStyles.moneySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
