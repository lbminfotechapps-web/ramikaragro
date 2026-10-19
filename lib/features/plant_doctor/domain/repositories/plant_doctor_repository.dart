import '../entities/plant_analysis_entity.dart';
import '../entities/plant_analysis_type.dart';
import '../entities/plant_product_entity.dart';

abstract class PlantDoctorRepository {
  Future<PlantAnalysisEntity> analyzePlant({
    required String imagePath,
    required PlantAnalysisType type,
  });

  Future<List<PlantProductEntity>>
      getRecommendedProducts({
    required String searchText,
  });
}