import '../entities/farmer_plot_entity.dart';

abstract class FarmerPlotRepository {
  Future<List<FarmerPlotEntity>> getFarmerPlots({
    required String empId,
    required String farmerId,
    String plotName = '',
    String cropId = '',
  });
}