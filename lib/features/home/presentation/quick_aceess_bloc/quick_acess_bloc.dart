import 'package:demo/features/home/doman/home_usecases/get_punch_status_usecase.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickAcessBloc extends Bloc<QuickAccessEvent, QuickAccessState> {
  final GetPunchStatusUsecase getPunchStatusUsecase;

  QuickAcessBloc(this.getPunchStatusUsecase) : super(const QuickAccessState()) {
    on<PunchStatEvent>(_onGetPunchStatus);
  }

  Future<void> _onGetPunchStatus(
    PunchStatEvent event,
    Emitter<QuickAccessState> emit,
  ) async {
    emit(
      state.copyWith(
        quickAccessStatus: QuickAccessStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final punchStat = await getPunchStatusUsecase.getPunchStatus(
        event.userId,
      );
      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.success,
          punchStat: punchStat,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
