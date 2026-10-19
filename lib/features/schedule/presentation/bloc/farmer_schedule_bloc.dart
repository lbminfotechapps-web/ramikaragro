import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/schedule_item_entity.dart';
import '../../domain/usecases/search_crop.dart';
import '../../domain/usecases/search_schedule_farmer.dart';

import 'farmer_schedule_event.dart';
import 'farmer_schedule_state.dart';

class FarmerScheduleBloc
    extends Bloc<
        FarmerScheduleEvent,
        FarmerScheduleState> {
  final SearchCrop searchCrop;
  final SearchScheduleFarmer searchFarmer;

  FarmerScheduleBloc({
    required this.searchCrop,
    required this.searchFarmer,
  }) : super(
          const FarmerScheduleState(),
        ) {
    on<FarmerSearchChanged>(
      _onFarmerSearchChanged,
    );

    on<FarmerSelected>(
      _onFarmerSelected,
    );

    on<CropSearchChanged>(
      _onCropSearchChanged,
    );

    on<CropSelected>(
      _onCropSelected,
    );

    on<ScheduleDateChanged>(
      _onDateChanged,
    );

    on<AddScheduleLine>(
      _onAddScheduleLine,
    );

    on<SaveScheduleSection>(
      _onSaveScheduleSection,
    );

    on<RemoveScheduleSection>(
      _onRemoveScheduleSection,
    );

    on<ClearScheduleMessage>(
      _onClearMessage,
    );
  }

  // ============================================================
  // FARMER SEARCH
  // ============================================================

  Future<void> _onFarmerSearchChanged(
    FarmerSearchChanged event,
    Emitter<FarmerScheduleState> emit,
  ) async {
    final String searchText =
        event.searchText.trim();

    print(
      'BLOC FARMER SEARCH : '
      '$searchText',
    );

    if (searchText.length < 3) {
      emit(
        state.copyWith(
          farmers: const [],
          farmerLoading: false,
        ),
      );

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
      final result =
          await searchFarmer(
        searchKey: searchText,
      );

      print(
        'BLOC FARMER COUNT : '
        '${result.length}',
      );

      for (final farmer in result) {
        print(
          'BLOC FARMER : '
          '${farmer.farmerName}',
        );
      }

      emit(
        state.copyWith(
          farmerLoading: false,
          farmers: result,
          message: '',
          isFailure: false,
        ),
      );
    } catch (e) {
      print(
        'BLOC FARMER ERROR : $e',
      );

      emit(
        state.copyWith(
          farmerLoading: false,
          farmers: const [],
          message: e
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              ),
          isFailure: true,
        ),
      );
    }
  }

  void _onFarmerSelected(
    FarmerSelected event,
    Emitter<FarmerScheduleState> emit,
  ) {
    print(
      'SELECTED FARMER ID : '
      '${event.farmer.farmerId}',
    );

    print(
      'SELECTED FARMER : '
      '${event.farmer.farmerName}',
    );

    emit(
      state.copyWith(
        selectedFarmer: event.farmer,
        farmers: const [],
        message: '',
      ),
    );
  }

  // ============================================================
  // CROP SEARCH
  // ============================================================

  Future<void> _onCropSearchChanged(
    CropSearchChanged event,
    Emitter<FarmerScheduleState> emit,
  ) async {
    final String searchText =
        event.searchText.trim();

    if (searchText.length < 3) {
      emit(
        state.copyWith(
          crops: const [],
          cropLoading: false,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        cropLoading: true,
        crops: const [],
        message: '',
      ),
    );

    try {
      final result =
          await searchCrop(
        searchKey: searchText,
      );

      emit(
        state.copyWith(
          cropLoading: false,
          crops: result,
          message: '',
          isFailure: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          cropLoading: false,
          crops: const [],
          message: e
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              ),
          isFailure: true,
        ),
      );
    }
  }

  void _onCropSelected(
    CropSelected event,
    Emitter<FarmerScheduleState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCropName:
            event.cropName,
        crops: const [],
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  void _onDateChanged(
    ScheduleDateChanged event,
    Emitter<FarmerScheduleState> emit,
  ) {
    emit(
      state.copyWith(
        selectedDate:
            event.date,
      ),
    );
  }

  // ============================================================
  // ADD PRODUCT SCHEDULE LINE
  // ============================================================

  void _onAddScheduleLine(
    AddScheduleLine event,
    Emitter<FarmerScheduleState> emit,
  ) {
    if (state.selectedDate == null) {
      _error(
        emit,
        'Please select schedule date.',
      );
      return;
    }

    if (state.selectedCropName
        .trim()
        .isEmpty) {
      _error(
        emit,
        'Please select crop.',
      );
      return;
    }

    if (event.productName
        .trim()
        .isEmpty) {
      _error(
        emit,
        'Please enter product name.',
      );
      return;
    }

    if (event.type ==
            'Select Type' ||
        event.type.trim().isEmpty) {
      _error(
        emit,
        'Please select type.',
      );
      return;
    }

    if (event.quantity
        .trim()
        .isEmpty) {
      _error(
        emit,
        'Please enter quantity.',
      );
      return;
    }

    if (event.quantityUnit ==
        'Select Unit') {
      _error(
        emit,
        'Please select quantity unit.',
      );
      return;
    }

    if (event.water
        .trim()
        .isEmpty) {
      _error(
        emit,
        'Please enter water.',
      );
      return;
    }

    if (event.waterUnit ==
        'Select Unit') {
      _error(
        emit,
        'Please select water unit.',
      );
      return;
    }

    final StringBuffer line =
        StringBuffer();

    line.write(
      '${event.type} :- '
      '${event.productName.trim()}'
      '(${event.quantity.trim()} '
      '${event.quantityUnit})'
      '(${event.water.trim()} '
      '${event.waterUnit})',
    );

    if (event.remark
        .trim()
        .isNotEmpty) {
      line.write(
        '\nRemark : '
        '${event.remark.trim()}',
      );
    }

    String updated =
        state.currentSchedule;

    if (updated.trim().isNotEmpty) {
      updated += '\n\n';
    }

    updated +=
        line.toString();

    emit(
      state.copyWith(
        currentSchedule:
            updated,
        message:
            'Schedule added.',
        isFailure:
            false,
      ),
    );
  }

  // ============================================================
  // SAVE FINAL CROP SCHEDULE
  // ============================================================

  void _onSaveScheduleSection(
    SaveScheduleSection event,
    Emitter<FarmerScheduleState> emit,
  ) {
    if (state.selectedDate == null) {
      _error(
        emit,
        'Please select schedule date.',
      );
      return;
    }

    if (state.selectedCropName
        .trim()
        .isEmpty) {
      _error(
        emit,
        'Please select crop.',
      );
      return;
    }

    if (state.currentSchedule
        .trim()
        .isEmpty) {
      _error(
        emit,
        'Please add at least one schedule.',
      );
      return;
    }

    final String date =
        DateFormat(
      'dd/MM/yyyy',
    ).format(
      state.selectedDate!,
    );

    final ScheduleItemEntity item =
        ScheduleItemEntity(
      cropName:
          state.selectedCropName,
      date:
          date,
      schedule:
          state.currentSchedule,
    );

    final List<ScheduleItemEntity>
        updatedList = [
      ...state.schedules,
      item,
    ];

    emit(
      state.copyWith(
        schedules:
            updatedList,
        selectedCropName:
            '',
        currentSchedule:
            '',
        crops:
            const [],
        clearDate:
            true,
        message:
            'Schedule added to list.',
        isFailure:
            false,
      ),
    );
  }

  // ============================================================
  // REMOVE
  // ============================================================

  void _onRemoveScheduleSection(
    RemoveScheduleSection event,
    Emitter<FarmerScheduleState> emit,
  ) {
    if (event.index < 0 ||
        event.index >=
            state.schedules.length) {
      return;
    }

    final List<ScheduleItemEntity> updated =
        List<ScheduleItemEntity>.from(
      state.schedules,
    );

    updated.removeAt(
      event.index,
    );

    emit(
      state.copyWith(
        schedules:
            updated,
      ),
    );
  }

  // ============================================================
  // CLEAR MESSAGE
  // ============================================================

  void _onClearMessage(
    ClearScheduleMessage event,
    Emitter<FarmerScheduleState> emit,
  ) {
    emit(
      state.copyWith(
        message: '',
        isFailure: false,
      ),
    );
  }

  void _error(
    Emitter<FarmerScheduleState> emit,
    String message,
  ) {
    emit(
      state.copyWith(
        message:
            message,
        isFailure:
            true,
      ),
    );
  }
}