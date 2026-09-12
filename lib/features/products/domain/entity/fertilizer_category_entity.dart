
import 'fertilizer_product_entity.dart';

class FertilizerCategoryEntity {
  final String categoryId;
  final String categoryName;
  final String categoryPath;
  final String categoryDescription;
  final List<FertilizerProductEntity> products;

  const FertilizerCategoryEntity({
    required this.categoryId,
    required this.categoryName,
    required this.categoryPath,
    required this.categoryDescription,
    required this.products,
  });
}

