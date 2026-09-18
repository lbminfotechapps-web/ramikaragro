import 'package:demo/features/followup/domain/usecases/get_followup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'followup_event.dart';
import 'followup_state.dart';

class FollowupBloc
    extends Bloc<FollowupEvent, FollowupState> {
  final GetUpcomingFollowup getUpcomingFollowup;

  FollowupBloc({
    required this.getUpcomingFollowup,
  }) : super(FollowupInitial()) {
    on<GetUpcomingFollowupEvent>(
      _onGetUpcomingFollowup,
    );
  }

  Future<void> _onGetUpcomingFollowup(
    GetUpcomingFollowupEvent event,
    Emitter<FollowupState> emit,
  ) async {
    emit(FollowupLoading());

    try {
      final result = await getUpcomingFollowup(
        fromDate: event.fromDate,
        toDate: event.toDate,
        type: event.type,
        userId: event.userId,
      );

      if (result.isEmpty) {
        emit(
          const FollowupEmpty(
            message: 'No followup records found',
          ),
        );

        return;
      }

      emit(
        FollowupSuccess(
          followups: result,
        ),
      );
    } catch (e) {
      emit(
        FollowupError(
          message: e
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              ),
        ),
      );
    }
  }
}