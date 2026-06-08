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

            // ── Hero header ────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.kBalanceGradient,
                borderRadius: AppRadius.topBar,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    R.h(context, 36),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.profile,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),

                      Gap(R.h(context, 28)),

                      // Large avatar
                      Obx(() => GestureDetector(
                            onTap: () => _showEditNameSheet(context, controller),
                            child: Stack(
                              children: [
                                Container(
                                  width:  R.w(context, 96),
                                  height: R.w(context, 96),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      width: 2.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      controller.initials,
                                      style: AppTextStyles.headingLarge.copyWith(
                                        color: Colors.white,
                                        fontSize: R.sp(context, 32),
                                      ),
                                    ),
                                  ),
                                ),
                                // Edit badge
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(R.w(context, 6)),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      CupertinoIcons.pencil,
                                      size:  R.w(context, 12),
                                      color: AppColors.kPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end:   const Offset(1, 1),
                          ),

                      Gap(R.h(context, 14)),

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

            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                R.h(context, 24),
                AppSpacing.xxl,
                R.h(context, 100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Account section ────────────────────────────
                  _SectionLabel(label: 'Account'),
                  Gap(R.h(context, 8)),
                  _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon:  CupertinoIcons.person,
                        label: 'Edit Name',
                        onTap: () => _showEditNameSheet(
                            context, controller),
                      ),
                      _SettingsRow(
                        icon:  CupertinoIcons.creditcard,
                        label: AppStrings.setBalance,
                        onTap: () => Get.toNamed(AppRoutes.addBalance),
                      ),
                      _SettingsRow(
                        icon:   CupertinoIcons.lock,
                        label:  AppStrings.changePassword,
                        onTap:  () => _showChangePasswordSheet(
                            context, controller),
                        isLast: true,
                      ),
                    ],
                  ),

                  Gap(R.h(context, 20)),

                  // ── Preferences section ────────────────────────
                  _SectionLabel(label: 'Preferences'),
                  Gap(R.h(context, 8)),
                  _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon:  CupertinoIcons.chart_bar_circle,
                        label: 'Set Monthly Budget',
                        onTap: () => _showBudgetSheet(context, controller),
                      ),
                      _SettingsRow(
                        icon:   CupertinoIcons.arrow_down_doc,
                        label:  AppStrings.exportData,
                        onTap:  controller.exportCsv,
                        isLast: true,
                      ),
                    ],
                  ),

                  Gap(R.h(context, 20)),

                  // ── Session section ────────────────────────────
                  _SectionLabel(label: 'Session'),
                  Gap(R.h(context, 8)),
                  _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon:       CupertinoIcons.square_arrow_right,
                        label:      AppStrings.logout,
                        iconColor:  AppColors.kError,
                        labelColor: AppColors.kError,
                        onTap:      () => _showLogoutSheet(
                            context, controller),
                        isLast:     true,
                      ),
                    ],
                  ),

                  Gap(R.h(context, 20)),

                  // ── Danger zone ────────────────────────────────
                  _SectionLabel(
                    label:      'Danger Zone',
                    labelColor: AppColors.kError,
                  ),
                  Gap(R.h(context, 8)),
                  _SettingsCard(
                    borderColor: AppColors.kError.withValues(alpha: 0.2),
                    children: [
                      _SettingsRow(
                        icon:       CupertinoIcons.trash,
                        label:      'Delete Account',
                        iconColor:  AppColors.kError,
                        labelColor: AppColors.kError,
                        onTap:      () => _showDeleteAccountSheet(
                            context, controller),
                        isLast:     true,
                        showChevron: false,
                      ),
                    ],
                  ),
                ],
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

  // ── Bottom sheets ─────────────────────────────────────────────

  void _showEditNameSheet(
      BuildContext context, ProfileController controller) {
    controller.nameController.text = controller.userName.value;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditNameSheet(controller: controller),
    );
  }

  void _showChangePasswordSheet(
      BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangePasswordSheet(controller: controller),
    );
  }

  void _showBudgetSheet(
      BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BudgetSheet(controller: controller),
    );
  }

  void _showLogoutSheet(
      BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogoutSheet(controller: controller),
    );
  }

  void _showDeleteAccountSheet(
      BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteAccountSheet(controller: controller),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color? labelColor;
  const _SectionLabel({required this.label, this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.labelMedium.copyWith(
        color: labelColor ?? AppColors.kTextHint,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Settings card ─────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final Color? borderColor;
  const _SettingsCard({required this.children, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: borderColor ?? AppColors.kBorder,
          width: 0.8,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(children: children),
    );
  }
}

// ── Settings row ──────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool isLast;
  final bool showChevron;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.isLast       = false,
    this.showChevron  = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDestructive = iconColor == AppColors.kError;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical:   R.h(context, 14),
            ),
            child: Row(
              children: [
                Container(
                  width:  R.w(context, 38),
                  height: R.w(context, 38),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.kErrorBg
                        : AppColors.kPrimaryTint,
                    borderRadius: AppRadius.tile,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.kPrimary,
                    size:  R.w(context, 17),
                  ),
                ),
                Gap(R.w(context, 12)),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: labelColor ?? AppColors.kTextPrimary,
                    ),
                  ),
                ),
                if (showChevron)
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: AppColors.kTextHint,
                    size:  R.w(context, 16),
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: AppSpacing.lg + 38 + 12,
            color: AppColors.kDivider,
          ),
      ],
    );
  }
}

