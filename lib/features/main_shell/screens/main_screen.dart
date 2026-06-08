// MoneyBuddy
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
import '../../profile/screens/profile_screen.dart';
import '../controllers/main_controller.dart';

/// Root shell screen that holds the 4-tab bottom navigation.
/// FAB in the center triggers add transaction sheet.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionScreen(),
    const AnalyticsScreen(),
    const GroupScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainController>();

    // Force light status bar on main screen
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

/// Floating action button for quick add transaction.
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
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }
}

/// Bottom navigation bar with 4 tabs + center FAB space.
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
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.changeTab(0),
                  ),
                  _NavItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Transactions',
                    index: 1,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.changeTab(1),
                  ),

                  // FAB space
                  const SizedBox(width: 56),

                  _NavItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Analytics',
                    index: 2,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.changeTab(2),
                  ),
                  _NavItem(
                    icon: Icons.group_rounded,
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

/// Single bottom nav item with active/inactive states.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
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
                icon,
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
