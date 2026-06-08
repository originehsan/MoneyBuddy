// MoneyBuddy
import 'package:get/get.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_register_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_screen.dart';
import '../../features/auth/screens/confirm_screen.dart';
import '../../features/main_shell/bindings/main_binding.dart';
import '../../features/main_shell/screens/main_screen.dart';
import '../../features/transactions/bindings/transaction_binding.dart';
import '../../features/transactions/screens/transaction_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../features/analytics/bindings/analytics_binding.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/groups/bindings/group_binding.dart';
import '../../features/groups/screens/group_screen.dart';
import '../../features/groups/screens/group_detail_screen.dart';
import '../../features/groups/screens/add_group_screen.dart';
import '../../features/groups/screens/add_group_transaction_screen.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/add_balance_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const _push  = Duration(milliseconds: 280);
  static const _fade  = Duration(milliseconds: 300);
  static const _modal = Duration(milliseconds: 300);

  static final List<GetPage> pages = [

    // ── Splash ──────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
      transition: Transition.noTransition,
    ),

    // ── Onboarding ──────────────────────────────────────────────
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _fade,
    ),

    // ── Login / Register entry ───────────────────────────────────
    GetPage(
      name: AppRoutes.loginRegister,
      page: () => const LoginRegisterScreen(),
      transition: Transition.fadeIn,
      transitionDuration: _fade,
    ),

    // ── Login ────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: _push,
    ),

    // ── Register ─────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: _push,
    ),

    // ── Forgot password ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.forgot,
      page: () => const ForgotScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: _push,
    ),

    // ── Confirm ──────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.confirm,
      page: () => const ConfirmScreen(),
      transition: Transition.fadeIn,
      transitionDuration: _fade,
    ),

    // ── Main shell ───────────────────────────────────────────────
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
      binding: MainBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 350),
    ),

    // ── Transactions ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionScreen(),
      binding: TransactionBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: _push,
    ),

    // ── Add transaction ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.addTransaction,
      page: () => const AddTransactionScreen(),
      binding: TransactionBinding(),
      transition: Transition.downToUp,
      transitionDuration: _modal,
    ),

    // ── Analytics ────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsScreen(),
      binding: AnalyticsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: _push,
    ),

    // ── Groups ───────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.groups,
      page: () => const GroupScreen(),
      binding: GroupBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: _push,
    ),

    // ── Group detail ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.groupDetail,
      page: () => const GroupDetailScreen(),
      binding: GroupBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: _push,
    ),

    // ── Add group ────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.addGroup,
      page: () => const AddGroupScreen(),
      binding: GroupBinding(),
      transition: Transition.downToUp,
      transitionDuration: _modal,
    ),

    // ── Add group transaction ────────────────────────────────────
    GetPage(
      name: AppRoutes.addGroupTransaction,
      page: () => const AddGroupTransactionScreen(),
      binding: GroupBinding(),
      transition: Transition.downToUp,
      transitionDuration: _modal,
    ),

    // ── Profile ──────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: _push,
    ),

    // ── Add balance ──────────────────────────────────────────────
    GetPage(
      name: AppRoutes.addBalance,
      page: () => const AddBalanceScreen(),
      binding: ProfileBinding(),
      transition: Transition.downToUp,
      transitionDuration: _modal,
    ),
  ];
}