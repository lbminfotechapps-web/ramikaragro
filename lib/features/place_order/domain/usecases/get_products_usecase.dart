import '../entities/product_entity.dart';
import '../repositories/place_order_repository.dart';

class GetProductsUseCase {
  final PlaceOrderRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> call({
    required String categoryId,
    required String searchText,
  }) {
    return repository.getProducts(
      categoryId: categoryId,
      searchText: searchText,
    );
  }
}