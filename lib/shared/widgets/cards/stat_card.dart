// MoneyBuddy
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/utils/responsive.dart';

/// Small stat card for dashboard metrics like daily/weekly/monthly averages.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.w(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.kBorder, width: 0.8),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(R.w(context, 6)),
            decoration: BoxDecoration(
              color: iconBgColor ?? AppColors.kPrimaryTint,
              borderRadius: AppRadius.tile,
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.kPrimary,
              size: R.w(context, 16),
            ),
          ),
          SizedBox(height: R.h(context, 6)),
          Text(
            value,
            style: AppTextStyles.moneyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: R.h(context, 2)),
          Text(
            label,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}