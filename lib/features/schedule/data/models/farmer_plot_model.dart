
import '../../domain/entities/farmer_plot_entity.dart';

class FarmerPlotModel extends FarmerPlotEntity {
  const FarmerPlotModel({
    required super.plotId,
    required super.plotName,
    required super.farmerId,
    required super.farmerName,
    required super.cropId,
    required super.cropName,
    required super.sowingDate,
    required super.createdDate,
  });

  factory FarmerPlotModel.fromJson(
    Map<String, dynamic> json,
  ) {
    String read(String key) =>
        json[key]?.toString().trim() ?? '';

    return FarmerPlotModel(
      plotId: read('fld_plot_registration_id'),
      plotName: read('fld_plot_name'),
      farmerId: read('fld_farmer_id'),
      farmerName: read('fld_farmer_name'),
      cropId: read('fld_crop_id'),
      cropName: read('fld_crop_name'),
      sowingDate: read('fld_sowing_date'),
      createdDate: read('fld_created_date'),
    );
  }
}
