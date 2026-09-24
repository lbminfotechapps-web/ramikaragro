import '../../domain/entities/product_rate_entity.dart';
import '../../domain/repositories/product_rate_repository.dart';
import '../datasources/product_rate_remote_datasource.dart';

class ProductRateRepositoryImpl
    implements ProductRateRepository {
  final ProductRateRemoteDataSource remoteDataSource;

  ProductRateRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<ProductRateEntity>> getProductDetailRates({
    required String productId,
    required String dealerId,
  }) {
    return remoteDataSource.getProductDetailRates(
      productId: productId,
      dealerId: dealerId,
    );
  }
}