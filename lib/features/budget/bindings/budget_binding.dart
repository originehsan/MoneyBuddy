// MoneyBuddy
import 'package:get/get.dart';
import '../controllers/budget_controller.dart';

class BudgetBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BudgetController());
  }
}