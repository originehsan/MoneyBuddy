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
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/feedback/empty_state.dart';
import '../../../shared/widgets/feedback/error_widget.dart';
import '../../../shared/widgets/feedback/shimmer_widget.dart';
import '../controllers/group_controller.dart';
import '../models/group_model.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupController>();

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) return _buildShimmer(context);
          if (controller.errorMessage.isNotEmpty) {
            return AppErrorWidget(
              message: controller.errorMessage.value,
              onRetry: controller.loadGroups,
            );
          }

          return RefreshIndicator(
            color: AppColors.kPrimary,
            onRefresh: controller.loadGroups,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Header ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.horizontalScreen.copyWith(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.groups,
                          style: AppTextStyles.headingLarge,
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.addGroup),
                          child: Container(
                            padding: EdgeInsets.all(R.w(context, 8)),
                            decoration: const BoxDecoration(
                              color: AppColors.kPrimaryTint,
                              borderRadius: AppRadius.tile,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: AppColors.kPrimary,
                              size: R.w(context, 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Group list or empty ──────────────────────────
                controller.groups.isEmpty
                    ? SliverFillRemaining(
                        child: EmptyState(
                          icon: Icons.group_rounded,
                          title: AppStrings.noGroups,
                          subtitle: AppStrings.noGroupsDesc,
                          buttonText: AppStrings.createGroup,
                          onButtonPressed: () =>
                              Get.toNamed(AppRoutes.addGroup),
                        ),
                      )
                    : SliverPadding(
                        padding:
                            AppSpacing.horizontalScreen.copyWith(top: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding: EdgeInsets.only(
                                bottom: R.h(context, 12),
                              ),
                              child: _GroupCard(
                                group: controller.groups[i],
                                index: i,
                                controller: controller,
                              ),
                            ),
                            childCount: controller.groups.length,
                          ),
                        ),
                      ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: R.h(context, 12)),
            child: ShimmerWidget(
              width: double.infinity,
              height: R.h(context, 120),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final int index;
  final GroupController controller;

  const _GroupCard({
    required this.group,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final totalExpense = group.transactions.fold<double>(
      0, (sum, t) => sum + t.amount,
    );

    return GestureDetector(
      onTap: () {
        // Set selected group and navigate to detail
        controller.selectedGroupId.value = group.id;
        Get.toNamed(
          AppRoutes.groupDetail,
          arguments: {
            'groupId':    group.id,
            'groupTitle': group.title,
            'group':      group,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.kCard,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.kBorder, width: 0.8),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width:  R.w(context, 44),
                  height: R.w(context, 44),
                  decoration: const BoxDecoration(
                    color: AppColors.kPrimaryTint,
                    borderRadius: AppRadius.tile,
                  ),
                  child: Icon(
                    Icons.group_rounded,
                    color: AppColors.kPrimary,
                    size: R.w(context, 20),
                  ),
                ),
                Gap(R.w(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.title,
                        style: AppTextStyles.headingSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(R.h(context, 2)),
                      Text(
                        group.description,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.formatCurrencyCompact(totalExpense),
                      style: AppTextStyles.moneyMedium.copyWith(
                        color: AppColors.kExpense,
                      ),
                    ),
                    Gap(R.h(context, 2)),
                    Text(
                      'total',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ],
            ),

            Gap(R.h(context, 12)),
            const Divider(height: 1, color: AppColors.kDivider),
            Gap(R.h(context, 10)),

            Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  size: R.w(context, 14),
                  color: AppColors.kTextHint,
                ),
                Gap(R.w(context, 4)),
                Text(
                  '${group.members.length} members',
                  style: AppTextStyles.labelSmall,
                ),
                Gap(R.w(context, 16)),
                Icon(
                  Icons.receipt_long_rounded,
                  size: R.w(context, 14),
                  color: AppColors.kTextHint,
                ),
                Gap(R.w(context, 4)),
                Text(
                  '${group.transactions.length} expenses',
                  style: AppTextStyles.labelSmall,
                ),
                const Spacer(),
                // Add expense quick action
                GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.addGroupTransaction,
                    arguments: {
                      'groupId':    group.id,
                      'groupTitle': group.title,
                    },
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 10),
                      vertical: R.h(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.kPrimaryTint,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: R.w(context, 12),
                          color: AppColors.kPrimary,
                        ),
                        Gap(R.w(context, 4)),
                        Text(
                          'Add',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.kPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 80))
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.1, end: 0),
    );
  }
}