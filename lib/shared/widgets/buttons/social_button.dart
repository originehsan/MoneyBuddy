// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';

/// Social login button — shows a single brand logo (Google, Apple, Facebook).
/// Used on login and register screens.
class SocialButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.assetPath,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed?.call();
      },
      child: Container(
        width:  R.w(context, 60),
        height: R.w(context, 60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 14)),
          border: Border.all(color: AppColors.kBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width:  R.w(context, 28),
            height: R.w(context, 28),
          ),
        ),
      ),
    );
  }
}