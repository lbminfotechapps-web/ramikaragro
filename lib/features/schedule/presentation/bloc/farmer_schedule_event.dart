
import 'package:equatable/equatable.dart';

import '../../domain/entities/schedule_farmer_entity.dart';
import '../../domain/entities/farmer_plot_entity.dart';

sealed class FarmerScheduleEvent extends Equatable {
  const FarmerScheduleEvent();

  @override
  List<Object?> get props => [];
}

class FarmerSearchChanged extends FarmerScheduleEvent {
  final String searchText;
  const FarmerSearchChanged(this.searchText);

  @override
  List<Object?> get props => [searchText];
}

class FarmerSelected extends FarmerScheduleEvent {
  final ScheduleFarmerEntity farmer;

  const FarmerSelected(this.farmer);

  @override
  List<Object?> get props => [farmer];
}

class CropSearchChanged extends FarmerScheduleEvent {
  final String searchText;
  const CropSearchChanged(this.searchText);

  @override
  List<Object?> get props => [searchText];
}

class CropSelected extends FarmerScheduleEvent {
  final String cropName;
  const CropSelected(this.cropName);

  @override
  List<Object?> get props => [cropName];
}

class ScheduleDateChanged extends FarmerScheduleEvent {
  final DateTime date;
  const ScheduleDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class AddScheduleLine extends FarmerScheduleEvent {
  final String productName;
  final String type;
  final String quantity;
  final String quantityUnit;
  final String water;
  final String waterUnit;
  final String remark;

  const AddScheduleLine({
    required this.productName,
    required this.type,
    required this.quantity,
    required this.quantityUnit,
    required this.water,
    required this.waterUnit,
    required this.remark,
  });

  @override
  List<Object?> get props => [
        productName,
        type,
        quantity,
        quantityUnit,
        water,
        waterUnit,
        remark,
      ];
}

class SaveScheduleSection extends FarmerScheduleEvent {
  const SaveScheduleSection();
}

class RemoveScheduleSection extends FarmerScheduleEvent {
  final int index;
  const RemoveScheduleSection(this.index);

  @override
  List<Object?> get props => [index];
}

class ClearScheduleMessage extends FarmerScheduleEvent {
  const ClearScheduleMessage();
}

// ============================================================
// NEW PLOT EVENTS
// ============================================================

class LoadFarmerPlots extends FarmerScheduleEvent {
  final String empId;
  final String farmerId;

  const LoadFarmerPlots({
    required this.empId,
    required this.farmerId,
  });

  @override
  List<Object?> get props => [empId, farmerId];
}

class FarmerPlotSelected extends FarmerScheduleEvent {
  final FarmerPlotEntity plot;

  const FarmerPlotSelected(this.plot);

  @override
  List<Object?> get props => [plot];
}

class ClearFarmerPlot extends FarmerScheduleEvent {
  const ClearFarmerPlot();
}

class ClearSubmittedSchedules extends FarmerScheduleEvent {
  const ClearSubmittedSchedules();
}

class ClearSelectedFarmer extends FarmerScheduleEvent {
  const ClearSelectedFarmer();
}
