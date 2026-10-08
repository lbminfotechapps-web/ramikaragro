import '../../domain/entities/growth_dealer_search.dart';
import '../../domain/entities/growth_report.dart';

import '../../domain/repositories/growth_report_repository.dart';

import '../datasources/growth_report_remote_datasource.dart';

class GrowthReportRepositoryImpl
    implements GrowthReportRepository {
  final GrowthReportRemoteDataSource
      remoteDataSource;

  GrowthReportRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<GrowthReport>
      getGrowthReport({
    required String userId,
    required String years,
    required String dealerId,
    required int startLimit,
  }) {
    return remoteDataSource
        .getGrowthReport(
      userId:
          userId,

      years:
          years,

      dealerId:
          dealerId,

      startLimit:
          startLimit,
    );
  }

  @override
  Future<List<GrowthDealerSearch>>
      searchDealers({
    required String userId,
    required String searchText,
    required int startLimit,
  }) {
    return remoteDataSource
        .searchDealers(
      userId:
          userId,

      searchText:
          searchText,

      startLimit:
          startLimit,
    );
  }
}