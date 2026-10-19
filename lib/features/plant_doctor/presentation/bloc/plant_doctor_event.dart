import 'package:equatable/equatable.dart';

import '../../domain/entities/plant_analysis_type.dart';

sealed class PlantDoctorEvent
    extends Equatable {
  const PlantDoctorEvent();

  @override
  List<Object?> get props => [];
}

class SelectPlantTypeEvent
    extends PlantDoctorEvent {
  final PlantAnalysisType type;

  const SelectPlantTypeEvent(
    this.type,
  );

  @override
  List<Object?> get props => [
        type,
      ];
}

class PickPlantFromGalleryEvent
    extends PlantDoctorEvent {
  const PickPlantFromGalleryEvent();
}

class CapturePlantImageEvent
    extends PlantDoctorEvent {
  const CapturePlantImageEvent();
}

class AnalyzePlantEvent
    extends PlantDoctorEvent {
  const AnalyzePlantEvent();
}

class ClearPlantDoctorEvent
    extends PlantDoctorEvent {
  const ClearPlantDoctorEvent();
}