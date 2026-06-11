// MoneyBuddy
import 'package:get/get.dart';
import '../controllers/emi_controller.dart';

class EmiBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmiController());
  }
}