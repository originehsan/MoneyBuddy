// MoneyBuddy
import 'package:get/get.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AnalyticsController());
  }
}