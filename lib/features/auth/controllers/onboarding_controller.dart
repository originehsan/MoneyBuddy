// MoneyBuddy
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

/// Controls single onboarding screen.
/// Navigates to login/register on Get Started tap.
class OnboardingController extends GetxController {
  void getStarted() => Get.offAllNamed(AppRoutes.loginRegister);
}