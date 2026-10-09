import '../entities/visit_geo_wise.dart';
import '../repositories/visit_month_wise_repository.dart';

class GetVisitGeoWiseUseCase {
  final VisitMonthWiseRepository repository;

  GetVisitGeoWiseUseCase(
    this.repository,
  );

  Future<VisitGeoWiseReport> call({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return repository.getVisitGeoWise(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: employeeId,
    );
  }
}