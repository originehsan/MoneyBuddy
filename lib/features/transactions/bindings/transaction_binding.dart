// MoneyBuddy
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';

class TransactionBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TransactionController());
  }
}