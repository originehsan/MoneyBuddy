// MoneyBuddy

/// All named route constants.
class AppRoutes {
  AppRoutes._();

  // ── Auth ──────────────────────────────────────────────────────
  static const String splash        = '/';
  static const String onboarding    = '/onboarding';
  static const String loginRegister = '/login-register';
  static const String login         = '/login';
  static const String register      = '/register';
  static const String forgot        = '/forgot';
  static const String confirm       = '/confirm';

  // ── PIN Lock ──────────────────────────────────────────────────
  static const String pinLock  = '/pin-lock';
  static const String pinSetup = '/pin-setup';

  // ── Shell ─────────────────────────────────────────────────────
  static const String main          = '/main';

  // ── Transactions ──────────────────────────────────────────────
  static const String transactions   = '/transactions';
  static const String addTransaction = '/add-transaction';

  // ── Analytics ─────────────────────────────────────────────────
  static const String analytics      = '/analytics';

  // ── Groups ────────────────────────────────────────────────────
  static const String groups              = '/groups';
  static const String addGroup            = '/add-group';
  static const String addGroupTransaction = '/add-group-transaction';
  static const String groupDetail         = '/group-detail';

  // ── Profile ───────────────────────────────────────────────────
  static const String profile    = '/profile';
  static const String addBalance = '/add-balance';

  // ── Budget ────────────────────────────────────────────────────
  static const String budget = '/budget';

  // ── Goals ─────────────────────────────────────────────────────
  static const String goals = '/goals';

  // ── EMI ───────────────────────────────────────────────────────
  static const String emi = '/emi';

  // ── Receipt Scanner ───────────────────────────────────────────
  static const String receiptScanner = '/receipt-scanner';
}