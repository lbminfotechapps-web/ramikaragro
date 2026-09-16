import 'package:demo/features/products/data/model/fertilizer_product_model.dart';
import 'package:demo/features/products/domain/entity/fertilizer_category_entity.dart';

class FertilizerCategoryModel extends FertilizerCategoryEntity {
  const FertilizerCategoryModel({
    required super.categoryId,
    required super.categoryName,
    required super.categoryPath,
    required super.categoryDescription,
    required super.products,
  });

  factory FertilizerCategoryModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as List? ?? [];

    return FertilizerCategoryModel(
      categoryId: json['fld_category_id']?.toString() ?? '',

      categoryName: json['fld_category_name']?.toString() ?? '',

      categoryPath: json['fld_category_path']?.toString() ?? '',

      categoryDescription: json['fld_category_description']?.toString() ?? '',

      products: productJson
          .whereType<Map<String, dynamic>>()
          .map((product) => FertilizerProductModel.fromJson(product))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_category_id': categoryId,
      'fld_category_name': categoryName,
      'fld_category_path': categoryPath,
      'fld_category_description': categoryDescription,

      'product': products
          .map(
            (product) => {
              'fld_product_id': product.productId,
              'fld_product_name': product.productName,
              'fld_product_path': product.productPath,
              'fld_product_contents': product.productContents,
              'fld_product_dosage': product.productDosage,
              'fld_product_short_details': product.productShortDetails,
              'fld_product_content_hindi': product.productContentHindi,
              'fld_product_content_marathi': product.productContentMarathi,
              'fld_product_name_marathi': product.productNameMarathi,
              'fld_product_name_hindi': product.productNameHindi,
              'fld_disease_path': product.diseasePath,
              'fld_product_name_kannad': product.productNameKannad,
              'fld_product_content_kannad': product.productContentKannad,
            },
          )
          .toList(),
    };
  }
}
