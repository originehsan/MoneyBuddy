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
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final groupTitle = args['groupTitle'] as String? ?? 'Group';
    final groupId = args['groupId'] as String? ?? '';
    final controller = Get.find<GroupController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.kBackground,
        body: Column(
          children: [
            // ── Header ───────────────────────────────────────────
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
                            style: AppTextStyles.headingSmall
                                .copyWith(color: Colors.white),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              // Share button
                              GestureDetector(
                                onTap: () {
                                  final g = controller.groups
                                      .firstWhereOrNull((g) => g.id == groupId);
                                  _shareExpenseSummary(g, groupTitle);
                                },
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
                                  final g = controller.groups
                                      .firstWhereOrNull((g) => g.id == groupId);
                                  controller.resetExpenseForm();
                                  controller.selectedGroupId.value = groupId;
                                  if (g != null) {
                                    controller.initExpenseDefaults(g);
                                  }
                                  Get.toNamed(
                                    AppRoutes.addGroupTransaction,
                                    arguments: {
                                      'groupId': groupId,
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

                      // ── Reactive total ──────────────────────────
                      Obx(() {
                        final g = controller.groups
                            .firstWhereOrNull((g) => g.id == groupId);
                        if (g == null) return const SizedBox.shrink();
                        return Column(
                          children: [
                            Text(
                              AppFormatters.formatCurrency(g.totalExpense),
                              style: AppTextStyles.displayMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Gap(R.h(context, 4)),
                            Text(
                              'Total expenses',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: Colors.white70),
                            ),
                            Gap(R.h(context, 16)),
                          ],
                        );
                      }),

                      // ── 3-tab bar ───────────────────────────────
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
                            Tab(text: 'Balances'),
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

            // ── Tab content — REACTIVE ────────────────────────────
            Expanded(
              child: Obx(() {
                final group =
                    controller.groups.firstWhereOrNull((g) => g.id == groupId);
                if (group == null) {
                  return Center(
                    child: Text('Group not found',
                        style: AppTextStyles.bodyMedium),
                  );
                }
                return TabBarView(
                  children: [
                    _ExpensesTab(
                      group: group,
                      controller: controller,
                      groupId: groupId,
                    ),
                    _BalancesTab(
                      group: group,
                      controller: controller,
                    ),
                    _MembersTab(group: group),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _shareExpenseSummary(GroupModel? group, String groupTitle) {
    if (group == null) return;
    final buffer = StringBuffer();
    buffer.writeln('*$groupTitle — Expense Summary*');
    buffer
        .writeln('Total: ${AppFormatters.formatCurrency(group.totalExpense)}');
    buffer.writeln('');
    for (final expense in group.expenses) {
      buffer.writeln(
          '• ${expense.description}: ${AppFormatters.formatCurrency(expense.amount)}');
      buffer.writeln('  Paid by: ${expense.paidByName}');
      for (final s in expense.settlements) {
        final status = s.paid ? '✓ Paid' : '⏳ Pending';
        buffer.writeln(
            '  ${s.name}: ${AppFormatters.formatCurrencyCompact(s.amount)} ($status)');
      }
    }
    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }
}

// ── Expenses Tab ──────────────────────────────────────────────────

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
    if (group.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.doc_text,
                size: R.w(context, 56), color: AppColors.kTextHint),
            Gap(R.h(context, 16)),
            Text('No expenses yet', style: AppTextStyles.headingSmall),
            Gap(R.h(context, 8)),
            Text('Tap + to add the first expense',
                style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl, R.h(context, 16), AppSpacing.xxl, 100),
      itemCount: group.expenses.length,
      separatorBuilder: (_, __) => Gap(R.h(context, 12)),
      itemBuilder: (_, i) {
        return _ExpenseCard(
          expense: group.expenses[i],
          group: group,
          controller: controller,
          groupId: groupId,
        )
            .animate(delay: Duration(milliseconds: i * 60))
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }
}

// ── Expense Card ──────────────────────────────────────────────────

class _ExpenseCard extends StatelessWidget {
  final GroupExpense expense;
  final GroupModel group;
  final GroupController controller;
  final String groupId;

  const _ExpenseCard({
    required this.expense,
    required this.group,
    required this.controller,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final allPaid = expense.allSettled;

    return Stack(children: [
      Container(
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
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(R.w(context, 8)),
                  decoration: BoxDecoration(
                    color:
                        allPaid ? AppColors.kSuccessBg : AppColors.kPrimaryTint,
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
                        expense.description,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(R.h(context, 2)),
                      Text(
                        'Paid by ${expense.paidByName}  •  '
                        '${AppFormatters.formatDate(expense.date)}',
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // ── Amount + 3-dot side by side ───────────────────
                Text(
                  AppFormatters.formatCurrency(expense.amount),
                  style: AppTextStyles.moneyMedium.copyWith(
                    color: AppColors.kExpense,
                  ),
                ),
              ],
            ),

            // ── Settlements (read-only) ──────────────────────────
            if (expense.settlements.isNotEmpty) ...[
              Gap(R.h(context, 12)),
              const Divider(height: 1, color: AppColors.kDivider),
              Gap(R.h(context, 10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Split details', style: AppTextStyles.labelMedium),
                  Text(
                    '${expense.paidCount}/'
                    '${expense.settlements.length} settled',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: allPaid ? AppColors.kSuccess : AppColors.kTextHint,
                    ),
                  ),
                ],
              ),
              Gap(R.h(context, 8)),
              ...expense.settlements.map(
                (s) => _SettlementRow(settlement: s),
              ),
            ],
          ],
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: GestureDetector(
          onTap: () => _showOptions(context),
          child: Padding(
            padding: EdgeInsets.all(R.w(context, 6)),
            child: Icon(
              CupertinoIcons.ellipsis,
              size: R.w(context, 18),
              color: AppColors.kTextHint,
            ),
          ),
        ),
      ),
    ]);
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: EdgeInsets.all(R.w(context, 16)),
          decoration: const BoxDecoration(
            color: AppColors.kCard,
            borderRadius: AppRadius.modal,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(R.h(context, 8)),
              Center(
                child: Container(
                  width: R.w(context, 40),
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.kBorder,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              Gap(R.h(context, 16)),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(
                    CupertinoIcons.pencil,
                    color: AppColors.kTextPrimary,
                  ),
                  title: Text('Edit Expense', style: AppTextStyles.bodyMedium),
                  onTap: () {
                    Get.back();
                    controller.startEditExpense(expense, group);
                    Get.toNamed(
                      AppRoutes.addGroupTransaction,
                      arguments: {
                        'groupId': groupId,
                        'groupTitle': expense.description,
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: AppColors.kDivider),
              Material(
                color: Colors.transparent,
                child: ListTile(
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
                      groupId: groupId,
                      expenseId: expense.id,
                    );
                  },
                ),
              ),
              Gap(R.h(context, 16)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settlement Row — READ ONLY (no mark paid here) ────────────────

class _SettlementRow extends StatelessWidget {
  final Settlement settlement;

  const _SettlementRow({required this.settlement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(context, 8)),
      child: Row(
        children: [
          Container(
            width: R.w(context, 8),
            height: R.w(context, 8),
            decoration: BoxDecoration(
              color: settlement.paid ? AppColors.kSuccess : AppColors.kWarning,
              shape: BoxShape.circle,
            ),
          ),
          Gap(R.w(context, 8)),
          Expanded(
            child: Text(
              settlement.name.isNotEmpty ? settlement.name : settlement.email,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            AppFormatters.formatCurrencyCompact(settlement.amount),
            style: AppTextStyles.moneySmall,
          ),
          Gap(R.w(context, 8)),
          // Status badge only — no action
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: R.w(context, 8),
              vertical: R.h(context, 3),
            ),
            decoration: BoxDecoration(
              color:
                  settlement.paid ? AppColors.kSuccessBg : AppColors.kWarningBg,
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              settlement.paid ? 'Paid' : 'Pending',
              style: AppTextStyles.labelSmall.copyWith(
                color:
                    settlement.paid ? AppColors.kSuccess : AppColors.kWarning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Balances Tab — with Mark Paid ─────────────────────────────────

class _BalancesTab extends StatelessWidget {
  final GroupModel group;
  final GroupController controller;

  const _BalancesTab({
    required this.group,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final debts = controller.computeBalances(group);

    if (debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.checkmark_seal,
              size: R.w(context, 56),
              color: AppColors.kSuccess,
            ),
            Gap(R.h(context, 16)),
            Text('All settled up!', style: AppTextStyles.headingSmall),
            Gap(R.h(context, 8)),
            Text('No pending amounts', style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl, R.h(context, 16), AppSpacing.xxl, 100),
      itemCount: debts.length,
      separatorBuilder: (_, __) => Gap(R.h(context, 8)),
      itemBuilder: (_, i) {
        final debt = debts[i];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.kCard,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.kBorder, width: 0.8),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              // From avatar
              Container(
                width: R.w(context, 38),
                height: R.w(context, 38),
                decoration: const BoxDecoration(
                  color: AppColors.kErrorBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    debt.from.isNotEmpty ? debt.from[0].toUpperCase() : '?',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.kError,
                    ),
                  ),
                ),
              ),
              Gap(R.w(context, 8)),
              Icon(
                CupertinoIcons.arrow_right,
                size: R.w(context, 16),
                color: AppColors.kTextHint,
              ),
              Gap(R.w(context, 8)),
              // To avatar
              Container(
                width: R.w(context, 38),
                height: R.w(context, 38),
                decoration: const BoxDecoration(
                  color: AppColors.kSuccessBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    debt.to.isNotEmpty ? debt.to[0].toUpperCase() : '?',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.kSuccess,
                    ),
                  ),
                ),
              ),
              Gap(R.w(context, 12)),
              // Who owes whom
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium,
                        children: [
                          TextSpan(
                            text: debt.from,
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.kError),
                          ),
                          const TextSpan(text: ' owes '),
                          TextSpan(
                            text: debt.to,
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.kSuccess),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      AppFormatters.formatCurrency(debt.amount),
                      style: AppTextStyles.moneySmall.copyWith(
                        color: AppColors.kExpense,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Mark paid button ──────────────────────────────
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: i * 50))
            .fadeIn(duration: 250.ms);
      },
    );
  }
}

// ── Members Tab ───────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  final GroupModel group;
  const _MembersTab({required this.group});

  @override
  Widget build(BuildContext context) {
    if (group.members.isEmpty) {
      return Center(
        child: Text('No members', style: AppTextStyles.bodyMedium),
      );
    }

    const colors = [
      AppColors.kPrimary,
      AppColors.kInfo,
      AppColors.kWarning,
      AppColors.kCatEntertain,
    ];

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl, R.h(context, 16), AppSpacing.xxl, 100),
      itemCount: group.members.length,
      separatorBuilder: (_, __) => Gap(R.h(context, 8)),
      itemBuilder: (_, i) {
        final member = group.members[i];
        final color = colors[i % colors.length];
        final isCreator = i == 0;

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
                width: R.w(context, 44),
                height: R.w(context, 44),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    member.initials,
                    style: AppTextStyles.labelLarge.copyWith(color: color),
                  ),
                ),
              ),
              Gap(R.w(context, 12)),
              Expanded(
                child: Text(
                  member.displayName,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCreator)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 8),
                    vertical: R.h(context, 3),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryTint,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    'Creator',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.kPrimary,
                    ),
                  ),
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
