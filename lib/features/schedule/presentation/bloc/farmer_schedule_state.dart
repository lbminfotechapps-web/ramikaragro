import 'package:equatable/equatable.dart';

import '../../domain/entities/crop_entity.dart';
import '../../domain/entities/schedule_farmer_entity.dart';
import '../../domain/entities/schedule_item_entity.dart';

class FarmerScheduleState extends Equatable {
  final bool farmerLoading;
  final bool cropLoading;

  final List<ScheduleFarmerEntity> farmers;
  final List<CropEntity> crops;

  final ScheduleFarmerEntity? selectedFarmer;

  final String selectedCropName;
  final DateTime? selectedDate;

  final String currentSchedule;

  final List<ScheduleItemEntity> schedules;

  final String message;
  final bool isFailure;

  const FarmerScheduleState({
    this.farmerLoading = false,
    this.cropLoading = false,
    this.farmers = const [],
    this.crops = const [],
    this.selectedFarmer,
    this.selectedCropName = '',
    this.selectedDate,
    this.currentSchedule = '',
    this.schedules = const [],
    this.message = '',
    this.isFailure = false,
  });

  FarmerScheduleState copyWith({
    bool? farmerLoading,
    bool? cropLoading,
    List<ScheduleFarmerEntity>? farmers,
    List<CropEntity>? crops,
    ScheduleFarmerEntity? selectedFarmer,
    String? selectedCropName,
    DateTime? selectedDate,
    bool clearDate = false,
    String? currentSchedule,
    List<ScheduleItemEntity>? schedules,
    String? message,
    bool? isFailure,
  }) {
    return FarmerScheduleState(
      farmerLoading:
          farmerLoading ?? this.farmerLoading,
      cropLoading:
          cropLoading ?? this.cropLoading,
      farmers:
          farmers ?? this.farmers,
      crops:
          crops ?? this.crops,
      selectedFarmer:
          selectedFarmer ?? this.selectedFarmer,
      selectedCropName:
          selectedCropName ??
          this.selectedCropName,
      selectedDate:
          clearDate
              ? null
              : selectedDate ??
                  this.selectedDate,
      currentSchedule:
          currentSchedule ??
          this.currentSchedule,
      schedules:
          schedules ?? this.schedules,
      message:
          message ?? this.message,
      isFailure:
          isFailure ?? this.isFailure,
    );
  }

  @override
  List<Object?> get props => [
        farmerLoading,
        cropLoading,
        farmers,
        crops,
        selectedFarmer,
        selectedCropName,
        selectedDate,
        currentSchedule,
        schedules,
        message,
        isFailure,
      ];
}