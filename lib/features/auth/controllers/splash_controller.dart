// MoneyBuddy
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/routes/app_routes.dart';

/// Controls splash screen — checks Firebase Auth state
/// and biometric authentication before routing.
class SplashController extends GetxController {
  final _auth     = FirebaseAuth.instance;
  final _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    final user = _auth.currentUser;

    if (user != null) {
      // User is logged in — check biometric
      final authenticated = await _authenticateUser();
      if (authenticated) {
        Get.offAllNamed(AppRoutes.main);
      } else {
        SystemNavigator.pop();
      }
    } else {
      // Not logged in — go to onboarding
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }

  Future<bool> _authenticateUser() async {
    if (_isAuthenticating) return false;
    _isAuthenticating = true;

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        // No biometric available — skip auth
        _isAuthenticating = false;
        return true;
      }

      final result = await _localAuth.authenticate(
        localizedReason: 'Unlock MoneyBuddy',
        options: const AuthenticationOptions(
          biometricOnly: false,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      _isAuthenticating = false;
      return result;
    } catch (_) {
      _isAuthenticating = false;
      return true; // If biometric fails — allow access anyway
    }
  }
}