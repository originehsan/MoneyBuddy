// MoneyBuddy
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/secure_storage.dart';

/// Handles all Firebase Auth operations.
/// Navigation after each action lives here to keep controllers thin.
class AuthService {
  final _auth = FirebaseAuth.instance;

  // ── Register ──────────────────────────────────────────────────

  /// Creates account, updates display name, sends verification email.
  /// Navigates to confirm screen on success.
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Set display name
      await credential.user?.updateDisplayName(name.trim());

      // Send email verification
      await credential.user?.sendEmailVerification();

      // Save user info locally
      await SecureStorage.saveUserName(name.trim());
      await SecureStorage.saveUserEmail(email.trim());

      // Navigate to confirm screen
      Get.offAllNamed(
        AppRoutes.confirm,
        arguments: {
          'title': 'Verify Your Email',
          'message':
              'We sent a verification link to $email. Please check your inbox and click the link to activate your account.',
          'isRegister': true,
        },
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(_firebaseMessage(e));
      return false;
    } catch (e) {
      _showError('Registration failed. Please try again.');
      return false;
    }
  }

  // ── Login ─────────────────────────────────────────────────────

  /// Signs in user and checks email verification.
  /// Navigates to main screen on success.
  Future<bool> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;

      if (user == null) {
        _showError('Login failed. Please try again.');
        return false;
      }

      // Check email verification
      if (!user.emailVerified) {
        _showError('Please verify your email before logging in.');
        // Offer resend option
        Get.snackbar(
          'Email not verified',
          'Check your inbox or tap to resend.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.kWarning,
          colorText: Colors.white,
          mainButton: TextButton(
            onPressed: () async {
              await user.sendEmailVerification();
              Get.snackbar(
                'Sent',
                'Verification email resent.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.kSuccess,
                colorText: Colors.white,
              );
            },
            child: const Text(
              'Resend',
              style: TextStyle(color: Colors.white),
            ),
          ),
          duration: const Duration(seconds: 5),
        );
        await _auth.signOut();
        return false;
      }

      // Save user info locally
      await SecureStorage.saveUserName(user.displayName ?? '');
      await SecureStorage.saveUserEmail(email.trim());

      Get.offAllNamed(AppRoutes.main);
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(_firebaseMessage(e));
      return false;
    } catch (e) {
      _showError('Login failed. Please try again.');
      return false;
    }
  }

  // ── Forgot Password ───────────────────────────────────────────

  /// Sends password reset email via Firebase.
  /// Navigates to confirm screen on success.
  Future<void> forgotPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      Get.offAllNamed(
        AppRoutes.confirm,
        arguments: {
          'title': 'Check Your Email',
          'message':
              'We sent a password reset link to $email. Click the link in the email to set a new password.',
          'isRegister': false,
        },
      );
    } on FirebaseAuthException catch (e) {
      _showError(_firebaseMessage(e));
    } catch (e) {
      _showError('Failed to send reset email. Please try again.');
    }
  }

  // ── Logout ────────────────────────────────────────────────────

  /// Signs out from Firebase and clears local storage.
  Future<void> logout() async {
    await _auth.signOut();
    await SecureStorage.saveUserName('');
    await SecureStorage.saveUserEmail('');
    await SecureStorage.saveGroupIds([]);
    Get.offAllNamed(AppRoutes.loginRegister);
  }

  // ── Resend verification ───────────────────────────────────────

  Future<void> resendVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      _showSuccess('Verification email resent.');
    } catch (e) {
      _showError('Failed to resend email.');
    }
  }

  // ── Current user ──────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn   => _auth.currentUser != null;

  // ── Firebase error messages ───────────────────────────────────

  String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  void _showError(String message) => Get.snackbar(
    'Error', message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.kError,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );

  void _showSuccess(String message) => Get.snackbar(
    'Success', message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.kSuccess,
    colorText: Colors.white,
    duration: const Duration(seconds: 2),
  );
}