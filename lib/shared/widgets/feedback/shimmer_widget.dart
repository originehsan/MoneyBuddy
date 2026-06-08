// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';

/// Reusable shimmer placeholder for skeleton loading screens.
/// Wrap any placeholder shape with this widget.
///
/// Example:
///   ShimmerWidget(width: double.infinity, height: 160, radius: 16)
class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.kSurface,
      highlightColor: AppColors.kCard,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}