
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_team_leave_list.dart';
import '../../domain/usecases/update_team_leave_status.dart';
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
    // ============================================================
    // GET TEAM LEAVE
    // ============================================================

    on<GetTeamLeaveListEvent>(
      _onGetTeamLeaveList,
      transformer: droppable(),
    );

    // ============================================================
    // REFRESH TEAM LEAVE
    // ============================================================

    on<RefreshTeamLeaveListEvent>(
      _onRefreshTeamLeaveList,
    );

    // ============================================================
    // UPDATE TEAM LEAVE STATUS
    // ============================================================

    on<UpdateTeamLeaveStatusEvent>(
      _onUpdateTeamLeaveStatus,
    );
  }

  // ============================================================
  // GET TEAM LEAVE LIST
  // ============================================================

  Future<void> _onGetTeamLeaveList(
    GetTeamLeaveListEvent event,
    Emitter<TeamLeaveState> emit,
  ) async {
    print('');
    print('========== GET TEAM LEAVE ==========');
    print('USER ID: ${event.userId}');
    print('FROM: ${event.fromDate}');
    print('TO: ${event.toDate}');
    print('SEARCH: ${event.searchText}');
    print('LIMIT: ${event.startLimit}');

    emit(
      state.copyWith(
        status: TeamLeaveStatus.loading,
        clearError: true,
      ),
    );

    try {
      final leaves = await getTeamLeaveList(
        userId: event.userId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        startLimit: event.startLimit,
        searchText: event.searchText,
      );

      print('LEAVES RECEIVED: ${leaves.length}');

      for (final leave in leaves) {
        print(
          'LEAVE => '
          'ID=${leave.leaveId}, '
          'NAME=${leave.employeeName}, '
          'MANAGER STATUS=${leave.managerStatus}, '
          'STATUS=${leave.status}',
        );
      }

      emit(
        state.copyWith(
          status: TeamLeaveStatus.success,
          leaves: leaves,
          clearError: true,
        ),
      );

      print('GET LIST SUCCESS');
    } catch (e, stackTrace) {
      print('GET LIST ERROR: $e');
      print(stackTrace);

      emit(
        state.copyWith(
          status: TeamLeaveStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // REFRESH TEAM LEAVE LIST
  // ============================================================

  Future<void> _onRefreshTeamLeaveList(
    RefreshTeamLeaveListEvent event,
    Emitter<TeamLeaveState> emit,
  ) async {
    print('');
    print('========== REFRESH TEAM LEAVE ==========');

    try {
      final leaves = await getTeamLeaveList(
        userId: event.userId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        startLimit: 0,
        searchText: event.searchText,
      );

      print(
        'REFRESHED LEAVES: ${leaves.length}',
      );

      emit(
        state.copyWith(
          status: TeamLeaveStatus.success,
          leaves: leaves,
          clearError: true,
        ),
      );

      print('REFRESH SUCCESS');
    } catch (e, stackTrace) {
      print('REFRESH ERROR: $e');
      print(stackTrace);

      emit(
        state.copyWith(
          status: TeamLeaveStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // UPDATE TEAM LEAVE STATUS
  //
  // status = 1 -> APPROVED
  // status = 2 -> REJECTED
  // ============================================================

  Future<void> _onUpdateTeamLeaveStatus(
    UpdateTeamLeaveStatusEvent event,
    Emitter<TeamLeaveState> emit,
  ) async {
    print('');
    print('======================================');
    print('UPDATE TEAM LEAVE START');
    print('LEAVE ID: ${event.leaveId}');
    print('USER ID: ${event.userId}');
    print('REMARK: ${event.remark}');
    print('STATUS: ${event.status}');
    print('======================================');

    // ------------------------------------------------------------
    // START UPDATE LOADING
    // ------------------------------------------------------------

    emit(
      state.copyWith(
        updateStatus: UpdateLeaveStatus.loading,
        updatingLeaveId: event.leaveId,
        clearUpdateMessage: true,
      ),
    );

    try {
      print('CALLING UPDATE USECASE');

      final response = await updateTeamLeaveStatus(
        leaveId: event.leaveId,
        userId: event.userId,
        remark: event.remark,
        status: event.status,
      );

      print('');
      print('========== UPDATE RESPONSE ==========');
      print('RESPONSE: $response');
      print('API STATUS: ${response['status']}');
      print('API RESULT: ${response['result']}');
      print('API MESSAGE: ${response['message']}');
      print('=====================================');

      // ------------------------------------------------------------
      // CHECK API SUCCESS
      // ------------------------------------------------------------

      final bool success =
          response['status'] == true ||
          response['status']
                  ?.toString()
                  .toLowerCase() ==
              'true' ||
          response['status'] == 1 ||
          response['status']?.toString() == '1';

      print('SUCCESS = $success');

      // ------------------------------------------------------------
      // API FAILURE
      // ------------------------------------------------------------

      if (!success) {
        emit(
          state.copyWith(
            updateStatus: UpdateLeaveStatus.failure,
            updateMessage:
                response['message']?.toString() ??
                    'Unable to update leave status',
            clearUpdatingLeaveId: true,
          ),
        );

        print('UPDATE FAILURE EMITTED');

        return;
      }

      // ------------------------------------------------------------
      // UPDATE LOCAL LIST
      //
      // IMPORTANT:
      // We DO NOT call getTeamLeaveList() here.
      // This prevents the second GET API call.
      // ------------------------------------------------------------

      final updatedLeaves = state.leaves.map((leave) {
        if (leave.leaveId == event.leaveId) {
          return leave.copyWith(
            managerStatus: event.status,
          );
        }

        return leave;
      }).toList();

      print('');
      print('========== LOCAL LEAVE UPDATED ==========');
      print('LEAVE ID: ${event.leaveId}');
      print('NEW MANAGER STATUS: ${event.status}');
      print('=========================================');

      // ------------------------------------------------------------
      // SUCCESS
      // ------------------------------------------------------------

      emit(
        state.copyWith(
          updateStatus: UpdateLeaveStatus.success,
          updateMessage:
              response['message']?.toString() ??
                  'Leave status updated successfully',
          leaves: updatedLeaves,
          clearUpdatingLeaveId: true,
        ),
      );

      print('UPDATE SUCCESS EMITTED');
      print('GET API WILL NOT BE CALLED AGAIN');
      print('LOADING SHOULD NOW STOP');
    } catch (e, stackTrace) {
      print('');
      print('========== UPDATE ERROR ==========');
      print('ERROR: $e');
      print(stackTrace);

      emit(
        state.copyWith(
          updateStatus: UpdateLeaveStatus.failure,
          updateMessage: e.toString(),
          clearUpdatingLeaveId: true,
        ),
      );

      print('UPDATE FAILURE EMITTED');
      print('LOADING SHOULD NOW STOP');
    }
  }
}

