import '../../domain/entities/schedule_farmer_entity.dart';

class ScheduleFarmerModel
    extends ScheduleFarmerEntity {
  const ScheduleFarmerModel({
    required super.farmerId,
    required super.farmerName,
    required super.address,
    required super.talukaName,
    super.mobileNo,
  });

  factory ScheduleFarmerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ScheduleFarmerModel(
      farmerId:
          json['fld_farmer_id']
                  ?.toString()
                  .trim() ??
              '',

      farmerName:
          json['fld_farmer_name']
                  ?.toString()
                  .trim() ??
              '',

      address:
          json['fld_address']
                  ?.toString()
                  .trim() ??
              '',

      talukaName:
          json['fld_taluka_name']
                  ?.toString()
                  .trim() ??
              '',

      // Current API response does not return this.
      mobileNo:
          json['fld_mobile_no']
                  ?.toString()
                  .trim() ??
              '',
    );
  }
}