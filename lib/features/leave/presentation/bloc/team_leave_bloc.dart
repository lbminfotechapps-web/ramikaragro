import 'package:demo/features/leave/domain/usecases/get_team_leave_list.dart';
import 'package:demo/features/leave/domain/usecases/update_team_leave_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'team_leave_event.dart';
import 'team_leave_state.dart';

class TeamLeaveBloc
    extends Bloc<TeamLeaveEvent, TeamLeaveState> {
  final GetTeamLeaveList getTeamLeaveList;
  final UpdateTeamLeaveStatus updateTeamLeaveStatus;

  TeamLeaveBloc({
    required this.getTeamLeaveList,
    required this.updateTeamLeaveStatus,
  }) : super(const TeamLeaveState()) {
    on<GetTeamLeaveListEvent>(
      _onGetTeamLeaveList,
    );

    on<RefreshTeamLeaveListEvent>(
      _onRefresh,
    );

    on<UpdateTeamLeaveStatusEvent>(
      _onUpdateStatus,
    );
  }

  Future<void> _onGetTeamLeaveList(
    GetTeamLeaveListEvent event,
    Emitter<TeamLeaveState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TeamLeaveStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final result = await getTeamLeaveList(
        userId: event.userId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        startLimit: event.startLimit,
        searchText: event.searchText,
      );

      emit(
        state.copyWith(
          status: TeamLeaveStatus.success,
          leaves: result,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TeamLeaveStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefresh(
    RefreshTeamLeaveListEvent event,
    Emitter<TeamLeaveState> emit,
  ) async {
    try {
      final result = await getTeamLeaveList(
        userId: event.userId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        startLimit: 0,
        searchText: event.searchText,
      );

      emit(
        state.copyWith(
          status: TeamLeaveStatus.success,
          leaves: result,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TeamLeaveStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateStatus(
    UpdateTeamLeaveStatusEvent event,
    Emitter<TeamLeaveState> emit,
  ) async {
    emit(
      state.copyWith(
        updateStatus:
            UpdateLeaveStatus.loading,
        updateMessage: null,
      ),
    );

    try {
      final response =
          await updateTeamLeaveStatus(
        leaveId: event.leaveId,
        userId: event.userId,
        remark: event.remark,
        status: event.status,
      );

      final success =
          response['status'] == true;

      if (success) {
        emit(
          state.copyWith(
            updateStatus:
                UpdateLeaveStatus.success,
            updateMessage:
                response['message']?.toString() ??
                    'Leave status updated',
          ),
        );
      } else {
        emit(
          state.copyWith(
            updateStatus:
                UpdateLeaveStatus.failure,
            updateMessage:
                response['message']?.toString() ??
                    'Unable to update leave status',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          updateStatus:
              UpdateLeaveStatus.failure,
          updateMessage: e.toString(),
        ),
      );
    }
  }
}