// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';

class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.kPrimary.withValues(alpha: 0.06),
              AppColors.kBackground,
              AppColors.kBackground,
              AppColors.kPrimary.withValues(alpha: 0.04),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [

                const Spacer(flex: 2),

                // ── Logo mark ──────────────────────
                Container(
                  width:  R.w(context, 88),
                  height: R.w(context, 88),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimary,
                    borderRadius: BorderRadius.circular(R.w(context, 24)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kPrimary.withValues(alpha: 0.3),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: R.sp(context, 44),
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                Gap(R.h(context, 24)),

                // ── App name ───────────────────────
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Money',
                        style: AppTextStyles.headingLarge.copyWith(
                          color: AppColors.kPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: R.sp(context, 32),
                        ),
                      ),
                      TextSpan(
                        text: 'Buddy',
                        style: AppTextStyles.headingLarge.copyWith(
                          color: AppColors.kTextPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: R.sp(context, 32),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                Gap(R.h(context, 8)),

                // ── Tagline ────────────────────────
                Text(
                  AppStrings.appTagline,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.kTextHint,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms),

                const Spacer(flex: 3),

                // ── Feature highlights ─────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FeatureChip(
                      icon: Icons.receipt_long_rounded,
                      label: 'Track',
                    ),
                    Gap(R.w(context, 12)),
                    _FeatureChip(
                      icon: Icons.pie_chart_rounded,
                      label: 'Analyse',
                    ),
                    Gap(R.w(context, 12)),
                    _FeatureChip(
                      icon: Icons.group_rounded,
                      label: 'Split',
                    ),
                  ],
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms),

                const Spacer(flex: 2),

                // ── Login button ───────────────────
                PrimaryButton(
                  text: AppStrings.login,
                  onPressed: () => Get.toNamed(AppRoutes.login),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.2, end: 0),

                Gap(R.h(context, AppSpacing.lg)),

                // ── Register button ────────────────
                SecondaryButton(
                  text: AppStrings.register,
                  onPressed: () => Get.toNamed(AppRoutes.register),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.2, end: 0),

                Gap(R.h(context, 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small feature highlight chip shown on welcome screen.
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.w(context, 16),
        vertical: R.h(context, 10),
      ),
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: BorderRadius.circular(R.w(context, 20)),
        border: Border.all(color: AppColors.kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.kPrimary,
            size: R.w(context, 16),
          ),
          Gap(R.w(context, 6)),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}