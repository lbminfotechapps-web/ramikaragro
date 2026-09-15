import 'package:demo/features/salesreturnhistory/domain/repositries/sales_return_history_repository.dart';

import '../entities/sales_return_history_entity.dart';

class GetSalesReturnHistoryUseCase {
  final SalesReturnHistoryRepository repository;

  GetSalesReturnHistoryUseCase({required this.repository});

  Future<List<SalesReturnHistoryEntity>> call({
    required String userId,
    required String outletId,
    required String fromDate,
    required String toDate,
    required String startLimit,
    required String status,
  }) {
    return repository.getSalesReturnHistory(
      userId: userId,
      outletId: outletId,
      fromDate: fromDate,
      toDate: toDate,
      startLimit: startLimit,
      status: status,
    );
  }
}
