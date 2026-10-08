import '../entities/growth_dealer_search.dart';

import '../repositories/growth_report_repository.dart';

class SearchGrowthDealersUseCase {
  final GrowthReportRepository
      repository;

  SearchGrowthDealersUseCase(
    this.repository,
  );

  Future<List<GrowthDealerSearch>>
      call({
    required String userId,
    required String searchText,
    required int startLimit,
  }) {
    return repository.searchDealers(
      userId:
          userId,

      searchText:
          searchText,

      startLimit:
          startLimit,
    );
  }
}