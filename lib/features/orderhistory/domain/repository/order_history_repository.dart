import 'package:solufine/features/orderhistory/domain/entities/order_history_entity.dart';

abstract class OrderHistoryRepository {
  Future<List<OrderHistoryEntity>> getOrderHistory({
    required int userId,
    required String searchText,
    required String status,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required int pageSize,
  });

  Future<String> updateOrderStatus({
    required int userId,
    required String orderId,
    required String orderStatus,
    required String remark,
  });
}
