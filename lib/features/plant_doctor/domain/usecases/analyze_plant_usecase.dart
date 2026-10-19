import '../entities/plant_analysis_entity.dart';
import '../entities/plant_analysis_type.dart';
import '../entities/plant_product_entity.dart';
import '../repositories/plant_doctor_repository.dart';

class PlantDoctorResult {
  final PlantAnalysisEntity analysis;
  final List<PlantProductEntity> products;

  const PlantDoctorResult({
    required this.analysis,
    required this.products,
  });
}

class AnalyzePlantUseCase {
  final PlantDoctorRepository repository;

  AnalyzePlantUseCase(
    this.repository,
  );

  Future<PlantDoctorResult> call({
    required String imagePath,
    required PlantAnalysisType type,
  }) async {
    // ==========================================================
    // STEP 1
    // GEMINI MARATHI + ENGLISH
    // ==========================================================

    final PlantAnalysisEntity analysis =
        await repository.analyzePlant(
      imagePath:
          imagePath,

      type:
          type,
    );

    // ==========================================================
    // STEP 2
    // ENGLISH RESULT -> MICRONUTRIENT PRODUCT API
    // ==========================================================

    List<PlantProductEntity> products =
        [];

    if (analysis
        .englishResult
        .trim()
        .isNotEmpty) {
      try {
        products =
            await repository
                .getRecommendedProducts(
          searchText:
              analysis
                  .englishResult,
        );
      } catch (e) {
        print(
          'RECOMMENDED PRODUCT ERROR: $e',
        );

        // Keep AI result even if product API fails.
      }
    }

    return PlantDoctorResult(
      analysis:
          analysis,

      products:
          products,
    );
  }
}