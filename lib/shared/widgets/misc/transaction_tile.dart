// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';

/// Single transaction row shown in home screen and transaction list.
/// Supports swipe-to-delete via [onDelete] and swipe-to-edit via [onEdit].
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
    final isIncome      = type.toLowerCase() == 'income';
    final amountColor   = isIncome ? AppColors.kIncome : AppColors.kExpense;
    final amountText    = AppFormatters.formatTransactionAmount(amount, type);
    final categoryColor = AppColors.categoryColor(category);
    final categoryBg    = AppColors.categoryBg(category);

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: onEdit != null ? 0.4 : 0.2,
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: AppColors.kInfo,
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              borderRadius: const BorderRadius.only(
                topLeft:    Radius.circular(AppRadius.md),
                bottomLeft: Radius.circular(AppRadius.md),
              ),
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: AppColors.kError,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              borderRadius: BorderRadius.only(
                topLeft:     Radius.circular(onEdit != null ? 0 : AppRadius.md),
                bottomLeft:  Radius.circular(onEdit != null ? 0 : AppRadius.md),
                topRight:    const Radius.circular(AppRadius.md),
                bottomRight: const Radius.circular(AppRadius.md),
              ),
            ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: AppSpacing.tilePadding,
          color: AppColors.kCard,
          child: Row(
            children: [
              // Category icon circle
              Container(
                width:  R.w(context, 44),
                height: R.w(context, 44),
                decoration: BoxDecoration(
                  color: categoryBg,
                  borderRadius: AppRadius.tile,
                ),
                child: Icon(
                  _categoryIcon(category),
                  color: categoryColor,
                  size: R.w(context, 20),
                ),
              ),

              Gap(R.w(context, AppSpacing.md)),

              // Title and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
      case 'dining':        return Icons.restaurant_rounded;
      case 'transport':     return Icons.directions_car_rounded;
      case 'shopping':      return Icons.shopping_bag_rounded;
      case 'salary':
      case 'income':        return Icons.account_balance_wallet_rounded;
      case 'bills':
      case 'utilities':     return Icons.receipt_long_rounded;
      case 'health':
      case 'medical':       return Icons.favorite_rounded;
      case 'travel':        return Icons.flight_rounded;
      case 'education':     return Icons.school_rounded;
      case 'entertainment': return Icons.movie_rounded;
      default:              return Icons.category_rounded;
    }
  }
}