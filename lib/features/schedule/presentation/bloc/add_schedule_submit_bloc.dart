
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/add_schedule_request.dart';
import '../../domain/usecases/submit_add_schedule.dart';

enum AddScheduleSubmitStatus {
  initial,
  loading,
  success,
  failure,
}

class AddScheduleSubmitState {
  final AddScheduleSubmitStatus status;
  final String message;
  final AddScheduleResult? result;

  const AddScheduleSubmitState({
    this.status = AddScheduleSubmitStatus.initial,
    this.message = '',
    this.result,
  });
}

abstract class AddScheduleSubmitEvent {
  const AddScheduleSubmitEvent();
}

class SendAddSchedule extends AddScheduleSubmitEvent {
  final AddScheduleRequest request;

  const SendAddSchedule(this.request);
}

class ResetAddScheduleSubmit extends AddScheduleSubmitEvent {
  const ResetAddScheduleSubmit();
}

class AddScheduleSubmitBloc
    extends Bloc<AddScheduleSubmitEvent, AddScheduleSubmitState> {
  final SubmitAddSchedule submitAddSchedule;

  bool _inProgress = false;

  AddScheduleSubmitBloc({
    required this.submitAddSchedule,
  }) : super(const AddScheduleSubmitState()) {
    on<SendAddSchedule>((event, emit) async {
      if (_inProgress ||
          state.status == AddScheduleSubmitStatus.success) {
        return;
      }

      _inProgress = true;

      emit(const AddScheduleSubmitState(
        status: AddScheduleSubmitStatus.loading,
      ));

      try {
        final result = await submitAddSchedule(
          event.request,
        );

        emit(AddScheduleSubmitState(
          status: AddScheduleSubmitStatus.success,
          message: result.message,
          result: result,
        ));
      } catch (error) {
        emit(AddScheduleSubmitState(
          status: AddScheduleSubmitStatus.failure,
          message: error
              .toString()
              .replaceFirst('Exception: ', '')
              .replaceFirst('FormatException: ', ''),
        ));
      } finally {
        _inProgress = false;
      }
    });

    on<ResetAddScheduleSubmit>((event, emit) {
      if (_inProgress) return;

      emit(const AddScheduleSubmitState());
    });
  }
}
