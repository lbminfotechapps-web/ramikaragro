import 'package:solufine/features/products/domain/entity/fertilizer_category_entity.dart';
import 'package:solufine/features/products/domain/entity/product_name.dart';
import 'package:solufine/features/products/domain/product_repository.dart';

class ProductUseCases {
  final ProductRepository productRepository;

  ProductUseCases(this.productRepository);

  Future<List<FertilizerCategoryEntity>> getProductList(
    String searchText,
  ) async {
    return productRepository.getProductList(searchText);
  }

  Future<ProductResponseEntity> getProductNameList(
    String searchText,
  ) async {
    return productRepository.getProductNameList(searchText);
  }
}
