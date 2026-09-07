import 'package:demo/features/home/doman/home_entity/vehicle_type_entity.dart';

class VehicleTypeModel extends VehicleTypeEntity {
  const VehicleTypeModel({
    required super.vehicleTypeIdAdmin,
    required super.vehicleRateAdmin,
    required super.vehicleTypeId,
    required super.vehicleType,
    required super.openingClosingKm,
    required super.monthlyKmLimit,
    required super.startingKm,
    required super.vehicleTypeIdValue,
    required super.closingKm,
    required super.todaysRoute,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      vehicleTypeIdAdmin: json['fld_vehicle_type_id_admin']?.toString() ?? '',

      vehicleRateAdmin: json['fld_vehicle_rate_admin']?.toString() ?? '',

      vehicleTypeId: json['fld_vehicle_type_id']?.toString() ?? '',

      vehicleType: json['fld_vehicle_type']?.toString() ?? '',

      openingClosingKm: json['fld_opening_closing_km']?.toString() ?? '',

      monthlyKmLimit: json['fld_monthly_km_limit']?.toString() ?? '',

      startingKm: json['fld_starting_km']?.toString() ?? '',

      vehicleTypeIdValue: json['vehicle_type_id']?.toString() ?? '',

      closingKm: json['fld_closing_km']?.toString() ?? '',

      todaysRoute: json['fld_todays_route']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_vehicle_type_id_admin': vehicleTypeIdAdmin,
      'fld_vehicle_rate_admin': vehicleRateAdmin,
      'fld_vehicle_type_id': vehicleTypeId,
      'fld_vehicle_type': vehicleType,
      'fld_opening_closing_km': openingClosingKm,
      'fld_monthly_km_limit': monthlyKmLimit,
      'fld_starting_km': startingKm,
      'vehicle_type_id': vehicleTypeIdValue,
      'fld_closing_km': closingKm,
      'fld_todays_route': todaysRoute,
    };
  }
}
