// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';

/// Controls the bottom navigation tab index.
/// Handles Android back button with exit confirmation on home tab.
class MainController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    if (currentIndex.value == index) return;
    HapticFeedback.selectionClick();
    currentIndex.value = index;
  }

  /// Shows exit confirmation dialog when user presses back on home tab.
  Future<void> onWillPop() async {
    if (currentIndex.value != 0) {
      currentIndex.value = 0;
      return;
    }

    await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Exit MoneyBuddy?',
          style: Get.textTheme.titleMedium,
        ),
        content: Text(
          'Are you sure you want to exit?',
          style: Get.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: Get.theme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text(
              'Exit',
              style: TextStyle(color: Get.theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
