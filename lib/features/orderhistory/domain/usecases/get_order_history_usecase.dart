import 'package:demo/features/orderhistory/domain/repository/order_history_repository.dart';

import '../entities/order_history_entity.dart';

class GetOrderHistoryUseCase {
  final OrderHistoryRepository repository;

  GetOrderHistoryUseCase(this.repository);

  Future<List<OrderHistoryEntity>> call({
    required int userId,
    required String searchText,
    required String status,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required int pageSize,
  }) async {
    return await repository.getOrderHistory(
      userId: userId,
      searchText: searchText,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
      startLimit: startLimit,
      pageSize: pageSize,
    );
  }
}
