import '../entities/growth_dealer_search.dart';
import '../entities/growth_report.dart';

abstract class GrowthReportRepository {
  Future<GrowthReport>
      getGrowthReport({
    required String userId,
    required String years,
    required String dealerId,
    required int startLimit,
  });

  Future<List<GrowthDealerSearch>>
      searchDealers({
    required String userId,
    required String searchText,
    required int startLimit,
  });
}