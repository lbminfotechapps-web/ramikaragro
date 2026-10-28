import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/schedule_item_entity.dart';
import '../../domain/usecases/search_crop.dart';
import '../../domain/usecases/search_schedule_farmer.dart';
import '../../domain/usecases/get_farmer_plots.dart';

import 'farmer_schedule_event.dart';
import 'farmer_schedule_state.dart';

class FarmerScheduleBloc
    extends Bloc<FarmerScheduleEvent, FarmerScheduleState> {
  final SearchCrop searchCrop;
  final SearchScheduleFarmer searchFarmer;
  final GetFarmerPlots getFarmerPlots;

  int _plotRequestVersion = 0;
  int _farmerSearchVersion = 0;

  FarmerScheduleBloc({
    required this.searchCrop,
    required this.searchFarmer,
    required this.getFarmerPlots,
  }) : super(const FarmerScheduleState()) {
    on<FarmerSearchChanged>(_onFarmerSearchChanged);
    on<FarmerSelected>(_onFarmerSelected);
    on<ClearSelectedFarmer>((event, emit) {
      _farmerSearchVersion++;
      _plotRequestVersion++;
      emit(const FarmerScheduleState());
    });
    on<CropSearchChanged>(_onCropSearchChanged);
    on<CropSelected>(_onCropSelected);
    on<ScheduleDateChanged>(_onDateChanged);
    on<AddScheduleLine>(_onAddScheduleLine);
    on<RemoveCurrentScheduleProduct>((event, emit) {
      if (event.index < 0 || event.index >= state.currentScheduleLines.length)
        return;
      final lines = List<String>.of(state.currentScheduleLines)
        ..removeAt(event.index);
      emit(
        state.copyWith(
          currentScheduleLines: List.unmodifiable(lines),
          currentSchedule: lines.join('\n\n'),
          message: '',
          isFailure: false,
        ),
      );
    });
    on<SaveScheduleSection>(_onSaveScheduleSection);
    on<RemoveScheduleSection>(_onRemoveScheduleSection);
    on<ClearScheduleMessage>(_onClearMessage);
    on<ClearSubmittedSchedules>((event, emit) {
      emit(state.copyWith(schedules: [], message: '', isFailure: false));
    });

    on<LoadFarmerPlots>(_onLoadFarmerPlots);
    on<FarmerPlotSelected>(_onFarmerPlotSelected);
    on<ClearFarmerPlot>(_onClearFarmerPlot);
  }

  Future<void> _onFarmerSearchChanged(
    FarmerSearchChanged event,
    Emitter<FarmerScheduleState> emit,
  ) async {
    final search = event.searchText.trim();
    final requestVersion = ++_farmerSearchVersion;

    if (search.length < 3) {
      emit(state.copyWith(farmers: const [], farmerLoading: false));
      return;
    }

    emit(
      state.copyWith(
        farmerLoading: true,
        farmers: const [],
        message: '',
        isFailure: false,
      ),
    );

    try {
      final result = await searchFarmer(searchKey: search);

      if (requestVersion != _farmerSearchVersion) return;

      emit(state.copyWith(farmerLoading: false, farmers: result));
    } catch (e) {
      if (requestVersion != _farmerSearchVersion) return;

      _error(emit, e.toString().replaceFirst('Exception: ', ''));

      emit(state.copyWith(farmerLoading: false, farmers: const []));
    }
  }

  void _onFarmerSelected(
    FarmerSelected event,
    Emitter<FarmerScheduleState> emit,
  ) {
    _farmerSearchVersion++;
    _plotRequestVersion++;

    final farmer = event.farmer;

    print('SELECTED FARMER: ${farmer.farmerName}');
    print('FARMER ID: ${farmer.farmerId}');
    print('PLOT STATUS: ${farmer.farmerPlotStatus}');

    emit(
      state.copyWith(
        selectedFarmer: farmer,
        schedules: const [],
        currentSchedule: '',
        selectedCropName: '',
        crops: const [],
        clearDate: true,
        farmers: const [],
        plots: const [],
        plotLoading: false,
        clearSelectedPlot: true,
        plotError: '',
        message: '',
      ),
    );

    // The page dispatches LoadFarmerPlots with the
    // logged-in employee ID once this farmer is selected.
  }

  Future<void> _onLoadFarmerPlots(
    LoadFarmerPlots event,
    Emitter<FarmerScheduleState> emit,
  ) async {
    if (state.selectedFarmer?.farmerId != event.farmerId) {
      return;
    }

    final version = ++_plotRequestVersion;

    emit(
      state.copyWith(
        plotLoading: true,
        plots: const [],
        clearSelectedPlot: true,
        plotError: '',
      ),
    );

    try {
      final plots = await getFarmerPlots(
        empId: event.empId,
        farmerId: event.farmerId,
      );

      if (version != _plotRequestVersion ||
          state.selectedFarmer?.farmerId != event.farmerId) {
        return;
      }

      emit(state.copyWith(plotLoading: false, plots: plots, plotError: ''));
    } catch (e) {
      if (version != _plotRequestVersion ||
          state.selectedFarmer?.farmerId != event.farmerId) {
        return;
      }

      emit(
        state.copyWith(
          plotLoading: false,
          plots: const [],
          clearSelectedPlot: true,
          plotError: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onFarmerPlotSelected(
    FarmerPlotSelected event,
    Emitter<FarmerScheduleState> emit,
  ) {
    final valid = state.plots.any(
      (plot) =>
          plot.plotId == event.plot.plotId &&
          plot.farmerId == state.selectedFarmer?.farmerId,
    );

    if (!valid) return;

    print('SELECTED PLOT ID: ${event.plot.plotId}');
    print('SELECTED PLOT NAME: ${event.plot.plotName}');

    emit(state.copyWith(selectedPlot: event.plot, message: ''));
  }

  void _onClearFarmerPlot(
    ClearFarmerPlot event,
    Emitter<FarmerScheduleState> emit,
  ) {
    emit(state.copyWith(clearSelectedPlot: true));
  }

  Future<void> _onCropSearchChanged(
    CropSearchChanged event,
    Emitter<FarmerScheduleState> emit,
  ) async {
    final search = event.searchText.trim();

    if (search.length < 3) {
      emit(state.copyWith(crops: const [], cropLoading: false));
      return;
    }

    emit(state.copyWith(cropLoading: true, crops: const [], message: ''));

    try {
      final result = await searchCrop(searchKey: search);

      emit(state.copyWith(cropLoading: false, crops: result, isFailure: false));
    } catch (e) {
      emit(
        state.copyWith(
          cropLoading: false,
          crops: const [],
          message: e.toString().replaceFirst('Exception: ', ''),
          isFailure: true,
        ),
      );
    }
  }

  void _onCropSelected(CropSelected event, Emitter<FarmerScheduleState> emit) {
    emit(state.copyWith(selectedCropName: event.cropName, crops: const []));
  }

  void _onDateChanged(
    ScheduleDateChanged event,
    Emitter<FarmerScheduleState> emit,
  ) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onAddScheduleLine(
    AddScheduleLine event,
    Emitter<FarmerScheduleState> emit,
  ) {
    if (state.selectedDate == null) {
      _error(emit, 'Please select schedule date.');
      return;
    }


    if (event.productName.trim().isEmpty) {
      _error(emit, 'Please enter product name.');
      return;
    }

    if (event.type == 'Select Type' || event.type.trim().isEmpty) {
      _error(emit, 'Please select type.');
      return;
    }

    if (event.quantity.trim().isEmpty) {
      _error(emit, 'Please enter quantity.');
      return;
    }

    if (event.quantityUnit == 'Select Unit') {
      _error(emit, 'Please select quantity unit.');
      return;
    }

    if (event.water.trim().isEmpty) {
      _error(emit, 'Please enter water.');
      return;
    }

    if (event.waterUnit == 'Select Unit') {
      _error(emit, 'Please select water unit.');
      return;
    }

    final quantity = double.tryParse(event.quantity.trim());
    final water = double.tryParse(event.water.trim());
    if (quantity == null || !quantity.isFinite || quantity <= 0) {
      _error(emit, 'Please enter a valid quantity greater than zero.');
      return;
    }
    if (water == null || !water.isFinite || water <= 0) {
      _error(emit, 'Please enter valid water greater than zero.');
      return;
    }
    final line = StringBuffer();

    line.write(
      '${event.type} :- '
      '${event.productName.trim()}'
      '(${event.quantity.trim()} ${event.quantityUnit})'
      '(${event.water.trim()} ${event.waterUnit})',
    );

    line.write('\nDate : ${DateFormat('dd/MM/yyyy').format(state.selectedDate!)}');

    if (event.remark.trim().isNotEmpty) {
      line.write('\nRemark : ${event.remark.trim()}');
    }

    var updated = state.currentSchedule;

    if (updated.trim().isNotEmpty) {
      updated += '\n\n';
    }

    updated += line.toString();

    emit(
      state.copyWith(
        currentSchedule: updated,
        currentScheduleLines: List.unmodifiable([
          ...state.currentScheduleLines,
          line.toString(),
        ]),
        message: 'Schedule added.',
        isFailure: false,
      ),
    );
  }

  void _onSaveScheduleSection(
    SaveScheduleSection event,
    Emitter<FarmerScheduleState> emit,
  ) {
    if (state.selectedDate == null) {
      _error(emit, 'Please select schedule date.');
      return;
    }


    if (state.currentSchedule.trim().isEmpty) {
      _error(emit, 'Please add at least one schedule.');
      return;
    }

    final item = ScheduleItemEntity(
      cropName: state.selectedPlot?.cropName ?? '',
      date: DateFormat('dd/MM/yyyy').format(state.selectedDate!),
      schedule: state.currentSchedule,
    );

    emit(
      state.copyWith(
        schedules: [...state.schedules, item],
        currentScheduleLines: const [],
        selectedCropName: '',
        currentSchedule: '',
        crops: const [],
        clearDate: true,
        message: 'Schedule added to list.',
        isFailure: false,
      ),
    );
  }

  void _onRemoveScheduleSection(
    RemoveScheduleSection event,
    Emitter<FarmerScheduleState> emit,
  ) {
    if (event.index < 0 || event.index >= state.schedules.length) {
      return;
    }

    final updated = List<ScheduleItemEntity>.from(state.schedules);

    updated.removeAt(event.index);

    emit(state.copyWith(schedules: updated));
  }

  void _onClearMessage(
    ClearScheduleMessage event,
    Emitter<FarmerScheduleState> emit,
  ) {
    emit(state.copyWith(message: '', isFailure: false));
  }

  void _error(Emitter<FarmerScheduleState> emit, String message) {
    emit(state.copyWith(message: message, isFailure: true));
  }
}
