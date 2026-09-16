import 'package:demo/features/products/data/product_datasource.dart';
import 'package:demo/features/products/domain/entity/fertilizer_category_entity.dart';
import 'package:demo/features/products/domain/product_repository.dart';

class ProductRepoImp implements ProductRepository {
  final ProductDatasource productDatasource;

  ProductRepoImp(this.productDatasource);

  @override
  Future<List<FertilizerCategoryEntity>> getProductList(
    String searchText,
  ) async {
    try {
      final result = await productDatasource.getProductList(searchText);

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
