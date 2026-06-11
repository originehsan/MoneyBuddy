// MoneyBuddy
import 'package:get/get.dart';
import 'package:moneybuddy/features/analytics/controllers/analytics_controller.dart';
import 'package:moneybuddy/features/goal/controllers/goals_controller.dart';
import 'package:moneybuddy/features/groups/controllers/group_controller.dart';
import 'package:moneybuddy/features/home/controllers/home_controller.dart';
import 'package:moneybuddy/features/profile/controllers/profile_controller.dart';
import 'package:moneybuddy/features/transactions/controllers/transaction_controller.dart';
import 'package:moneybuddy/features/emi/controllers/emi_controller.dart';
import '../controllers/main_controller.dart';

/// Registers all controllers needed by the main shell and its tabs.
/// All are lazy — only instantiated when their tab is first accessed.
class MainBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => TransactionController());
    Get.lazyPut(() => AnalyticsController());
    Get.lazyPut(() => GroupController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => GoalsController());
    Get.lazyPut(() => EmiController());
  }
}
