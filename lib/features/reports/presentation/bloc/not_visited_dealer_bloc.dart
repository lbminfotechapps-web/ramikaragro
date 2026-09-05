import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_not_visited_dealers.dart';
import 'not_visited_dealer_event.dart';
import 'not_visited_dealer_state.dart';

class NotVisitedDealerBloc
    extends Bloc<NotVisitedDealerEvent, DealerState> {
  final GetNotVisitedDealers getNotVisitedDealers;

  NotVisitedDealerBloc(
    this.getNotVisitedDealers,
  ) : super(const DealerState()) {
    // ===========================================================
    // FIRST PAGE
    // ===========================================================

    on<GetNotVisitedDealersEvent>(
      _getNotVisitedDealers,
    );

    // ===========================================================
    // LOAD MORE
    // ===========================================================

    on<GetMoreNotVisitedDealersEvent>(
      _getMoreNotVisitedDealers,
    );
  }

  // =============================================================
  // FIRST PAGE / REFRESH
  // =============================================================

  Future<void> _getNotVisitedDealers(
    GetNotVisitedDealersEvent event,
    Emitter<DealerState> emit,
  ) async {
    print('');
    print('========================================');
    print('GET NOT VISITED DEALERS - FIRST PAGE');
    print('========================================');
    print('Days       : ${event.days}');
    print('startLimit : ${event.startLimit}');
    print('========================================');

    emit(
      state.copyWith(
        status: DealerStatus.loading,
        dealers: [],
        startLimit: 0,
        hasReachedMax: false,
        clearErrorMessage: true,
      ),
    );

    try {
      final dealers = await getNotVisitedDealers(
        days: event.days,
        startLimit: 0,
      );

      print('');
      print('========================================');
      print('FIRST PAGE RESPONSE');
      print('========================================');
      print('Received : ${dealers.length}');
      print('========================================');

      if (dealers.isEmpty) {
        emit(
          state.copyWith(
            status: DealerStatus.success,
            dealers: [],
            startLimit: 0,
            hasReachedMax: true,
            clearErrorMessage: true,
          ),
        );

        return;
      }

      final reachedMax =
          dealers.length < state.pageSize;

      emit(
        state.copyWith(
          status: DealerStatus.success,
          dealers: dealers,
          startLimit: dealers.length,
          hasReachedMax: reachedMax,
          clearErrorMessage: true,
        ),
      );

      print('');
      print('========================================');
      print('STATE UPDATED');
      print('========================================');
      print('Total dealers : ${dealers.length}');
      print('Next limit    : ${dealers.length}');
      print('Has max       : $reachedMax');
      print('========================================');
    } catch (e) {
      print('');
      print('========================================');
      print('FIRST PAGE ERROR');
      print('========================================');
      print(e);
      print('========================================');

      emit(
        state.copyWith(
          status: DealerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // =============================================================
  // LOAD MORE
  // =============================================================

  Future<void> _getMoreNotVisitedDealers(
    GetMoreNotVisitedDealersEvent event,
    Emitter<DealerState> emit,
  ) async {
    if (state.status == DealerStatus.loadingMore) {
      print('Already loading more. Ignoring request.');
      return;
    }

    if (state.hasReachedMax) {
      print('Already reached maximum. No API call.');
      return;
    }

    final nextStartLimit = state.startLimit;

    print('');
    print('========================================');
    print('LOAD MORE NOT VISITED DEALERS');
    print('========================================');
    print('Current records : ${state.dealers.length}');
    print('startLimit      : $nextStartLimit');
    print('days            : ${event.days}');
    print('========================================');

    emit(
      state.copyWith(
        status: DealerStatus.loadingMore,
      ),
    );

    try {
      final newDealers = await getNotVisitedDealers(
        days: event.days,
        startLimit: nextStartLimit,
      );

      print('');
      print('========================================');
      print('LOAD MORE RESPONSE');
      print('========================================');
      print('Requested startLimit : $nextStartLimit');
      print('Received             : ${newDealers.length}');
      print('========================================');

      if (newDealers.isEmpty) {
        emit(
          state.copyWith(
            status: DealerStatus.success,
            hasReachedMax: true,
          ),
        );

        return;
      }

      final updatedDealers = [
        ...state.dealers,
        ...newDealers,
      ];

      final reachedMax =
          newDealers.length < state.pageSize;

      emit(
        state.copyWith(
          status: DealerStatus.success,
          dealers: updatedDealers,
          startLimit: updatedDealers.length,
          hasReachedMax: reachedMax,
          clearErrorMessage: true,
        ),
      );

      print('');
      print('========================================');
      print('PAGINATION SUCCESS');
      print('========================================');
      print('New records     : ${newDealers.length}');
      print('Total records   : ${updatedDealers.length}');
      print('Next startLimit : ${updatedDealers.length}');
      print('Has max         : $reachedMax');
      print('========================================');
    } catch (e) {
      print('');
      print('========================================');
      print('LOAD MORE ERROR');
      print('========================================');
      print(e);
      print('========================================');

      emit(
        state.copyWith(
          status: DealerStatus.success,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}