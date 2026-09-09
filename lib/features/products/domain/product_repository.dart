import 'package:demo/features/products/domain/entity/fertilizer_category_entity.dart';

abstract class ProductRepository {
  Future<List<FertilizerCategoryEntity>> getProductList(String searchText);
}
