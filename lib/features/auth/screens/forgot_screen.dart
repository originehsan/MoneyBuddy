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
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/forgot_controller.dart';

class ForgotScreen extends StatelessWidget {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.kBackground,
      body: Padding(
        padding: AppSpacing.horizontalScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(R.hp(context, 0.06)),

            // Back button
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width:  R.w(context, 40),
                height: R.w(context, 40),
                decoration: BoxDecoration(
                  color: AppColors.kSurface,
                  borderRadius: BorderRadius.circular(R.w(context, 12)),
                  border: Border.all(color: AppColors.kBorder),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: R.w(context, 16),
                  color: AppColors.kTextPrimary,
                ),
              ),
            ),

            Gap(R.hp(context, 0.036)),

            Text(
              AppStrings.forgotPassword,
              style: AppTextStyles.authHeading,
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.2, end: 0),

            Gap(R.hp(context, 0.012)),

            Text(
              "Don't worry! Enter the email linked with your account.",
              style: AppTextStyles.authSubHeading,
              maxLines: 2,
            )
                .animate(delay: 100.ms)
                .fadeIn(duration: 300.ms),

            Gap(R.hp(context, 0.05)),

            AppTextField(
              label: AppStrings.email,
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
            )
                .animate(delay: 150.ms)
                .fadeIn(duration: 300.ms),

            Gap(R.hp(context, 0.04)),

            Obx(() => PrimaryButton(
                  text: AppStrings.sendCode,
                  onPressed: controller.confirmEmail,
                  isLoading: controller.isLoading.value,
                ))
                .animate(delay: 200.ms)
                .fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}