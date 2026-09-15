import 'package:demo/features/orderhistory/data/datasource/order_history_remote_datasource.dart';
import 'package:demo/features/orderhistory/domain/entities/order_history_entity.dart';
import 'package:demo/features/orderhistory/domain/repository/order_history_repository.dart';

class OrderHistoryRepositoryImpl implements OrderHistoryRepository {
  final OrderHistoryRemoteDataSource remoteDataSource;

  OrderHistoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<OrderHistoryEntity>> getOrderHistory({
    required int userId,
    required String searchText,
    required String status,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required int pageSize,
  }) async {
    return await remoteDataSource.getOrderHistory(
      userId: userId,
      searchText: searchText,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
      startLimit: startLimit,
      pageSize: pageSize,
    );
  }

  @override
  Future<String> updateOrderStatus({
    required int userId,
    required String orderId,
    required String orderStatus,
    required String remark,
  }) async {
    return await remoteDataSource.updateOrderStatus(
      userId: userId,
      orderId: orderId,
      orderStatus: orderStatus,
      remark: remark,
    );
  }
}
