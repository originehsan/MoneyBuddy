// MoneyBuddy
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
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.kBackground,
      body: Column(
        children: [
          // ── Emerald header ────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF059669), Color(0xFF047857)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.xxl),
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
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(R.w(context, 8)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: AppRadius.tile,
                            ),
                            child: Icon(
                              Icons.close_rounded,
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

                    Gap(R.h(context, 20)),

                    Text(
                      'Account Balance',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),

                    Gap(R.h(context, 8)),

                    // Amount input
                    TextField(
                      controller: controller.amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
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

          const Spacer(),

          // ── Submit button ─────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              R.h(context, 40),
            ),
            child: Obx(() => PrimaryButton(
                      text: 'Set Balance',
                      onPressed: controller.updateBalance,
                      isLoading: controller.isLoading.value,
                    ))
                .animate(delay: 200.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.2, end: 0),
          ),
        ],
      ),
    );
  }
}
