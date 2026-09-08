import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/add_leave.dart';
import '../../domain/usecases/get_leave_list.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final GetLeaveList getLeaveList;
  final AddLeave addLeave;
  final SecureStorage secureStorage;

  LeaveBloc({
    required this.getLeaveList,
    required this.addLeave,
    required this.secureStorage,
  }) : super(const LeaveState()) {
    on<GetLeaveListEvent>(_onGetLeaveList);
    on<AddLeaveEvent>(_onAddLeave);
    on<ClearLeaveMessageEvent>(_onClearMessage);
  }

  // ============================================================
  // GET USER ID FROM SECURE STORAGE
  // ============================================================

  Future<String?> _getUserId() async {
    final userData = await secureStorage.getUserData();

    if (userData == null) {
      return null;
    }

    final userId = userData["user_id"]?.toString();

    if (userId == null || userId.trim().isEmpty) {
      return null;
    }

    return userId;
  }

  // ============================================================
  // GET LEAVE LIST
  // ============================================================

  Future<void> _onGetLeaveList(
    GetLeaveListEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(
      state.copyWith(
        leaveStatus: LeaveStatus.loading,
        clearError: true,
      ),
    );

    try {
      final userId = await _getUserId();

      if (userId == null) {
        emit(
          state.copyWith(
            leaveStatus: LeaveStatus.failure,
            errorMessage: "User ID not found",
          ),
        );

        return;
      }

      print("========== GET LEAVE LIST ==========");
      print("USER ID = $userId");
      print("FROM DATE = ${event.fromDate ?? ""}");
      print("TO DATE = ${event.toDate ?? ""}");
      print("====================================");

      final leaves = await getLeaveList(
        userId: userId,
        fromDate: event.fromDate ?? "",
        toDate: event.toDate ?? "",
      );

      emit(
        state.copyWith(
          leaveStatus: LeaveStatus.success,
          leaves: leaves,
          clearError: true,
        ),
      );
    } catch (e) {
      String message = "Something went wrong";

      if (e is ServerException || e is NetworkException) {
        message = e.toString();
      }

      emit(
        state.copyWith(
          leaveStatus: LeaveStatus.failure,
          errorMessage: message,
        ),
      );
    }
  }

  // ============================================================
  // ADD LEAVE
  // ============================================================

  Future<void> _onAddLeave(
    AddLeaveEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(
      state.copyWith(
        addLeaveStatus: AddLeaveStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final userId = await _getUserId();

      if (userId == null) {
        emit(
          state.copyWith(
            addLeaveStatus: AddLeaveStatus.failure,
            errorMessage: "User ID not found",
          ),
        );

        return;
      }

      print("========== ADD LEAVE ==========");
      print("USER ID = $userId");
      print("FROM DATE = ${event.fromDate}");
      print("END DATE = ${event.endDate}");
      print("START TYPE = ${event.startLeaveType}");
      print("END TYPE = ${event.endLeaveType}");
      print("TOTAL DAYS = ${event.totalLeaveDays}");
      print("REASON = ${event.reason}");
      print("================================");

      final message = await addLeave(
        userId: userId,
        fromDate: event.fromDate,
        endDate: event.endDate,
        startLeaveType: event.startLeaveType,
        endLeaveType: event.endLeaveType,
        totalLeaveDays: event.totalLeaveDays,
        reason: event.reason,
      );

      emit(
        state.copyWith(
          addLeaveStatus: AddLeaveStatus.success,
          successMessage: message,
          clearError: true,
        ),
      );
    } catch (e) {
      String message = "Unable to apply leave";

      if (e is ServerException || e is NetworkException) {
        message = e.toString();
      }

      emit(
        state.copyWith(
          addLeaveStatus: AddLeaveStatus.failure,
          errorMessage: message,
          clearSuccess: true,
        ),
      );
    }
  }

  // ============================================================
  // CLEAR MESSAGE
  // ============================================================

  void _onClearMessage(
    ClearLeaveMessageEvent event,
    Emitter<LeaveState> emit,
  ) {
    emit(
      state.copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }
}