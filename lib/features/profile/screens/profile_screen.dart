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
import '../../../core/theme/app_shadows.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Emerald header with avatar ─────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                ),
                borderRadius: AppRadius.topBar,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    R.h(context, 32),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.profile,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Gap(R.h(context, 24)),
                      Obx(() => Container(
                                width: R.w(context, 80),
                                height: R.w(context, 80),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    controller.initials,
                                    style: AppTextStyles.headingLarge.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )).animate().fadeIn(duration: 300.ms).scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                          ),
                      Gap(R.h(context, 12)),
                      Obx(() => Text(
                            controller.userName.value,
                            style: AppTextStyles.headingMedium.copyWith(
                              color: Colors.white,
                            ),
                          )),
                      Gap(R.h(context, 4)),
                      Obx(() => Text(
                            controller.userEmail.value,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          )),
                      Gap(R.h(context, 8)),
                    ],
                  ),
                ),
              ),
            ),

            // ── Settings list ──────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                R.h(context, 24),
                AppSpacing.xxl,
                R.h(context, 100),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.kCard,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: AppColors.kBorder, width: 0.8),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    _SettingsRow(
                      icon: Icons.account_balance_wallet_rounded,
                      label: AppStrings.setBalance,
                      onTap: () => Get.toNamed(AppRoutes.addBalance),
                    ),
                    const Divider(height: 1, color: AppColors.kDivider),

                    // ── Budget row — NEW ───────────────────────
                    _SettingsRow(
                      icon: Icons.savings_rounded,
                      label: 'Set Monthly Budget',
                      onTap: () => Get.bottomSheet(
                        _BudgetSheet(),
                        backgroundColor: AppColors.kCard,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.bottomSheet,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.kDivider),

                    _SettingsRow(
                      icon: Icons.lock_outline_rounded,
                      label: AppStrings.changePassword,
                      onTap: () => Get.toNamed(AppRoutes.forgot),
                    ),
                    const Divider(height: 1, color: AppColors.kDivider),
                    _SettingsRow(
                      icon: Icons.download_rounded,
                      label: AppStrings.exportData,
                      onTap: controller.exportCsv,
                    ),
                    const Divider(height: 1, color: AppColors.kDivider),
                    _SettingsRow(
                      icon: Icons.logout_rounded,
                      label: AppStrings.logout,
                      iconColor: AppColors.kError,
                      labelColor: AppColors.kError,
                      onTap: controller.showLogoutDialog,
                      isLast: true,
                    ),
                  ],
                ),
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single settings row item.
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: R.h(context, 16),
        ),
        child: Row(
          children: [
            Container(
              width: R.w(context, 40),
              height: R.w(context, 40),
              decoration: BoxDecoration(
                color: iconColor != null
                    ? AppColors.kErrorBg
                    : AppColors.kPrimaryTint,
                borderRadius: AppRadius.tile,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.kPrimary,
                size: R.w(context, 18),
              ),
            ),
            Gap(R.w(context, 12)),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: labelColor ?? AppColors.kTextPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.kTextHint,
              size: R.w(context, 20),
            ),
          ],
        ),
      ),
    );
  }
}

/// Budget bottom sheet — lets user set or update monthly budget.
class _BudgetSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + R.h(context, 32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: R.w(context, 40),
              height: R.h(context, 4),
              decoration: const BoxDecoration(
                color: AppColors.kBorder,
                borderRadius: AppRadius.pill,
              ),
            ),
          ),

          Gap(R.h(context, 20)),

          Text('Set Monthly Budget', style: AppTextStyles.headingSmall),

          Gap(R.h(context, 4)),

          Text(
            'Track your spending against a monthly limit.',
            style: AppTextStyles.bodySmall,
          ),

          Gap(R.h(context, 24)),

          // Amount input
          TextField(
            controller: controller.budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.kTextPrimary,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '₹0',
              hintStyle: AppTextStyles.displayMedium.copyWith(
                color: AppColors.kTextHint,
              ),
              filled: true,
              fillColor: AppColors.kInputFill,
              border: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: AppColors.kBorder),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(
                  color: AppColors.kBorderActive,
                  width: 1.5,
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: AppColors.kBorder),
              ),
            ),
            cursorColor: AppColors.kPrimary,
          ),

          Gap(R.h(context, 20)),

          // Save button
          SizedBox(
            width: double.infinity,
            height: R.h(context, 56),
            child: ElevatedButton(
              onPressed: controller.saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.buttonLarge,
                ),
              ),
              child: Text(
                'Save Budget',
                style: AppTextStyles.buttonPrimary,
              ),
            ),
          ),

          Gap(R.h(context, 8)),

          // Clear budget option
          Center(
            child: TextButton(
              onPressed: () async {
                await controller.clearBudget();
                Get.back();
              },
              child: Text(
                'Clear Budget',
                style: AppTextStyles.buttonSmall.copyWith(
                  color: AppColors.kTextHint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
