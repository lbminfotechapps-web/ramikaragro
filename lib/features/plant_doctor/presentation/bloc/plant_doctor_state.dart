import 'package:equatable/equatable.dart';

import '../../domain/entities/plant_analysis_type.dart';
import '../../domain/entities/plant_product_entity.dart';

enum PlantDoctorStatus {
  initial,
  imageSelected,
  loading,
  success,
  failure,
}

class PlantDoctorState
    extends Equatable {
  final PlantDoctorStatus status;

  final PlantAnalysisType selectedType;

  final String imagePath;

  final String result;

  final String englishResult;

  final List<PlantProductEntity> products;

  final String errorMessage;

  const PlantDoctorState({
    this.status =
        PlantDoctorStatus.initial,

    this.selectedType =
        PlantAnalysisType.growth,

    this.imagePath =
        '',

    this.result =
        '',

    this.englishResult =
        '',

    this.products =
        const [],

    this.errorMessage =
        '',
  });

  PlantDoctorState copyWith({
    PlantDoctorStatus? status,
    PlantAnalysisType? selectedType,
    String? imagePath,
    String? result,
    String? englishResult,
    List<PlantProductEntity>? products,
    String? errorMessage,
  }) {
    return PlantDoctorState(
      status:
          status ??
          this.status,

      selectedType:
          selectedType ??
          this.selectedType,

      imagePath:
          imagePath ??
          this.imagePath,

      result:
          result ??
          this.result,

      englishResult:
          englishResult ??
          this.englishResult,

      products:
          products ??
          this.products,

      errorMessage:
          errorMessage ??
          this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedType,
        imagePath,
        result,
        englishResult,
        products,
        errorMessage,
      ];
}