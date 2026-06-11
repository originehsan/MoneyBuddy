// MoneyBuddy
import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moneybuddy/core/utils/responsive.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/utils/formatters.dart';

/// Hero balance card shown at the top of the home screen.
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
    final netFlow    = income - expense;
    final isPositive = netFlow >= 0;

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

          // ── Balance label + net flow badge ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Balance',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.kTextOnDarkMuted,
                ),
              ),
              // Net cash flow badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? CupertinoIcons.arrow_up_right
                          : CupertinoIcons.arrow_down_right,
                      color: isPositive
                          ? AppColors.kPrimaryLight
                          : const Color(0xFFFFCDD2),
                      size: 10,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${isPositive ? '+' : ''}${AppFormatters.formatCurrencyCompact(netFlow)}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isPositive
                            ? AppColors.kPrimaryLight
                            : const Color(0xFFFFCDD2),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── Animated balance amount ─────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
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

          // ── Income + Expense row ────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label:  'Income',
                  amount: income,
                  icon:   CupertinoIcons.arrow_down_circle_fill,
                  color:  AppColors.kPrimaryLight,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatItem(
                  label:  'Expense',
                  amount: expense,
                  icon:   CupertinoIcons.arrow_up_circle_fill,
                  color:  const Color(0xFFFFCDD2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
        vertical:   AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppRadius.tile,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.kTextOnDarkMuted,
                  ),
                ),
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