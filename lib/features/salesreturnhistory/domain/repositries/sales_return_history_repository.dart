import 'package:demo/features/salesreturnhistory/domain/entities/dealer_name_entity.dart';
import 'package:demo/features/salesreturnhistory/domain/entities/sales_return_history_entity.dart';

abstract class SalesReturnHistoryRepository {
  Future<List<SalesReturnHistoryEntity>> getSalesReturnHistory({
    required String userId,
    required String outletId,
    required String fromDate,
    required String toDate,
    required String startLimit,
    required String status,
  });

  Future<List<DealerNameEntity>> searchDealer({
    required String userId,
    required String searchText,
  });
}
