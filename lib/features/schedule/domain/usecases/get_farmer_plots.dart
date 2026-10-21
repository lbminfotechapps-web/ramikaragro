
import '../entities/farmer_plot_entity.dart';
import '../repositories/farmer_plot_repository.dart';

class GetFarmerPlots {
  final FarmerPlotRepository repository;

  const GetFarmerPlots(this.repository);

  Future<List<FarmerPlotEntity>> call({
    required String empId,
    required String farmerId,
    String plotName = '',
    String cropId = '',
  }) {
    if (empId.trim().isEmpty || empId == '0') {
      throw ArgumentError('Employee ID is required');
    }

    if (farmerId.trim().isEmpty) {
      throw ArgumentError('Farmer ID is required');
    }

    return repository.getFarmerPlots(
      empId: empId,
      farmerId: farmerId,
      plotName: plotName,
      cropId: cropId,
    );
  }
}
