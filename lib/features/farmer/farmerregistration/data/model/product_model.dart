
import 'package:demo/features/farmer/farmerregistration/domain/entity/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.fldProductId,
    required super.fldProductName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      fldProductId: json['fld_product_id']?.toString() ?? '',
      fldProductName:
          json['fld_product_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_product_id': fldProductId,
      'fld_product_name': fldProductName,
    };
  }
}