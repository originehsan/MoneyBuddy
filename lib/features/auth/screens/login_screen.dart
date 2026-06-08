// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/social_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.kBackground,
      body: Padding(
        padding: AppSpacing.horizontalScreen,
        child: SingleChildScrollView(
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

              // Heading
              Text(
                AppStrings.welcomeBack,
                style: AppTextStyles.authHeading,
                maxLines: 2,
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 4),

              Text(
                AppStrings.gladToSeeYou,
                style: AppTextStyles.authSubHeading,
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 300.ms),

              Gap(R.hp(context, 0.04)),

              // Email field
              AppTextField(
                label: AppStrings.email,
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
              )
                  .animate(delay: 150.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.lg),

              // Password field
              AppTextField(
                label: AppStrings.password,
                hint: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                controller: controller.passwordController,
                obscureText: controller.obscureText,
                toggleObscureText: controller.toggleObscure,
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.forgot),
                  child: Text(
                    AppStrings.forgotPassword,
                    style: AppTextStyles.buttonSmall,
                  ),
                ),
              ),

              Gap(R.hp(context, 0.05)),

              // Login button
              Obx(() => PrimaryButton(
                    text: AppStrings.signIn,
                    onPressed: controller.login,
                    isLoading: controller.isLoading.value,
                  ))
                  .animate(delay: 250.ms)
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: AppSpacing.lg),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.kDivider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Text(
                      AppStrings.orContinueWith,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.kDivider)),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Social buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialButton(assetPath: AppAssets.facebookLogo),
                  SizedBox(width: R.w(context, AppSpacing.xxxl)),
                  SocialButton(assetPath: AppAssets.googleLogo),
                  SizedBox(width: R.w(context, AppSpacing.xxxl)),
                  SocialButton(assetPath: AppAssets.appleLogo),
                ],
              ),

              const SizedBox(height: AppSpacing.giant),
            ],
          ),
        ),
      ),
    );
  }
}