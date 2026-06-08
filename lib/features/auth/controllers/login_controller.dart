// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';

/// Manages login form state and delegates to [AuthService].
class LoginController extends GetxController {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final obscureText        = true.obs;
  final isLoading          = false.obs;

  final _authService = AuthService();

  void toggleObscure() => obscureText.value = !obscureText.value;

  Future<void> login() async {
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    final emailError = AppValidators.validateEmail(email);
    if (emailError != null) { _showError(emailError); return; }

    final passError = AppValidators.validateRequired(
      password,
      fieldName: 'Password',
    );
    if (passError != null) { _showError(passError); return; }

    isLoading.value = true;
    await _authService.login(email, password);
    isLoading.value = false;
  }

  void _showError(String msg) => Get.snackbar(
    'Error', msg,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.kError,
    colorText: Colors.white,
    duration: const Duration(seconds: 2),
  );

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}