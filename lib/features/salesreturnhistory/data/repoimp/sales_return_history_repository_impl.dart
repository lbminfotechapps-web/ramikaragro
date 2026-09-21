import 'package:solufine/features/salesreturnhistory/data/datasource/sales_return_history_remote_datasource.dart';
import 'package:solufine/features/salesreturnhistory/domain/repositries/sales_return_history_repository.dart';

import '../../domain/entities/dealer_name_entity.dart';
import '../../domain/entities/sales_return_history_entity.dart';

class SalesReturnHistoryRepositoryImpl implements SalesReturnHistoryRepository {
  final SalesReturnHistoryRemoteDatasource datasource;

  SalesReturnHistoryRepositoryImpl({required this.datasource});

  @override
  Future<List<SalesReturnHistoryEntity>> getSalesReturnHistory({
    required String userId,
    required String outletId,
    required String fromDate,
    required String toDate,
    required String startLimit,
    required String status,
  }) {
    return datasource.getSalesReturnHistory(
      params: {
        'userId': userId,
        'outlet_id': outletId,
        'fromDate': fromDate,
        'toDate': toDate,
        'startLimit': startLimit,
        if (status.isNotEmpty) 'status': status,
      },
    );
  }

  @override
  Future<List<DealerNameEntity>> searchDealer({
    required String userId,
    required String searchText,
  }) {
    return datasource.searchDealer(
      params: {'userId': userId, 'searchText': searchText},
    );
  }
}
