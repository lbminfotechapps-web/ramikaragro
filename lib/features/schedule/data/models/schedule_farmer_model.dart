
import '../../domain/entities/schedule_farmer_entity.dart';

class ScheduleFarmerModel extends ScheduleFarmerEntity {
  const ScheduleFarmerModel({
    required super.farmerId,
    required super.farmerName,
    required super.address,
    required super.talukaName,
    super.mobileNo,
    super.farmerPlotStatus,
  });

  factory ScheduleFarmerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    String read(String key) =>
        json[key]?.toString().trim() ?? '';

    return ScheduleFarmerModel(
      farmerId: read('fld_farmer_id'),
      farmerName: read('fld_farmer_name'),
      address: read('fld_address'),
      talukaName: read('fld_taluka_name'),
      mobileNo: read('fld_mobile_no'),
      farmerPlotStatus:
          int.tryParse(read('farmer_plot_status')) ?? 0,
    );
  }
}
