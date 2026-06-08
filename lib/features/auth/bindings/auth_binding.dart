// MoneyBuddy
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';
import '../controllers/forgot_controller.dart';

/// Registers all auth controllers lazily.
/// OtpController and NewPassController removed — Firebase handles these flows.
class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
    Get.lazyPut(() => OnboardingController());
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => RegisterController());
    Get.lazyPut(() => ForgotController());
  }
}