// ── Edit name sheet ───────────────────────────────────────────────

class _EditNameSheet extends StatelessWidget {
  final ProfileController controller;
  const _EditNameSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(R.w(context, 16)),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + R.h(context, 24),
      ),
      decoration: const BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          Gap(R.h(context, 20)),
          Text('Edit Name', style: AppTextStyles.headingSmall),
          Gap(R.h(context, 16)),
          TextField(
            controller: controller.nameController,
            autofocus:  true,
            style:      AppTextStyles.inputValue,
            decoration: InputDecoration(
              hintText: 'Your full name',
              hintStyle: AppTextStyles.inputHint,
              filled:    true,
              fillColor: AppColors.kInputFill,
              border: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: AppColors.kBorder),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(
                  color: AppColors.kBorderActive, width: 1.5),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: AppColors.kBorder),
              ),
            ),
            cursorColor: AppColors.kPrimary,
          ),
          Gap(R.h(context, 20)),
          Obx(() => SizedBox(
                width: double.infinity,
                height: R.h(context, 52),
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.updateName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kPrimary,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.buttonLarge,
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Save', style: AppTextStyles.buttonPrimary),
                ),
              )),
        ],
      ),
    );
  }
}

// ── Change password sheet ─────────────────────────────────────────

class _ChangePasswordSheet extends StatelessWidget {
  final ProfileController controller;
  const _ChangePasswordSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(R.w(context, 16)),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + R.h(context, 24),
      ),
      decoration: const BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.modal,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(),
            Gap(R.h(context, 20)),
            Text('Change Password', style: AppTextStyles.headingSmall),
            Gap(R.h(context, 4)),
            Text(
              'Enter your current password to continue.',
              style: AppTextStyles.bodySmall,
            ),
            Gap(R.h(context, 20)),
            _PasswordField(
              label:      'Current Password',
              controller: controller.currentPasswordController,
              autofocus:  true,
            ),
            Gap(R.h(context, 12)),
            _PasswordField(
              label:      'New Password',
              controller: controller.newPasswordController,
            ),
            Gap(R.h(context, 12)),
            _PasswordField(
              label:      'Confirm New Password',
              controller: controller.confirmPasswordController,
            ),
            Gap(R.h(context, 20)),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: R.h(context, 52),
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kPrimary,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.buttonLarge,
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Update Password',
                            style: AppTextStyles.buttonPrimary),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Budget sheet ──────────────────────────────────────────────────

