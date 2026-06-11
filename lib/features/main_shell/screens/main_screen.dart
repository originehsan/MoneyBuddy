// MoneyBuddy
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../home/screens/home_screen.dart';
import '../../transactions/screens/transaction_screen.dart';
import '../../analytics/screens/analytics_screen.dart';
import '../../groups/screens/group_screen.dart';
import '../controllers/main_controller.dart';

/// Root shell — 4-tab bottom navigation.
/// Profile accessed via avatar tap on home screen header.
/// FAB in center triggers add transaction.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionScreen(),
    const AnalyticsScreen(),
    const GroupScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainController>();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await controller.onWillPop();
      },
      child: Obx(() => Scaffold(
            backgroundColor: AppColors.kBackground,
            body: IndexedStack(
              index: controller.currentIndex.value,
              children: _screens,
            ),
            floatingActionButton: const _FAB(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: _BottomNav(controller: controller),
          )),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────

class _FAB extends StatelessWidget {
  const _FAB();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Get.toNamed(AppRoutes.addTransaction);
      },
      backgroundColor: AppColors.kPrimary,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(
        CupertinoIcons.add,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final MainController controller;
  const _BottomNav({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kCard,
        border: const Border(
          top: BorderSide(color: AppColors.kBorder, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomAppBar(
        color: AppColors.kCard,
        elevation: 0,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 64,
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: CupertinoIcons.house,
                    activeIcon: CupertinoIcons.house_fill,
                    label: 'Home',
                    index: 0,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.changeTab(0),
                  ),
                  _NavItem(
                    icon: CupertinoIcons.doc_text,
                    activeIcon: CupertinoIcons.doc_text_fill,
                    label: 'Transactions',
                    index: 1,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.changeTab(1),
                  ),

                  // FAB space
                  const SizedBox(width: 56),

                  _NavItem(
                    icon: CupertinoIcons.chart_bar,
                    activeIcon: CupertinoIcons.chart_bar_fill,
                    label: 'Analytics',
                    index: 2,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.changeTab(2),
                  ),
                  _NavItem(
                    icon: CupertinoIcons.person_3,
                    activeIcon: CupertinoIcons.person_3_fill,
                    label: 'Groups',
                    index: 3,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.changeTab(3),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.kPrimaryTint : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.kPrimary : AppColors.kTextHint,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: isActive
                  ? AppTextStyles.navActive
                  : AppTextStyles.navInactive,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
