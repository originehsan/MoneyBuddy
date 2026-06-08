// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Section header row with title on the left and optional "See all" link.
/// Used above transaction lists, stat rows, and group lists.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final String? actionRoute;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.actionRoute,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headingSmall),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap ?? () {
              if (actionRoute != null) Get.toNamed(actionRoute!);
            },
            child: Text(
              actionText!,
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.kPrimary,
              ),
            ),
          ),
      ],
    );
  }
}