// MoneyBuddy
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';

/// Single transaction row — supports swipe-to-edit and swipe-to-delete.
/// Features colored left border by category for premium feel.
class TransactionTile extends StatelessWidget {
  final String title;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.onDelete,
    this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type.toLowerCase() == 'income';
    final amountColor = isIncome ? AppColors.kIncome : AppColors.kExpense;
    final amountText = AppFormatters.formatTransactionAmount(amount, type);
    final categoryColor = AppColors.categoryColor(category);
    final categoryBg = AppColors.categoryBg(category);

    return Slidable(
      endActionPane: (onDelete != null || onEdit != null)
          ? ActionPane(
              motion: const DrawerMotion(),
              extentRatio: onEdit != null ? 0.4 : 0.2,
              children: [
                if (onEdit != null)
                  SlidableAction(
                    onPressed: (_) => onEdit!(),
                    backgroundColor: AppColors.kInfo,
                    foregroundColor: Colors.white,
                    icon: CupertinoIcons.pencil,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.md),
                      bottomLeft: Radius.circular(AppRadius.md),
                    ),
                  ),
                if (onDelete != null)
                  SlidableAction(
                    onPressed: (_) => onDelete!(),
                    backgroundColor: AppColors.kError,
                    foregroundColor: Colors.white,
                    icon: CupertinoIcons.trash,
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(onEdit != null ? 0 : AppRadius.md),
                      bottomLeft:
                          Radius.circular(onEdit != null ? 0 : AppRadius.md),
                      topRight: const Radius.circular(AppRadius.md),
                      bottomRight: const Radius.circular(AppRadius.md),
                    ),
                  ),
              ],
            )
          : null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: AppColors.kCard,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Colored left border ─────────────────────
              Container(
                width: 3,
                height: R.h(context, 68),
                color: categoryColor,
              ),

              // ── Content — Expanded gives bounded width ──
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, AppSpacing.md),
                    vertical: R.h(context, 12),
                  ),
                  child: Row(
                    children: [
                      // Category icon
                      Container(
                        width: R.w(context, 40),
                        height: R.w(context, 40),
                        decoration: BoxDecoration(
                          color: categoryBg,
                          borderRadius: AppRadius.tile,
                        ),
                        child: Icon(
                          _categoryIcon(category),
                          color: categoryColor,
                          size: R.w(context, 18),
                        ),
                      ),

                      Gap(R.w(context, 12)),

                      // Title and date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(R.h(context, 2)),
                            Text(
                              AppFormatters.formatDateTime(date),
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      Gap(R.w(context, 8)),

                      // Amount
                      Text(
                        amountText,
                        style: AppTextStyles.moneyMedium.copyWith(
                          color: amountColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'dining':
        return CupertinoIcons.cart;
      case 'transport':
        return CupertinoIcons.car;
      case 'shopping':
        return CupertinoIcons.bag;
      case 'salary':
      case 'income':
      case 'freelance':
        return CupertinoIcons.briefcase;
      case 'bills':
      case 'utilities':
      case 'rent':
        return CupertinoIcons.doc_text;
      case 'health':
      case 'medical':
        return CupertinoIcons.heart;
      case 'travel':
        return CupertinoIcons.airplane;
      case 'education':
        return CupertinoIcons.book;
      case 'entertainment':
        return CupertinoIcons.film;
      case 'investment':
        return CupertinoIcons.chart_bar_square;
      case 'bonus':
        return CupertinoIcons.star;
      case 'emi':
        return CupertinoIcons.creditcard;
      default:
        return CupertinoIcons.square_grid_2x2;
    }
  }
}
