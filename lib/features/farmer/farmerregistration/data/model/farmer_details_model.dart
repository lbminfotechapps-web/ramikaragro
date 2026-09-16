

import 'package:demo/features/farmer/farmerregistration/data/model/crop_model.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/irrigation_model.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/product_model.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/farmer_details_entity.dart';

class FarmerDetailsModel extends FarmerDetailsEntity {
  const FarmerDetailsModel({
    required super.cropDetailsData,
    required super.irrigationDetailsData,
    required super.productDetailsData,
  });

  factory FarmerDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FarmerDetailsModel(
      cropDetailsData:
          (json['cropDetailsData'] as List<dynamic>? ?? [])
              .map(
                (item) => CropModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),

      irrigationDetailsData:
          (json['irrigationDetailsData'] as List<dynamic>? ?? [])
              .map(
                (item) => IrrigationModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),

      productDetailsData:
          (json['productDetailsData'] as List<dynamic>? ?? [])
              .map(
                (item) => ProductModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropDetailsData': cropDetailsData
          .map(
            (item) => CropModel(
              fldCropId: item.fldCropId,
              fldCropName: item.fldCropName,
            ).toJson(),
          )
          .toList(),

      'irrigationDetailsData': irrigationDetailsData
          .map(
            (item) => IrrigationModel(
              fldId: item.fldId,
              fldIrrigationName: item.fldIrrigationName,
            ).toJson(),
          )
          .toList(),

      'productDetailsData': productDetailsData
          .map(
            (item) => ProductModel(
              fldProductId: item.fldProductId,
              fldProductName: item.fldProductName,
            ).toJson(),
          )
          .toList(),
    };
  }
}