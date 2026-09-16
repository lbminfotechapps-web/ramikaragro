import 'package:demo/features/products/domain/entity/fertilizer_product_entity.dart';

class FertilizerProductModel extends FertilizerProductEntity {
  const FertilizerProductModel({
    required super.productId,
    required super.productName,
    required super.productPath,
    required super.productContents,
    required super.productDosage,
    required super.productShortDetails,
    required super.productContentHindi,
    required super.productContentMarathi,
    required super.productNameMarathi,
    required super.productNameHindi,
    required super.diseasePath,
    required super.productNameKannad,
    super.productContentKannad,
  });

  factory FertilizerProductModel.fromJson(Map<String, dynamic> json) {
    return FertilizerProductModel(
      productId: json['fld_product_id']?.toString() ?? '',

      productName: json['fld_product_name']?.toString() ?? '',

      productPath: json['fld_product_path']?.toString() ?? '',

      productContents: json['fld_product_contents']?.toString() ?? '',

      productDosage: json['fld_product_dosage']?.toString() ?? '',

      productShortDetails: json['fld_product_short_details']?.toString() ?? '',

      productContentHindi: json['fld_product_content_hindi']?.toString() ?? '',

      productContentMarathi:
          json['fld_product_content_marathi']?.toString() ?? '',

      productNameMarathi: json['fld_product_name_marathi']?.toString() ?? '',

      productNameHindi: json['fld_product_name_hindi']?.toString() ?? '',

      diseasePath: json['fld_disease_path']?.toString() ?? '',

      productNameKannad: json['fld_product_name_kannad']?.toString() ?? '',

      productContentKannad: json['fld_product_content_kannad']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_product_id': productId,
      'fld_product_name': productName,
      'fld_product_path': productPath,
      'fld_product_contents': productContents,
      'fld_product_dosage': productDosage,
      'fld_product_short_details': productShortDetails,
      'fld_product_content_hindi': productContentHindi,
      'fld_product_content_marathi': productContentMarathi,
      'fld_product_name_marathi': productNameMarathi,
      'fld_product_name_hindi': productNameHindi,
      'fld_disease_path': diseasePath,
      'fld_product_name_kannad': productNameKannad,
      'fld_product_content_kannad': productContentKannad,
    };
  }
}
