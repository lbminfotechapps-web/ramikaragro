import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.image,
    required super.categoryId,
    required super.unit,
    required super.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _getValue(
        json,
        [
          'product_id',
          'productId',
          'id',
          'fld_product_id',
        ],
      ),
      name: _getValue(
        json,
        [
          'product_name',
          'productName',
          'name',
          'fld_product_name',
        ],
      ),
      image: _getValue(
        json,
        [
          'image',
          'product_image',
          'productImage',
          'fld_product_image',
          'fld_product_path',
        ],
      ),
      categoryId: _getValue(
        json,
        [
          'category_id',
          'categoryId',
          'fld_category_id',
        ],
      ),
      unit: _getValue(
        json,
        [
          'unit',
          'product_unit',
        ],
      ),
      price: _getValue(
        json,
        [
          'price',
          'product_price',
          'mrp',
          'product_mrp',
          'fld_product_mrp',
        ],
      ),
    );
  }

  static String _getValue(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (json[key] != null) {
        return json[key].toString();
      }
    }

    return '';
  }
}