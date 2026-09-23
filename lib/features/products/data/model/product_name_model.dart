import 'package:solufine/features/products/domain/entity/product_name.dart';

class ProductResponseModel extends ProductResponseEntity {
  const ProductResponseModel({
    required super.products,
    required super.status,
    required super.message,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductResponseModel(
      products: (json['result'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                ProductModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': products.map((product) {
        if (product is ProductModel) {
          return product.toJson();
        }

        return {
          'fld_product_id': product.productId,
          'fld_product_name': product.productName,
          'fld_product_path': product.productPath,
          'fld_product_contents': product.productContents,
          'fld_product_dosage': product.productDosage,
        };
      }).toList(),
      'status': status,
      'message': message,
    };
  }
}

class ProductModel extends ProductEntityy {
  const ProductModel({
    required super.productId,
    required super.productName,
    required super.productPath,
    required super.productContents,
    required super.productDosage,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['fld_product_id']?.toString() ?? '',
      productName: json['fld_product_name']?.toString() ?? '',
      productPath: json['fld_product_path']?.toString() ?? '',
      productContents: json['fld_product_contents']?.toString() ?? '',
      productDosage: json['fld_product_dosage']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_product_id': productId,
      'fld_product_name': productName,
      'fld_product_path': productPath,
      'fld_product_contents': productContents,
      'fld_product_dosage': productDosage,
    };
  }
}
