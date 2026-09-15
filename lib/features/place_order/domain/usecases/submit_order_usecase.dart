import 'dart:typed_data';

import '../../domain/entities/dealer_entity.dart';
import '../../domain/entities/godown_entity.dart';
import '../../domain/repositories/place_order_repository.dart';

class SubmitOrderUseCase {
  final PlaceOrderRepository repository;

  SubmitOrderUseCase({
    required this.repository,
  });

  Future<void> call({
    required int userId,
    required DealerEntity dealer,
    required GodownEntity godown,
    required List<Map<String, dynamic>> products,
    required String remark,
    required List<String> imagePaths,
    required Uint8List? signatureBytes,
  }) async {
    await repository.submitOrder(
      userId: userId,
      dealer: dealer,
      godown: godown,
      products: products,
      remark: remark,
      imagePaths: imagePaths,
      signatureBytes: signatureBytes,
    );
  }
}