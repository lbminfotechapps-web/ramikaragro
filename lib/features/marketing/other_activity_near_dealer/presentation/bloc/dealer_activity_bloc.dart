
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dealer_activity.dart';
import '../../domain/usecases/submit_dealer_activity.dart';

abstract class DealerActivityEvent {
  const DealerActivityEvent();
}

class SubmitActivityEvent extends DealerActivityEvent {
  final DealerActivity activity;

  const SubmitActivityEvent(this.activity);
}

enum DealerActivityStatus {
  initial,
  submitting,
  success,
  failure,
}

class DealerActivityState {
  final DealerActivityStatus status;
  final String message;

  const DealerActivityState({
    this.status = DealerActivityStatus.initial,
    this.message = '',
  });
}

class DealerActivityBloc
    extends Bloc<DealerActivityEvent, DealerActivityState> {
  final SubmitDealerActivity submitDealerActivity;

  DealerActivityBloc(this.submitDealerActivity)
      : super(const DealerActivityState()) {
    on<SubmitActivityEvent>(_submit);
  }

  Future<void> _submit(
    SubmitActivityEvent event,
    Emitter<DealerActivityState> emit,
  ) async {
    emit(
      const DealerActivityState(
        status: DealerActivityStatus.submitting,
      ),
    );

    try {
      final message = await submitDealerActivity(
        event.activity,
      );

      emit(
        DealerActivityState(
          status: DealerActivityStatus.success,
          message: message,
        ),
      );
    } catch (error) {
      emit(
        DealerActivityState(
          status: DealerActivityStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
