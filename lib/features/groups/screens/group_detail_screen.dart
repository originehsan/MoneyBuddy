// MoneyBuddy
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/group_controller.dart';
import '../models/group_model.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args       = Get.arguments as Map<String, dynamic>? ?? {};
    final groupTitle = args['groupTitle'] as String? ?? 'Group';
    final group      = args['group']      as GroupModel?;
    final groupId    = args['groupId']    as String? ?? '';
    final controller = Get.find<GroupController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.kBackground,
        body: Column(
          children: [

            // ── Emerald header ───────────────────────────────────
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
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Column(
                    children: [
                      // Back + title + actions
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
                                CupertinoIcons.back,
                                color: Colors.white,
                                size: R.w(context, 18),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            groupTitle,
                            style: AppTextStyles.headingSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              // Share button
                              GestureDetector(
                                onTap: () => _shareExpenseSummary(
                                  group, groupTitle),
                                child: Container(
                                  padding: EdgeInsets.all(R.w(context, 8)),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: AppRadius.tile,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.share,
                                    color: Colors.white,
                                    size: R.w(context, 18),
                                  ),
                                ),
                              ),
                              Gap(R.w(context, 8)),
                              // Add expense button
                              GestureDetector(
                                onTap: () {
                                  controller.resetExpenseForm();
                                  controller.selectedGroupId.value = groupId;
                                  Get.toNamed(
                                    AppRoutes.addGroupTransaction,
                                    arguments: {
                                      'groupId':    groupId,
                                      'groupTitle': groupTitle,
                                    },
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(R.w(context, 8)),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: AppRadius.tile,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.add,
                                    color: Colors.white,
                                    size: R.w(context, 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Gap(R.h(context, 16)),

                      // Total + paid summary
                      if (group != null) ...[
                        Text(
                          AppFormatters.formatCurrency(
                            group.transactions.fold(
                              0.0, (sum, t) => sum + t.amount,
                            ),
                          ),
                          style: AppTextStyles.displayMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Gap(R.h(context, 4)),
                        Text(
                          'Total expenses',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Gap(R.h(context, 16)),
                      ],

                      // Tab bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: AppRadius.pill,
                        ),
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadius.pill,
                          ),
                          labelColor: AppColors.kPrimary,
                          unselectedLabelColor: Colors.white,
                          labelStyle: AppTextStyles.labelLarge,
                          unselectedLabelStyle: AppTextStyles.labelMedium,
                          tabs: const [
                            Tab(text: 'Expenses'),
                            Tab(text: 'Members'),
                          ],
                        ),
                      ),
                      Gap(R.h(context, 12)),
                    ],
                  ),
                ),
              ),
            ),

            // ── Tab content ──────────────────────────────────────
            Expanded(
              child: group == null
                  ? Center(
                      child: Text(
                        'Group not found',
                        style: AppTextStyles.bodyMedium,
                      ),
                    )
                  : TabBarView(
                      children: [
                        _ExpensesTab(
                          group:      group,
                          controller: controller,
                          groupId:    groupId,
                        ),
                        _MembersTab(group: group),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareExpenseSummary(GroupModel? group, String groupTitle) {
    if (group == null) return;
    final total = group.transactions.fold(0.0, (sum, t) => sum + t.amount);
    final buffer = StringBuffer();
    buffer.writeln('$groupTitle — Expense Summary');
    buffer.writeln('Total: ${AppFormatters.formatCurrency(total)}');
    buffer.writeln('');
    for (final tx in group.transactions) {
      buffer.writeln('${tx.description}: ${AppFormatters.formatCurrency(tx.amount)}');
      for (final split in tx.splitDetails) {
        final status = split.paid ? 'Paid' : 'Pending';
        buffer.writeln('  ${split.memberEmail}: ${AppFormatters.formatCurrencyCompact(split.share)} ($status)');
      }
    }
    Share.share(buffer.toString());
  }
}

class _ExpensesTab extends StatelessWidget {
  final GroupModel group;
  final GroupController controller;
  final String groupId;

  const _ExpensesTab({
    required this.group,
    required this.controller,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    if (group.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: R.w(context, 56),
              color: AppColors.kTextHint,
            ),
            Gap(R.h(context, 16)),
            Text('No expenses yet', style: AppTextStyles.headingSmall),
            Gap(R.h(context, 8)),
            Text(
              'Tap + to add the first expense',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl, R.h(context, 16), AppSpacing.xxl, 100,
      ),
      itemCount: group.transactions.length,
      separatorBuilder: (_, __) => Gap(R.h(context, 12)),
      itemBuilder: (_, i) {
        final tx = group.transactions[i];
        return _ExpenseCard(
          transaction: tx,
          groupId:     groupId,
          controller:  controller,
        )
            .animate(delay: Duration(milliseconds: i * 60))
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final GroupTransaction transaction;
  final String groupId;
  final GroupController controller;

  const _ExpenseCard({
    required this.transaction,
    required this.groupId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final paidCount  = transaction.splitDetails.where((s) => s.paid).length;
    final totalCount = transaction.splitDetails.length;
    final allPaid    = paidCount == totalCount && totalCount > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: allPaid
              ? AppColors.kSuccess.withValues(alpha: 0.3)
              : AppColors.kBorder,
          width: 0.8,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(R.w(context, 8)),
                decoration: BoxDecoration(
                  color: allPaid
                      ? AppColors.kSuccessBg
                      : AppColors.kPrimaryTint,
                  borderRadius: AppRadius.tile,
                ),
                child: Icon(
                  allPaid
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.doc_text,
                  color: allPaid ? AppColors.kSuccess : AppColors.kPrimary,
                  size: R.w(context, 18),
                ),
              ),
              Gap(R.w(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(R.h(context, 2)),
                    Text(
                      'by ${transaction.initiatedBy}  •  ${AppFormatters.formatDate(transaction.date)}',
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
                    AppFormatters.formatCurrency(transaction.amount),
                    style: AppTextStyles.moneyMedium.copyWith(
                      color: AppColors.kExpense,
                    ),
                  ),
                  // Options button
                  GestureDetector(
                    onTap: () => _showExpenseOptions(context),
                    child: Icon(
                      CupertinoIcons.ellipsis,
                      size: R.w(context, 16),
                      color: AppColors.kTextHint,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Split details ─────────────────────────────────────
          if (transaction.splitDetails.isNotEmpty) ...[
            Gap(R.h(context, 12)),
            const Divider(height: 1, color: AppColors.kDivider),
            Gap(R.h(context, 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Split details', style: AppTextStyles.labelMedium),
                Text(
                  '$paidCount/$totalCount paid',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: allPaid
                        ? AppColors.kSuccess
                        : AppColors.kTextHint,
                  ),
                ),
              ],
            ),
            Gap(R.h(context, 8)),
            ...transaction.splitDetails.map(
              (split) => _SplitRow(
                split:       split,
                groupId:     groupId,
                expenseId:   transaction.id,
                controller:  controller,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showExpenseOptions(BuildContext context) {
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
            ListTile(
              leading: const Icon(
                CupertinoIcons.pencil,
                color: AppColors.kTextPrimary,
              ),
              title: Text('Edit Expense', style: AppTextStyles.bodyMedium),
              onTap: () {
                Get.back();
                controller.startEditExpense(transaction, groupId);
                Get.toNamed(
                  AppRoutes.addGroupTransaction,
                  arguments: {
                    'groupId':    groupId,
                    'groupTitle': transaction.description,
                  },
                );
              },
            ),
            const Divider(height: 1, color: AppColors.kDivider),
            ListTile(
              leading: const Icon(
                CupertinoIcons.trash,
                color: AppColors.kError,
              ),
              title: Text(
                'Delete Expense',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.kError,
                ),
              ),
              onTap: () {
                Get.back();
                controller.deleteExpense(
                  groupId:   groupId,
                  expenseId: transaction.id,
                );
              },
            ),
            Gap(R.h(context, 16)),
          ],
        ),
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  final SplitDetail split;
  final String groupId;
  final String expenseId;
  final GroupController controller;

  const _SplitRow({
    required this.split,
    required this.groupId,
    required this.expenseId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(context, 8)),
      child: Row(
        children: [
          Container(
            width:  R.w(context, 8),
            height: R.w(context, 8),
            decoration: BoxDecoration(
              color: split.paid
                  ? AppColors.kSuccess
                  : AppColors.kWarning,
              shape: BoxShape.circle,
            ),
          ),
          Gap(R.w(context, 8)),
          Expanded(
            child: Text(
              split.memberEmail,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            AppFormatters.formatCurrencyCompact(split.share),
            style: AppTextStyles.moneySmall,
          ),
          Gap(R.w(context, 8)),
          if (split.paid)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: R.w(context, 8),
                vertical:   R.h(context, 3),
              ),
              decoration: BoxDecoration(
                color: AppColors.kSuccessBg,
                borderRadius: AppRadius.pill,
              ),
              child: Text(
                'Paid',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.kSuccess,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => controller.markAsPaid(
                groupId:     groupId,
                expenseId:   expenseId,
                memberEmail: split.memberEmail,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: R.w(context, 8),
                  vertical:   R.h(context, 3),
                ),
                decoration: BoxDecoration(
                  color: AppColors.kPrimaryTint,
                  borderRadius: AppRadius.pill,
                  border: Border.all(
                    color: AppColors.kPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Mark paid',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.kPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  final GroupModel group;
  const _MembersTab({required this.group});

  @override
  Widget build(BuildContext context) {
    if (group.members.isEmpty) {
      return Center(
        child: Text('No members found', style: AppTextStyles.bodyMedium),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl, R.h(context, 16), AppSpacing.xxl, 100,
      ),
      itemCount: group.members.length,
      separatorBuilder: (_, __) => Gap(R.h(context, 8)),
      itemBuilder: (_, i) {
        final member   = group.members[i];
        final initials = member.name.isNotEmpty
            ? member.name.trim().split(' ')
                .map((w) => w[0]).take(2).join().toUpperCase()
            : '?';
        const colors = [
          AppColors.kPrimary,
          AppColors.kInfo,
          AppColors.kWarning,
          AppColors.kCatEntertain,
        ];
        final color = colors[i % colors.length];

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.kCard,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.kBorder, width: 0.8),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width:  R.w(context, 44),
                height: R.w(context, 44),
                decoration: BoxDecoration(
                  color:  color.withValues(alpha: 0.12),
                  shape:  BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: AppTextStyles.labelLarge.copyWith(color: color),
                  ),
                ),
              ),
              Gap(R.w(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (member.email != member.name) ...[
                      Gap(R.h(context, 2)),
                      Text(
                        member.email,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.person_fill,
                color: AppColors.kTextHint,
                size: R.w(context, 18),
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: i * 50))
            .fadeIn(duration: 250.ms)
            .slideX(begin: 0.05, end: 0);
      },
    );
  }
}