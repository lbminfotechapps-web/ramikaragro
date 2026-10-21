
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_schedule_list.dart';

import 'schedule_list_event.dart';
import 'schedule_list_state.dart';

class ScheduleListBloc
    extends Bloc<ScheduleListEvent, ScheduleListState> {
  final GetScheduleList getScheduleList;
  final SearchScheduleListFarmers searchFarmers;

  int _farmerRequestId = 0;
  int _scheduleRequestId = 0;

  ScheduleListBloc({
    required this.getScheduleList,
    required this.searchFarmers,
  }) : super(const ScheduleListState()) {
    on<SearchScheduleFarmers>(_onSearchFarmers);
    on<ClearScheduleFarmerResults>(_onClearFarmers);
    on<LoadScheduleList>(_onLoadSchedules);
    on<ResetScheduleList>(_onReset);
  }

  Future<void> _onSearchFarmers(
    SearchScheduleFarmers event,
    Emitter<ScheduleListState> emit,
  ) async {
    final requestId = ++_farmerRequestId;
    final search = event.search.trim();

    if (search.length < 3) {
      emit(state.copyWith(
        farmers: [],
        farmerLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      farmerLoading: true,
      farmers: [],
      errorMessage: '',
    ));

    try {
      final farmers = await searchFarmers(search);

      if (requestId != _farmerRequestId) return;

      emit(state.copyWith(
        farmers: farmers,
        farmerLoading: false,
      ));
    } catch (error) {
      if (requestId != _farmerRequestId) return;

      emit(state.copyWith(
        farmerLoading: false,
        farmers: [],
        errorMessage: _message(error),
      ));
    }
  }

  void _onClearFarmers(
    ClearScheduleFarmerResults event,
    Emitter<ScheduleListState> emit,
  ) {
    _farmerRequestId++;

    emit(state.copyWith(
      farmerLoading: false,
      farmers: [],
    ));
  }

  Future<void> _onLoadSchedules(
    LoadScheduleList event,
    Emitter<ScheduleListState> emit,
  ) async {
    final requestId = ++_scheduleRequestId;

    emit(state.copyWith(
      status: ScheduleListStatus.loading,
      schedules: [],
      errorMessage: '',
    ));

    try {
      final schedules = await getScheduleList(event.filter);

      if (requestId != _scheduleRequestId) return;

      emit(state.copyWith(
        status: ScheduleListStatus.success,
        schedules: schedules,
        errorMessage: '',
      ));
    } catch (error) {
      if (requestId != _scheduleRequestId) return;

      emit(state.copyWith(
        status: ScheduleListStatus.failure,
        schedules: [],
        errorMessage: _message(error),
      ));
    }
  }

  void _onReset(
    ResetScheduleList event,
    Emitter<ScheduleListState> emit,
  ) {
    _farmerRequestId++;
    _scheduleRequestId++;

    emit(const ScheduleListState());
  }

  String _message(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('FormatException: ', '');
  }
}
