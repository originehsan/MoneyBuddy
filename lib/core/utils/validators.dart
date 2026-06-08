// MoneyBuddy
// MoneyBuddy

/// All form validators.
/// Usage: AppValidators.validateEmail('test@test.com')
class AppValidators {
  AppValidators._();

  // ── Email ─────────────────────────────────────────────────────
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ── Password ──────────────────────────────────────────────────
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8)             return 'At least 8 characters required';
    if (!hasUpperAndLower(value))     return 'Use both uppercase and lowercase';
    if (!hasNumberOrSymbol(value))    return 'Add at least one number or symbol';
    return null;
  }

  static String? validateConfirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original)              return 'Passwords do not match';
    return null;
  }

  // ── Name ──────────────────────────────────────────────────────
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  // ── Amount ────────────────────────────────────────────────────
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final amount = double.tryParse(value.trim());
    if (amount == null) return 'Enter a valid amount';
    if (amount <= 0)    return 'Amount must be greater than 0';
    return null;
  }

  // ── OTP ───────────────────────────────────────────────────────
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6)              return 'Enter the 6-digit OTP';
    return null;
  }

  // ── General required ──────────────────────────────────────────
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // ── Password rule checks — for live checklist ─────────────────
  static bool hasMinLength(String password)     => password.length >= 8;
  static bool hasUpperAndLower(String password) =>
      RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(password);
  static bool hasNumberOrSymbol(String password) =>
      RegExp(r'(?=.*\d)|(?=.*[!@#\$%^&*(),.?":{}|<>])').hasMatch(password);
}