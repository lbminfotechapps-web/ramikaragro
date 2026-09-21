import 'package:solufine/features/orderhistory/domain/repository/order_history_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderHistoryRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<String> call({
    required int userId,
    required String orderId,
    required String orderStatus,
    required String remark,
  }) async {
    return await repository.updateOrderStatus(
      userId: userId,
      orderId: orderId,
      orderStatus: orderStatus,
      remark: remark,
    );
  }
}
