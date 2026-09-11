
import 'package:demo/features/farmer/farmerregistration/domain/entity/irrigation_entity.dart';

class IrrigationModel extends IrrigationEntity {
  const IrrigationModel({
    required super.fldId,
    required super.fldIrrigationName,
  });

  factory IrrigationModel.fromJson(Map<String, dynamic> json) {
    return IrrigationModel(
      fldId: json['fld_id']?.toString() ?? '',
      fldIrrigationName:
          json['fld_irrigation_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_id': fldId,
      'fld_irrigation_name': fldIrrigationName,
    };
  }
}