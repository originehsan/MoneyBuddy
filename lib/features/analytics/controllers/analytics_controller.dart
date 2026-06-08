// MoneyBuddy
import 'package:get/get.dart';
import '../../../core/utils/formatters.dart';
import '../../home/models/home_stats_model.dart';
import '../../home/services/home_service.dart';
import '../models/graph_model.dart';
import '../models/prediction_model.dart';
import '../services/analytics_service.dart';

export '../services/analytics_service.dart' show SmartInsight;

/// Manages analytics screen state.
class AnalyticsController extends GetxController {
  final _service     = AnalyticsService();
  final _homeService = HomeService();

  final isLoading         = true.obs;
  final selectedTab       = 0.obs;
  final graph1Data        = <GraphModel>[].obs;
  final graph2Data        = <GraphModel>[].obs;
  final graph3Data        = <GraphModel>[].obs;
  final prediction        = Rxn<PredictionModel>();
  final stats             = Rxn<HomeStatsModel>();
  final categoryBreakdown = <String, double>{}.obs;
  final smartInsights     = <SmartInsight>[].obs;
  final errorMessage      = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value    = true;
    errorMessage.value = '';

    try {
      final results = await Future.wait([
        _service.getGraph1(),
        _service.getGraph2(),
        _service.getGraph3(),
        _service.getPrediction(),
        _homeService.getHomeStats(),
        _service.getCategoryBreakdown(),
        _service.getSmartInsights(),
      ]);

      graph1Data.value        = results[0] as List<GraphModel>;
      graph2Data.value        = results[1] as List<GraphModel>;
      graph3Data.value        = results[2] as List<GraphModel>;
      prediction.value        = results[3] as PredictionModel?;
      stats.value             = results[4] as HomeStatsModel?;
      categoryBreakdown.value = results[5] as Map<String, double>;
      smartInsights.value     = results[6] as List<SmartInsight>;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  List<GraphModel> get currentGraphData {
    switch (selectedTab.value) {
      case 0:  return graph1Data;
      case 1:  return graph2Data;
      case 2:  return graph3Data;
      default: return graph1Data;
    }
  }

  double get totalSaving =>
      (stats.value?.totalIncome ?? 0) - (stats.value?.totalExpense ?? 0);

  /// True only when prediction has reliable data to show.
  /// Hides card when null OR when confidence is insufficient.
  bool get shouldShowPrediction {
    final p = prediction.value;
    if (p == null) return false;
    return p.isReliable;
  }

  /// Subtitle text shown below prediction card title.
  String get predictionSubtitle {
    final p = prediction.value;
    if (p == null) return '';
    return 'Based on ${p.daysOfData} ${p.daysOfData == 1 ? "day" : "days"} of data';
  }

  /// Confidence label for badge.
  String get confidenceLabel {
    switch (prediction.value?.confidence) {
      case PredictionConfidence.high:   return 'High confidence';
      case PredictionConfidence.medium: return 'Moderate confidence';
      case PredictionConfidence.low:    return 'Early estimate';
      default:                          return '';
    }
  }

  String formatAmount(double amount) =>
      AppFormatters.formatCurrencyCompact(amount);
}