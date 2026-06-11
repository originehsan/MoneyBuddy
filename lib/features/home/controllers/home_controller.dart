// MoneyBuddy
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/utils/formatters.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/services/transaction_service.dart';
import '../../budget/budget_service.dart';
import '../models/home_stats_model.dart';
import '../services/home_service.dart';

/// Manages all home screen state.
class HomeController extends GetxController {
  final _homeService        = HomeService();
  final _transactionService = TransactionService();

  final isLoading     = true.obs;
  final userName      = ''.obs;
  final greeting      = ''.obs;
  final stats         = Rxn<HomeStatsModel>();
  final recentTx      = <TransactionModel>[].obs;
  final monthlyBudget = 0.0.obs;
  final errorMessage  = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    _loadBudget();
  }

  Future<void> loadData() async {
    isLoading.value    = true;
    errorMessage.value = '';

    try {
      final results = await Future.wait([
        _homeService.getUserName(),
        _homeService.getHomeStats(),
        _transactionService.getTransactions(),
      ]);

      final name     = results[0] as String?;
      final homeData = results[1] as HomeStatsModel?;
      final txList   = results[2] as List<TransactionModel>;

      userName.value = name ??
          FirebaseAuth.instance.currentUser?.displayName ??
          'there';
      greeting.value = AppFormatters.getGreeting();
      stats.value    = homeData;
      recentTx.value = txList.take(5).toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadBudget() async {
    final budget = await BudgetService.getBudget();
    monthlyBudget.value = budget;
  }

  void refreshBudget() => _loadBudget();

  double get budgetProgress {
    if (monthlyBudget.value <= 0) return 0;
    return ((stats.value?.totalExpense ?? 0) / monthlyBudget.value)
        .clamp(0.0, 1.0);
  }
}