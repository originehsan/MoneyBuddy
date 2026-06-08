// MoneyBuddy
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../controllers/profile_controller.dart';

class AddBalanceScreen extends StatelessWidget {
  const AddBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.kBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.kBalanceGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(AppRadius.xxl),
                  bottomRight: Radius.circular(AppRadius.xxl),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.amountController.clear();
                              Get.back();
                            },
                            child: Container(
                              padding: EdgeInsets.all(R.w(context, 8)),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: AppRadius.tile,
                              ),
                              child: Icon(
                                CupertinoIcons.xmark,
                                color: Colors.white,
                                size: R.w(context, 20),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppStrings.setBalance,
                            style: AppTextStyles.headingSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(width: R.w(context, 36)),
                        ],
                      ),

                      Gap(R.h(context, 24)),

                      Text(
                        'Enter your current bank balance',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),

                      Gap(R.h(context, 8)),

                      TextField(
                        controller: controller.amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        autofocus: true,
                        style: AppTextStyles.displayLarge,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '₹0',
                          hintStyle: AppTextStyles.displayLarge.copyWith(
                            color: Colors.white38,
                          ),
                          border: InputBorder.none,
                          filled: false,
                        ),
                        cursorColor: Colors.white,
                      ),

                      Gap(R.h(context, 8)),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),

            Gap(R.h(context, 40)),

            // ── Info text ──────────────────────────────────────
            Padding(
              padding: AppSpacing.horizontalScreen,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.kInfoBg,
                  borderRadius: AppRadius.tile,
                  border: Border.all(
                    color: AppColors.kInfo.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.info_circle,
                      color: AppColors.kInfo,
                      size: R.w(context, 18),
                    ),
                    Gap(R.w(context, 8)),
                    Expanded(
                      child: Text(
                        'This is your manually tracked balance. Update it whenever you check your bank.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.kInfoText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

            Gap(R.h(context, 32)),

            // ── Submit button ──────────────────────────────────
            Padding(
              padding: AppSpacing.horizontalScreen,
              child: Obx(() => PrimaryButton(
                    text:      'Set Balance',
                    onPressed: controller.updateBalance,
                    isLoading: controller.isLoading.value,
                  ))
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.2, end: 0),
            ),

            Gap(R.h(context, 40)),
          ],
        ),
      ),
    );
  }
}