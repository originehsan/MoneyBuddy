// MoneyBuddy
import 'package:get/get.dart';
import '../controllers/goals_controller.dart';

class GoalsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GoalsController());
  }
}