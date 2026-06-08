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
                          onTap: () {
                            controller.resetGroupForm();
                            Get.toNamed(AppRoutes.addGroup);
                          },
                          child: Container(
                            padding: EdgeInsets.all(R.w(context, 8)),
                            decoration: const BoxDecoration(
                              color: AppColors.kPrimaryTint,
                              borderRadius: AppRadius.tile,
                            ),
                            child: Icon(
                              CupertinoIcons.add,
                              color: AppColors.kPrimary,
                              size: R.w(context, 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                controller.groups.isEmpty
                    ? SliverFillRemaining(
                        child: EmptyState(
                          icon: CupertinoIcons.person_3,
                          title: AppStrings.noGroups,
                          subtitle: AppStrings.noGroupsDesc,
                          buttonText: AppStrings.createGroup,
                          onButtonPressed: () {
                            controller.resetGroupForm();
                            Get.toNamed(AppRoutes.addGroup);
                          },
                        ),
                      )
                    : SliverPadding(
                        padding: AppSpacing.horizontalScreen.copyWith(top: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding: EdgeInsets.only(
                                bottom: R.h(context, 12),
                              ),
                              child: _GroupCard(
                                group:      controller.groups[i],
                                index:      i,
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
              height: R.h(context, 130),
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

    // Paid/unpaid progress
    int totalSplits = 0;
    int paidSplits  = 0;
    for (final tx in group.transactions) {
      totalSplits += tx.splitDetails.length;
      paidSplits  += tx.splitDetails.where((s) => s.paid).length;
    }
    final paidPercent = totalSplits > 0
        ? paidSplits / totalSplits
        : 0.0;

    return GestureDetector(
      onTap: () {
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

            // ── Title row ──────────────────────────────────────
            Row(
              children: [
                // Group icon
                Container(
                  width:  R.w(context, 44),
                  height: R.w(context, 44),
                  decoration: const BoxDecoration(
                    gradient: AppColors.kBalanceGradient,
                    borderRadius: AppRadius.tile,
                  ),
                  child: Icon(
                    CupertinoIcons.person_3_fill,
                    color: Colors.white,
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
                // Total + options
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
                    // 3-dot menu
                    GestureDetector(
                      onTap: () => _showOptions(context),
                      child: Icon(
                        CupertinoIcons.ellipsis,
                        size: R.w(context, 18),
                        color: AppColors.kTextHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Gap(R.h(context, 12)),

            // ── Member avatar stack ────────────────────────────
            _MemberAvatarStack(
              members: group.members,
              context: context,
            ),

            Gap(R.h(context, 12)),

            // ── Paid progress bar ──────────────────────────────
            if (totalSplits > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$paidSplits/$totalSplits settled',
                    style: AppTextStyles.labelSmall,
                  ),
                  Text(
                    '${(paidPercent * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: paidPercent >= 1.0
                          ? AppColors.kSuccess
                          : AppColors.kPrimary,
                    ),
                  ),
                ],
              ),
              Gap(R.h(context, 6)),
              ClipRRect(
                borderRadius: AppRadius.pill,
                child: LinearProgressIndicator(
                  value: paidPercent,
                  minHeight: 5,
                  backgroundColor: AppColors.kSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    paidPercent >= 1.0
                        ? AppColors.kSuccess
                        : AppColors.kPrimary,
                  ),
                ),
              ),
              Gap(R.h(context, 12)),
            ],

            const Divider(height: 1, color: AppColors.kDivider),
            Gap(R.h(context, 10)),

            // ── Footer row ─────────────────────────────────────
            Row(
              children: [
                Icon(
                  CupertinoIcons.doc_text,
                  size: R.w(context, 13),
                  color: AppColors.kTextHint,
                ),
                Gap(R.w(context, 4)),
                Text(
                  '${group.transactions.length} expenses',
                  style: AppTextStyles.labelSmall,
                ),
                const Spacer(),
                // Quick add expense
                GestureDetector(
                  onTap: () {
                    controller.resetExpenseForm();
                    controller.selectedGroupId.value = group.id;
                    Get.toNamed(
                      AppRoutes.addGroupTransaction,
                      arguments: {
                        'groupId':    group.id,
                        'groupTitle': group.title,
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 10),
                      vertical:   R.h(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.kPrimaryTint,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.add,
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

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: EdgeInsets.all(R.w(context, 16)),
        decoration: const BoxDecoration(
          color: AppColors.kCard,
          borderRadius: AppRadius.modal,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(R.h(context, 8)),
            Container(
              width: R.w(context, 40),
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.kBorder,
                borderRadius: AppRadius.pill,
              ),
            ),
            Gap(R.h(context, 16)),
            // Edit
            ListTile(
              leading: const Icon(
                CupertinoIcons.pencil,
                color: AppColors.kTextPrimary,
              ),
              title: Text('Edit Group', style: AppTextStyles.bodyMedium),
              onTap: () {
                Get.back();
                controller.startEditGroup(group);
                Get.toNamed(AppRoutes.addGroup);
              },
            ),
            const Divider(height: 1, color: AppColors.kDivider),
            // Delete
            ListTile(
              leading: const Icon(
                CupertinoIcons.trash,
                color: AppColors.kError,
              ),
              title: Text(
                'Delete Group',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.kError,
                ),
              ),
              onTap: () {
                Get.back();
                _confirmDelete(context);
              },
            ),
            Gap(R.h(context, 16)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
        title: Text('Delete Group', style: AppTextStyles.headingSmall),
        content: Text(
          'This will delete the group and all its expenses. This cannot be undone.',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyles.buttonSmall),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteGroup(group.id);
            },
            child: Text(
              'Delete',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.kError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stacked member avatars — shows up to 3 then "+N more"
class _MemberAvatarStack extends StatelessWidget {
  final List<GroupMember> members;
  final BuildContext context;

  const _MemberAvatarStack({
    required this.members,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final visible = members.take(3).toList();
    final extra   = members.length - visible.length;
    const colors  = [
      AppColors.kPrimary,
      AppColors.kInfo,
      AppColors.kWarning,
    ];

    return Row(
      children: [
        SizedBox(
          width: R.w(context, 20.0 * visible.length + 10),
          height: R.w(context, 28),
          child: Stack(
            children: visible.asMap().entries.map((e) {
              final initials = e.value.name.isNotEmpty
                  ? e.value.name.trim().split(' ')
                      .map((w) => w[0]).take(1).join().toUpperCase()
                  : '?';
              return Positioned(
                left: e.key * R.w(context, 20),
                child: Container(
                  width:  R.w(context, 28),
                  height: R.w(context, 28),
                  decoration: BoxDecoration(
                    color:  colors[e.key % colors.length].withValues(alpha: 0.15),
                    shape:  BoxShape.circle,
                    border: Border.all(color: AppColors.kCard, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTextStyles.labelSmall.copyWith(
                        color:      colors[e.key % colors.length],
                        fontSize:   9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (extra > 0) ...[
          Gap(R.w(context, 4)),
          Text(
            '+$extra more',
            style: AppTextStyles.labelSmall,
          ),
        ],
        const Spacer(),
        Text(
          '${members.length} members',
          style: AppTextStyles.labelSmall,
        ),
      ],
    );
  }
}