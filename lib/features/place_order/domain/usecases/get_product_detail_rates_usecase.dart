import '../entities/product_rate_entity.dart';
import '../repositories/product_rate_repository.dart';

class GetProductDetailRatesUseCase {
  final ProductRateRepository repository;

  GetProductDetailRatesUseCase({
    required this.repository,
  });

  Future<List<ProductRateEntity>> call({
    required String productId,
    required String dealerId,
  }) {
    return repository.getProductDetailRates(
      productId: productId,
      dealerId: dealerId,
    );
  }
}