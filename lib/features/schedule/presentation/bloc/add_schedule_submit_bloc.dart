import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/add_schedule_request.dart';
import '../../domain/usecases/submit_add_schedule.dart';

enum AddScheduleSubmitStatus { initial, loading, success, failure }

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
  final AddScheduleRequest? _request;
  final List<AddScheduleRequest>? _requests;

  List<AddScheduleRequest> get requests => _requests ?? [_request!];
  AddScheduleRequest get request => requests.first;

  const SendAddSchedule(AddScheduleRequest request)
    : _request = request,
      _requests = null;

  const SendAddSchedule.batch(List<AddScheduleRequest> requests)
    : _requests = requests,
      _request = null;
}

class ResetAddScheduleSubmit extends AddScheduleSubmitEvent {
  const ResetAddScheduleSubmit();
}

class AddScheduleSubmitBloc
    extends Bloc<AddScheduleSubmitEvent, AddScheduleSubmitState> {
  final SubmitAddSchedule submitAddSchedule;

  bool _inProgress = false;
  final Set<String> _completedRequests = {};

  AddScheduleSubmitBloc({required this.submitAddSchedule})
    : super(const AddScheduleSubmitState()) {
    on<SendAddSchedule>((event, emit) async {
      if (_inProgress || state.status == AddScheduleSubmitStatus.success) {
        return;
      }

      _inProgress = true;

      emit(
        const AddScheduleSubmitState(status: AddScheduleSubmitStatus.loading),
      );

      try {
        if (event.requests.isEmpty) throw Exception('No schedules to submit.');
        AddScheduleResult? result;
        for (var i = 0; i < event.requests.length; i++) {
          final request = event.requests[i];
          final key = jsonEncode(request.toJson());
          if (_completedRequests.contains(key)) continue;
          debugPrint(
            'SUBMIT SCHEDULE REQUEST ${i + 1}/${event.requests.length}',
          );
          result = await submitAddSchedule(request);
          _completedRequests.add(key);
        }

        emit(
          AddScheduleSubmitState(
            status: AddScheduleSubmitStatus.success,
            message: event.requests.length > 1
                ? 'All date-wise schedules submitted successfully.'
                : result?.message ?? 'Schedule submitted successfully.',
            result: result,
          ),
        );
      } catch (error) {
        emit(
          AddScheduleSubmitState(
            status: AddScheduleSubmitStatus.failure,
            message: error
                .toString()
                .replaceFirst('Exception: ', '')
                .replaceFirst('FormatException: ', ''),
          ),
        );
      } finally {
        _inProgress = false;
      }
    });

    on<ResetAddScheduleSubmit>((event, emit) {
      if (_inProgress) return;

      _completedRequests.clear();
      emit(const AddScheduleSubmitState());
    });
  }
}