class _BudgetSheet extends StatelessWidget {
  final ProfileController controller;
  const _BudgetSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(R.w(context, 16)),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + R.h(context, 24),
      ),
      decoration: const BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          Gap(R.h(context, 20)),
          Text('Monthly Budget', style: AppTextStyles.headingSmall),
          Gap(R.h(context, 4)),
          Text(
            'Set a spending limit to track your monthly expenses.',
            style: AppTextStyles.bodySmall,
          ),
          Gap(R.h(context, 20)),
          TextField(
            controller: controller.budgetController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true),
            autofocus: true,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.kTextPrimary,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '₹0',
              hintStyle: AppTextStyles.displayMedium.copyWith(
                color: AppColors.kTextHint),
              filled:    true,
              fillColor: AppColors.kInputFill,
              border: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: AppColors.kBorder),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(
                  color: AppColors.kBorderActive, width: 1.5),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: AppColors.kBorder),
              ),
            ),
            cursorColor: AppColors.kPrimary,
          ),
          Gap(R.h(context, 20)),
          SizedBox(
            width: double.infinity,
            height: R.h(context, 52),
            child: ElevatedButton(
              onPressed: controller.saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.buttonLarge),
              ),
              child: Text('Save Budget',
                  style: AppTextStyles.buttonPrimary),
            ),
          ),
          Gap(R.h(context, 8)),
          Center(
            child: TextButton(
              onPressed: controller.clearBudget,
              child: Text(
                'Clear Budget',
                style: AppTextStyles.buttonSmall.copyWith(
                  color: AppColors.kTextHint),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logout sheet ──────────────────────────────────────────────────

class _LogoutSheet extends StatelessWidget {
  final ProfileController controller;
  const _LogoutSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(R.w(context, 16)),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl, AppSpacing.lg,
        AppSpacing.xxl, R.h(context, 24),
      ),
      decoration: const BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          Gap(R.h(context, 20)),
          Container(
            padding: EdgeInsets.all(R.w(context, 16)),
            decoration: const BoxDecoration(
              color: AppColors.kErrorBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.square_arrow_right,
              color: AppColors.kError,
              size: R.w(context, 28),
            ),
          ),
          Gap(R.h(context, 16)),
          Text('Log out?', style: AppTextStyles.headingSmall),
          Gap(R.h(context, 8)),
          Text(
            'You can log back in anytime.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          Gap(R.h(context, 24)),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: R.h(context, 52),
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.kBorder),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonLarge),
                    ),
                    child: Text('Cancel',
                        style: AppTextStyles.buttonSecondary),
                  ),
                ),
              ),
              Gap(R.w(context, 12)),
              Expanded(
                child: SizedBox(
                  height: R.h(context, 52),
                  child: ElevatedButton(
                    onPressed: controller.logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kError,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonLarge),
                    ),
                    child: Text('Log out',
                        style: AppTextStyles.buttonPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Delete account sheet ──────────────────────────────────────────

class _DeleteAccountSheet extends StatelessWidget {
  final ProfileController controller;
  const _DeleteAccountSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(R.w(context, 16)),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + R.h(context, 24),
      ),
      decoration: const BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.modal,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(),
            Gap(R.h(context, 20)),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(R.w(context, 8)),
                  decoration: const BoxDecoration(
                    color: AppColors.kErrorBg,
                    borderRadius: AppRadius.tile,
                  ),
                  child: Icon(
                    CupertinoIcons.trash,
                    color: AppColors.kError,
                    size: R.w(context, 20),
                  ),
                ),
                Gap(R.w(context, 12)),
                Text('Delete Account',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.kError,
                    )),
              ],
            ),
            Gap(R.h(context, 12)),
            Text(
              'This will permanently delete your account and all your transaction data. This action cannot be undone.',
              style: AppTextStyles.bodySmall,
            ),
            Gap(R.h(context, 20)),
            _PasswordField(
              label:      'Enter your password to confirm',
              controller: controller.deletePasswordController,
              autofocus:  true,
            ),
            Gap(R.h(context, 20)),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: R.h(context, 52),
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kError,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.buttonLarge),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Delete My Account',
                            style: AppTextStyles.buttonPrimary),
                  ),
                )),
            Gap(R.h(context, 8)),
            Center(
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.kTextHint)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width:  R.w(context, 40),
        height: R.h(context, 4),
        decoration: const BoxDecoration(
          color: AppColors.kBorder,
          borderRadius: AppRadius.pill,
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool autofocus;

  const _PasswordField({
    required this.label,
    required this.controller,
    this.autofocus = false,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:  widget.controller,
      autofocus:   widget.autofocus,
      obscureText: _obscure,
      style:       AppTextStyles.inputValue,
      decoration: InputDecoration(
        labelText:  widget.label,
        labelStyle: AppTextStyles.inputLabel,
        filled:     true,
        fillColor:  AppColors.kInputFill,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? CupertinoIcons.eye
                : CupertinoIcons.eye_slash,
            color: AppColors.kTextHint,
            size:  R.w(context, 18),
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.kBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
              color: AppColors.kBorderActive, width: 1.5),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.kBorder),
        ),
      ),
      cursorColor: AppColors.kPrimary,
    );
  }
}