import 'package:solufine/features/salesreturn/domain/repositories/sales_return_repository.dart';

import '../entities/product_entity.dart';

class GetProductsUseCase {
  final SalesReturnRepository repository;

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