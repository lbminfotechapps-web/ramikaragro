
import 'package:equatable/equatable.dart';

import '../../domain/entities/crop_entity.dart';
import '../../domain/entities/schedule_farmer_entity.dart';
import '../../domain/entities/schedule_item_entity.dart';
import '../../domain/entities/farmer_plot_entity.dart';

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

  // PLOT STATE
  final bool plotLoading;
  final List<FarmerPlotEntity> plots;
  final FarmerPlotEntity? selectedPlot;
  final String plotError;

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
    this.plotLoading = false,
    this.plots = const [],
    this.selectedPlot,
    this.plotError = '',
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

    // NEW PLOT PARAMETERS
    bool? plotLoading,
    List<FarmerPlotEntity>? plots,
    FarmerPlotEntity? selectedPlot,
    bool clearSelectedPlot = false,
    String? plotError,
  }) {
    return FarmerScheduleState(
      farmerLoading:
          farmerLoading ?? this.farmerLoading,
      cropLoading:
          cropLoading ?? this.cropLoading,
      farmers: farmers ?? this.farmers,
      crops: crops ?? this.crops,
      selectedFarmer:
          selectedFarmer ?? this.selectedFarmer,
      selectedCropName:
          selectedCropName ?? this.selectedCropName,
      selectedDate: clearDate
          ? null
          : (selectedDate ?? this.selectedDate),
      currentSchedule:
          currentSchedule ?? this.currentSchedule,
      schedules: schedules ?? this.schedules,
      message: message ?? this.message,
      isFailure: isFailure ?? this.isFailure,

      plotLoading: plotLoading ?? this.plotLoading,
      plots: plots ?? this.plots,
      selectedPlot: clearSelectedPlot
          ? null
          : (selectedPlot ?? this.selectedPlot),
      plotError: plotError ?? this.plotError,
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
        plotLoading,
        plots,
        selectedPlot,
        plotError,
      ];
}
