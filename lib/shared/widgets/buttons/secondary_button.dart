// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';

/// Outlined secondary button — used for cancel, skip, alternate actions.
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final Color? borderColor;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 56,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: borderColor ?? AppColors.kPrimary,
            width: 1.5,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonLarge,
          ),
          elevation: 0,
        ),
        child: Text(text, style: AppTextStyles.buttonSecondary),
      ),
    );
  }
}