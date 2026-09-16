import 'package:demo/features/addexpense/domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.fldVehicleTypeIdAdmin,
    required super.fldVehicleRateAdmin,
    required super.fldVehicleTypeId,
    required super.fldVehicleType,
    required super.fldOpeningClosingKm,
    required super.fldMonthlyKmLimit,
    required super.fldStartingKm,
    required super.vehicleTypeId,
    required super.fldClosingKm,
    required super.fldTodaysRoute,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      fldVehicleTypeIdAdmin:
          json['fld_vehicle_type_id_admin']?.toString() ?? '',
      fldVehicleRateAdmin: json['fld_vehicle_rate_admin']?.toString() ?? '',
      fldVehicleTypeId: json['fld_vehicle_type_id']?.toString() ?? '',
      fldVehicleType: json['fld_vehicle_type']?.toString() ?? '',
      fldOpeningClosingKm: json['fld_opening_closing_km']?.toString() ?? '',
      fldMonthlyKmLimit: json['fld_monthly_km_limit']?.toString() ?? '',
      fldStartingKm: json['fld_starting_km']?.toString() ?? '',
      vehicleTypeId: json['vehicle_type_id']?.toString() ?? '',
      fldClosingKm: json['fld_closing_km']?.toString() ?? '',
      fldTodaysRoute: json['fld_todays_route']?.toString() ?? '',
    );
  }
}
