import '../entities/visit_top_list.dart';
import '../repositories/visit_month_wise_repository.dart';

class GetVisitTopListUseCase {
  final VisitMonthWiseRepository repository;

  GetVisitTopListUseCase(this.repository);

  Future<VisitTopListReport> call({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return repository.getVisitTopList(
      fromDate: fromDate,

      toDate: toDate,

      employeeId: employeeId,
    );
  }
}
