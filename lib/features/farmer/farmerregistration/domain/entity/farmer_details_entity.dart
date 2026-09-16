import 'package:equatable/equatable.dart';

import 'crop_entity.dart';
import 'irrigation_entity.dart';
import 'product_entity.dart';

class FarmerDetailsEntity extends Equatable {
  final List<CropEntity> cropDetailsData;
  final List<IrrigationEntity> irrigationDetailsData;
  final List<ProductEntity> productDetailsData;

  const FarmerDetailsEntity({
    required this.cropDetailsData,
    required this.irrigationDetailsData,
    required this.productDetailsData,
  });

  @override
  List<Object?> get props => [
        cropDetailsData,
        irrigationDetailsData,
        productDetailsData,
      ];
}