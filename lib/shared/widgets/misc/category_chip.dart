// MoneyBuddy
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';

/// Colored category pill used on transaction tiles and filter rows.
/// Color is automatically derived from the category name.
class CategoryChip extends StatelessWidget {
  final String category;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(category);
    final bgColor = selected ? color : AppColors.categoryBg(category);
    final textColor = selected ? Colors.white : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          category.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: textColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
