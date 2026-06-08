// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';

/// Manages registration form state including live password
/// validation checklist and terms checkbox.
class RegisterController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  final obscureText        = true.obs;
  final hasMinLength       = false.obs;
  final hasUpperLower      = false.obs;
  final hasNumberOrSymbol  = false.obs;
  final isChecked          = false.obs;
  final isLoading          = false.obs;

  final _authService = AuthService();

  void toggleObscure() => obscureText.value = !obscureText.value;

  void onPasswordChanged(String password) {
    hasMinLength.value      = AppValidators.hasMinLength(password);
    hasUpperLower.value     = AppValidators.hasUpperAndLower(password);
    hasNumberOrSymbol.value = AppValidators.hasNumberOrSymbol(password);
  }

  bool get _isPasswordValid =>
      hasMinLength.value &&
      hasUpperLower.value &&
      hasNumberOrSymbol.value;

  Future<void> signUp() async {
    final name     = fullNameController.text.trim();
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill all fields'); return;
    }

    final emailError = AppValidators.validateEmail(email);
    if (emailError != null) { _showError(emailError); return; }

    if (!_isPasswordValid) {
      _showError('Password does not meet requirements'); return;
    }

    if (!isChecked.value) {
      _showError('Please accept the privacy policy'); return;
    }

    isLoading.value = true;
    await _authService.registerUser(
      name: name,
      email: email,
      password: password,
    );
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
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}