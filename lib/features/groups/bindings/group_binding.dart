// MoneyBuddy
import 'package:get/get.dart';
import '../controllers/group_controller.dart';

class GroupBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupController());
  }
}