import 'package:demo/features/home/doman/home_usecases/get_crop_schedules.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'crop_schedule_event.dart';
import 'crop_schedule_state.dart';

class CropScheduleBloc
    extends Bloc<CropScheduleEvent, CropScheduleState> {
  final GetCropSchedules getCropSchedules;

  CropScheduleBloc({
    required this.getCropSchedules,
  }) : super(const CropScheduleState()) {
    on<GetCropSchedulesEvent>(
      _onGetCropSchedules,
    );

    on<RefreshCropSchedulesEvent>(
      _onRefreshCropSchedules,
    );
  }

  // =========================================================
  // GET CROP SCHEDULE
  // =========================================================

  Future<void> _onGetCropSchedules(
    GetCropSchedulesEvent event,
    Emitter<CropScheduleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CropScheduleStatus.loading,
        schedules: [],
        clearErrorMessage: true,
      ),
    );

    try {
      final schedules = await getCropSchedules();

      emit(
        state.copyWith(
          status: CropScheduleStatus.success,
          schedules: schedules,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CropScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> _onRefreshCropSchedules(
    RefreshCropSchedulesEvent event,
    Emitter<CropScheduleState> emit,
  ) async {
    try {
      final schedules = await getCropSchedules();

      emit(
        state.copyWith(
          status: CropScheduleStatus.success,
          schedules: schedules,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      // Keep old data during refresh failure
      emit(
        state.copyWith(
          status: CropScheduleStatus.success,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}