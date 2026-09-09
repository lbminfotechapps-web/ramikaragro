
import 'package:demo/features/products/domain/entity/fertilizer_category_entity.dart';
import 'package:demo/features/products/domain/product_repository.dart';

class ProductUseCases {
  final ProductRepository productRepository;

  ProductUseCases(this.productRepository);

  Future<List<FertilizerCategoryEntity>> getProductList(
    String searchText,
  ) async {
    return productRepository.getProductList(searchText);
  }
}
