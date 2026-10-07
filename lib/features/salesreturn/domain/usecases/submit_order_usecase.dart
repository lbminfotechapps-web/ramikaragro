import 'package:solufine/features/salesreturn/domain/repositories/sales_return_repository.dart';

import '../../domain/entities/dealer_entity.dart';
import '../../domain/entities/godown_entity.dart';

class SubmitOrderUseCase {
  final SalesReturnRepository repository;

  SubmitOrderUseCase({required this.repository});

  Future<void> call({
    required int userId,
    required DealerEntity dealer,
    required GodownEntity godown,
    required List<Map<String, dynamic>> products,
    required String remark,
    required List<String> imagePaths,
    required String signaturePath,
  }) async {


    final signatureFileName = await repository.uploadSignature(
      signaturePath: signaturePath,
    );


    await repository.submitOrder(
      userId: userId,
      dealer: dealer,
      godown: godown,
      products: products,
      remark: remark,
      imagePaths: imagePaths,
      signatureFileName: signatureFileName,
    );
  }
}
