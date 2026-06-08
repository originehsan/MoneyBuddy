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
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/social_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();

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

              Gap(R.hp(context, 0.03)),

              // Heading
              Text(
                AppStrings.welcomeTo,
                style: AppTextStyles.authHeading,
                maxLines: 2,
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.2, end: 0),

              Gap(R.hp(context, 0.03)),

              // Full name
              AppTextField(
                label: 'Full Name',
                hint: 'Enter your name',
                icon: Icons.person_outline_rounded,
                controller: controller.fullNameController,
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: AppSpacing.lg),

              // Email
              AppTextField(
                label: AppStrings.email,
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
              )
                  .animate(delay: 150.ms)
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: AppSpacing.lg),

              // Password
              AppTextField(
                label: AppStrings.password,
                hint: 'Create a password',
                icon: Icons.lock_outline_rounded,
                controller: controller.passwordController,
                obscureText: controller.obscureText,
                toggleObscureText: controller.toggleObscure,
                onChanged: controller.onPasswordChanged,
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: AppSpacing.md),

              // Password validation checklist
              _ValidationRow(
                text: 'At least 8 characters',
                isValid: controller.hasMinLength,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ValidationRow(
                text: 'Uppercase and lowercase letters',
                isValid: controller.hasUpperLower,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ValidationRow(
                text: 'At least one number or symbol',
                isValid: controller.hasNumberOrSymbol,
              ),

              const SizedBox(height: AppSpacing.lg),
              const Divider(color: AppColors.kDivider),
              const SizedBox(height: AppSpacing.lg),

              // Terms checkbox
              Row(
                children: [
                  Obx(() => Checkbox(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(color: AppColors.kTextHint),
                        activeColor: AppColors.kPrimary,
                        checkColor: Colors.white,
                        value: controller.isChecked.value,
                        onChanged: (v) =>
                            controller.isChecked.value = v ?? false,
                      )),
                  Expanded(
                    child: Text(
                      'I accept the Privacy Policy and Terms of Use',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Sign up button
              Obx(() => PrimaryButton(
                    text: AppStrings.signUp,
                    onPressed: controller.signUp,
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

/// Single password rule row with animated icon.
class _ValidationRow extends StatelessWidget {
  final String text;
  final RxBool isValid;

  const _ValidationRow({required this.text, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Icon(
              isValid.value
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: isValid.value ? AppColors.kSuccess : AppColors.kError,
              size: R.w(context, 18),
            ),
            SizedBox(width: R.w(context, AppSpacing.sm)),
            Expanded(
              child: Text(text, style: AppTextStyles.bodySmall),
            ),
          ],
        ));
  }
}