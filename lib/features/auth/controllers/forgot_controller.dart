// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';

/// Manages forgot password form state.
class ForgotController extends GetxController {
  final emailController = TextEditingController();
  final isLoading       = false.obs;

  final _authService = AuthService();

  Future<void> confirmEmail() async {
    final email = emailController.text.trim();
    final error = AppValidators.validateEmail(email);

    if (error != null) {
      Get.snackbar(
        'Error', error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.kError,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    await _authService.forgotPassword(email: email);
    isLoading.value = false;
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}