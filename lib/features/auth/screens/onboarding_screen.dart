// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              // ── Logo mark top ──────────────────────
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Container(
                      width: R.w(context, 36),
                      height: R.w(context, 36),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimary,
                        borderRadius: BorderRadius.circular(R.w(context, 10)),
                      ),
                      child: Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: R.sp(context, 20),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Gap(R.w(context, 8)),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Money',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: AppColors.kPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: 'Buddy',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: AppColors.kTextPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const Spacer(),

              // ── Lottie animation ───────────────────
              SizedBox(
                width: R.wp(context, 0.8),
                height: R.h(context, 280),
                child: Lottie.asset(
                  'assets/lottie/onboarding.json',
                  fit: BoxFit.contain,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.account_balance_wallet_rounded,
                    size: R.w(context, 120),
                    color: AppColors.kPrimary,
                  ),
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 500.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              Gap(R.h(context, 32)),

              // ── Title ──────────────────────────────
              Text(
                AppStrings.ob1Title,
                style: AppTextStyles.headingLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              Gap(R.h(context, 12)),

              // ── Description ────────────────────────
              Text(
                AppStrings.ob1Desc,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.kTextSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

              const Spacer(),

              // ── Get Started button ─────────────────
              PrimaryButton(
                text: AppStrings.getStarted,
                onPressed: controller.getStarted,
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              Gap(R.h(context, 24)),
            ],
          ),
        ),
      ),
    );
  }
}
