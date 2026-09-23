import '../entities/product_rate_entity.dart';

abstract class ProductRateRepository {
  Future<List<ProductRateEntity>> getProductDetailRates({
    required String productId,
    required String dealerId,
  });
}