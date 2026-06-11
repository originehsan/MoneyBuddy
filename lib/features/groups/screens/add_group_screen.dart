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
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/group_controller.dart';

class AddGroupScreen extends StatelessWidget {
  const AddGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupController>();

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.kBalanceGradient,
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
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.resetGroupForm();
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
                    Obx(() => Text(
                          controller.isEditMode.value
                              ? 'Edit Group'
                              : AppStrings.addGroup,
                          style: AppTextStyles.headingSmall
                              .copyWith(color: Colors.white),
                        )),
                    const Spacer(),
                    SizedBox(width: R.w(context, 36)),
                  ],
                ),
              ),
            ),
          ),

          // ── Form ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                R.h(context, 24),
                AppSpacing.xxl,
                R.h(context, 100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: AppStrings.groupName,
                    hint: 'e.g. Goa Trip, Office Lunch',
                    controller: controller.titleController,
                  ).animate().fadeIn(duration: 300.ms),

                  Gap(R.h(context, 16)),

                  AppTextField(
                    label: AppStrings.groupDesc,
                    hint: 'What is this group for?',
                    controller: controller.descController,
                  ).animate(delay: 50.ms).fadeIn(duration: 300.ms),

                  Gap(R.h(context, 20)),

                  Text(AppStrings.members, style: AppTextStyles.inputLabel),
                  Gap(R.h(context, 4)),
                  Text(
                    'Enter names of members',
                    style: AppTextStyles.bodySmall,
                  ),
                  Gap(R.h(context, 10)),

                  // Dynamic member name fields
                  Obx(() => Column(
                        children: List.generate(
                          controller.memberNameControllers.length,
                          (i) => Padding(
                            padding: EdgeInsets.only(bottom: R.h(context, 12)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Member ${i + 1}',
                                    hint: 'e.g. Rahul',
                                    controller:
                                        controller.memberNameControllers[i],
                                  ),
                                ),
                                if (controller.memberNameControllers.length >
                                    1) ...[
                                  Gap(R.w(context, 8)),
                                  GestureDetector(
                                    onTap: () =>
                                        controller.removeMemberField(i),
                                    child: Container(
                                      padding: EdgeInsets.all(R.w(context, 10)),
                                      decoration: const BoxDecoration(
                                        color: AppColors.kErrorBg,
                                        borderRadius: AppRadius.tile,
                                      ),
                                      child: Icon(
                                        CupertinoIcons.minus,
                                        color: AppColors.kError,
                                        size: R.w(context, 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )),

                  // Add member button
                  Obx(() => controller.memberNameControllers.length < 10
                      ? GestureDetector(
                          onTap: controller.addMemberField,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: R.h(context, 12)),
                            decoration: BoxDecoration(
                              color: AppColors.kPrimaryTint,
                              borderRadius: AppRadius.input,
                              border: Border.all(
                                color:
                                    AppColors.kPrimary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.add,
                                  color: AppColors.kPrimary,
                                  size: R.w(context, 16),
                                ),
                                Gap(R.w(context, 6)),
                                Text(
                                  AppStrings.addMember,
                                  style: AppTextStyles.buttonSmall,
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),

                  Gap(R.h(context, 28)),

                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: AppStrings.cancel,
                          onPressed: () {
                            controller.resetGroupForm();
                            Get.back();
                          },
                        ),
                      ),
                      Gap(R.w(context, 12)),
                      Expanded(
                        child: Obx(() => PrimaryButton(
                              text: controller.isEditMode.value
                                  ? AppStrings.save
                                  : 'Create Group',
                              onPressed: controller.submitGroup,
                              isLoading: controller.isSubmitting.value,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
