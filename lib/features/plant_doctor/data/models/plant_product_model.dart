import '../../domain/entities/plant_product_entity.dart';

class PlantProductModel extends PlantProductEntity {
  const PlantProductModel({
    required super.productId,
    required super.productName,
    required super.micronutrientName,
    super.usage,
  });

  factory PlantProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PlantProductModel(
      productId:
          json['product_id']?.toString() ??
          json['productId']?.toString() ??
          json['fld_product_id']?.toString() ??
          '',

      productName:
          json['product_name']?.toString() ??
          json['productName']?.toString() ??
          json['fld_product_name']?.toString() ??
          '',

      micronutrientName:
          json['micronutrient_name']?.toString() ??
          json['micronutrientName']?.toString() ??
          json['fld_micronutrient_name']?.toString() ??
          '',

      usage:
          json['usage']?.toString() ??
          json['fld_usage']?.toString() ??
          '',
    );
  }
}