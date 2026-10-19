import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utility/plant_image_picker.dart';
import '../../domain/entities/plant_analysis_type.dart';
import '../../domain/usecases/analyze_plant_usecase.dart';

import 'plant_doctor_event.dart';
import 'plant_doctor_state.dart';

class PlantDoctorBloc
    extends Bloc<
        PlantDoctorEvent,
        PlantDoctorState> {
  final AnalyzePlantUseCase
      analyzePlantUseCase;

  final PlantImagePicker
      imagePicker;

  PlantDoctorBloc({
    required this.analyzePlantUseCase,
    required this.imagePicker,
  }) : super(
          const PlantDoctorState(),
        ) {
    on<SelectPlantTypeEvent>(
      _onSelectType,
    );

    on<PickPlantFromGalleryEvent>(
      _onGallery,
    );

    on<CapturePlantImageEvent>(
      _onCamera,
    );

    on<AnalyzePlantEvent>(
      _onAnalyze,
    );

    on<ClearPlantDoctorEvent>(
      _onClear,
    );
  }

  void _onSelectType(
    SelectPlantTypeEvent event,
    Emitter<PlantDoctorState> emit,
  ) {
    emit(
      state.copyWith(
        selectedType:
            event.type,

        result:
            '',

        englishResult:
            '',

        products:
            [],

        errorMessage:
            '',

        status:
            state.imagePath.isEmpty
            ? PlantDoctorStatus.initial
            : PlantDoctorStatus.imageSelected,
      ),
    );

    if (state.imagePath.isNotEmpty) {
      add(
        const AnalyzePlantEvent(),
      );
    }
  }

  Future<void> _onGallery(
    PickPlantFromGalleryEvent event,
    Emitter<PlantDoctorState> emit,
  ) async {
    final String? path =
        await imagePicker.gallery();

    if (path == null ||
        path.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        imagePath:
            path,

        result:
            '',

        englishResult:
            '',

        products:
            [],

        errorMessage:
            '',

        status:
            PlantDoctorStatus
                .imageSelected,
      ),
    );

    add(
      const AnalyzePlantEvent(),
    );
  }

  Future<void> _onCamera(
    CapturePlantImageEvent event,
    Emitter<PlantDoctorState> emit,
  ) async {
    final String? path =
        await imagePicker.camera();

    if (path == null ||
        path.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        imagePath:
            path,

        result:
            '',

        englishResult:
            '',

        products:
            [],

        errorMessage:
            '',

        status:
            PlantDoctorStatus
                .imageSelected,
      ),
    );

    add(
      const AnalyzePlantEvent(),
    );
  }

  Future<void> _onAnalyze(
    AnalyzePlantEvent event,
    Emitter<PlantDoctorState> emit,
  ) async {
    if (state.imagePath.isEmpty) {
      emit(
        state.copyWith(
          status:
              PlantDoctorStatus.failure,

          errorMessage:
              'Please select plant image.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        status:
            PlantDoctorStatus.loading,

        errorMessage:
            '',
      ),
    );

    try {
      final result =
          await analyzePlantUseCase(
        imagePath:
            state.imagePath,

        type:
            state.selectedType,
      );

      emit(
        state.copyWith(
          status:
              PlantDoctorStatus.success,

          result:
              result.analysis
                  .marathiResult,

          englishResult:
              result.analysis
                  .englishResult,

          products:
              result.products,

          errorMessage:
              '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              PlantDoctorStatus.failure,

          errorMessage:
              e.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
        ),
      );
    }
  }

  void _onClear(
    ClearPlantDoctorEvent event,
    Emitter<PlantDoctorState> emit,
  ) {
    emit(
      PlantDoctorState(
        selectedType:
            state.selectedType,
      ),
    );
  }
}