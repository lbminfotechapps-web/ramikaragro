import '../../domain/entities/plant_analysis_entity.dart';
import '../../domain/entities/plant_analysis_type.dart';
import '../../domain/entities/plant_product_entity.dart';
import '../../domain/repositories/plant_doctor_repository.dart';

import '../datasource/plant_ai_remote_datasource.dart';
import '../datasource/plant_product_remote_datasource.dart';

class PlantDoctorRepositoryImpl
    implements PlantDoctorRepository {
  final PlantAiRemoteDataSource
      aiRemoteDataSource;

  final PlantProductRemoteDataSource
      productRemoteDataSource;

  PlantDoctorRepositoryImpl({
    required this.aiRemoteDataSource,
    required this.productRemoteDataSource,
  });

  @override
  Future<PlantAnalysisEntity> analyzePlant({
    required String imagePath,
    required PlantAnalysisType type,
  }) {
    return aiRemoteDataSource.analyzePlant(
      imagePath:
          imagePath,

      type:
          type,
    );
  }

  @override
  Future<List<PlantProductEntity>>
      getRecommendedProducts({
    required String searchText,
  }) {
    return productRemoteDataSource
        .getRecommendedProducts(
      searchText:
          searchText,
    );
  }
}