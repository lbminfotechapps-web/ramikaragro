
import '../../domain/entities/farmer_plot_entity.dart';
import '../../domain/repositories/farmer_plot_repository.dart';
import '../datasources/farmer_plot_remote_data_source.dart';

class FarmerPlotRepositoryImpl
    implements FarmerPlotRepository {
  final FarmerPlotRemoteDataSource remoteDataSource;

  const FarmerPlotRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<FarmerPlotEntity>> getFarmerPlots({
    required String empId,
    required String farmerId,
    String plotName = '',
    String cropId = '',
  }) {
    return remoteDataSource.getFarmerPlots(
      empId: empId,
      farmerId: farmerId,
      plotName: plotName,
      cropId: cropId,
    );
  }
}
