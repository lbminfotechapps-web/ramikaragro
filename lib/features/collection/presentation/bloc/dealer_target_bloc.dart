import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_collection_wise_target.dart';
import '../../domain/usecases/get_target_dates.dart';

import 'dealer_target_event.dart';
import 'dealer_target_state.dart';

class DealerTargetBloc
    extends Bloc<DealerTargetEvent, DealerTargetState> {
  final GetTargetDates getTargetDates;
  final GetCollectionWiseTarget getCollectionWiseTarget;

  DealerTargetBloc({
    required this.getTargetDates,
    required this.getCollectionWiseTarget,
  }) : super(const DealerTargetState()) {
    on<LoadTargetDatesEvent>(_onLoadTargetDates);
    on<SelectTargetDateEvent>(_onSelectTargetDate);
  }

  // ============================================================
  // LOAD TARGET DATES
  // ============================================================

  Future<void> _onLoadTargetDates(
    LoadTargetDatesEvent event,
    Emitter<DealerTargetState> emit,
  ) async {
    print('====================================');
    print('LOAD TARGET DATES');
    print('USER ID: ${event.userId}');
    print('====================================');

    emit(
      state.copyWith(
        datesStatus: TargetDatesStatus.loading,
        targetStatus: CollectionTargetStatus.initial,
        clearTarget: true,
        clearMessage: true,
      ),
    );

    try {
      final dates = await getTargetDates();

      print('TARGET DATES COUNT: ${dates.length}');

      if (dates.isEmpty) {
        emit(
          state.copyWith(
            datesStatus: TargetDatesStatus.success,
            targetDates: const [],
            targetStatus: CollectionTargetStatus.failure,
            clearSelectedDate: true,
            clearTarget: true,
            message: 'No target dates found',
          ),
        );

        return;
      }

      // Select first month automatically
      final firstDate = dates.first;

      print('FIRST MONTH: ${firstDate.monthName}');
      print(
        'FIRST TARGET ID: '
        '${firstDate.monthlyCollectionId}',
      );

      emit(
        state.copyWith(
          datesStatus: TargetDatesStatus.success,
          targetDates: dates,
          selectedDate: firstDate,
          targetStatus: CollectionTargetStatus.loading,
          clearTarget: true,
          clearMessage: true,
        ),
      );

      // Load target for first month
      await _getTarget(
        userId: event.userId,
        targetId: firstDate.monthlyCollectionId,
        emit: emit,
      );
    } catch (e) {
      print('TARGET DATES ERROR: $e');

      emit(
        state.copyWith(
          datesStatus: TargetDatesStatus.failure,
          targetStatus: CollectionTargetStatus.failure,
          clearTarget: true,
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // SELECT MONTH
  // ============================================================

  Future<void> _onSelectTargetDate(
    SelectTargetDateEvent event,
    Emitter<DealerTargetState> emit,
  ) async {
    print('====================================');
    print('SELECT MONTH');
    print('MONTH: ${event.selectedDate.monthName}');
    print(
      'TARGET ID: '
      '${event.selectedDate.monthlyCollectionId}',
    );
    print('USER ID: ${event.userId}');
    print('====================================');

    emit(
      state.copyWith(
        selectedDate: event.selectedDate,
        targetStatus: CollectionTargetStatus.loading,
        clearTarget: true,
        clearMessage: true,
      ),
    );

    await _getTarget(
      userId: event.userId,
      targetId: event.selectedDate.monthlyCollectionId,
      emit: emit,
    );
  }

  // ============================================================
  // GET TARGET
  // ============================================================

  Future<void> _getTarget({
    required String userId,
    required String targetId,
    required Emitter<DealerTargetState> emit,
  }) async {
    try {
      print('====================================');
      print('CALLING COLLECTION TARGET API');
      print('USER ID: $userId');
      print('TARGET ID: $targetId');
      print('====================================');

      if (targetId.isEmpty) {
        emit(
          state.copyWith(
            targetStatus: CollectionTargetStatus.failure,
            clearTarget: true,
            message: 'Target ID is empty',
          ),
        );

        return;
      }

      final result = await getCollectionWiseTarget(
        userId: userId,
        targetId: targetId,
      );

      // No record
      if (result == null) {
        print('TARGET RESULT: NULL');

        emit(
          state.copyWith(
            targetStatus: CollectionTargetStatus.failure,
            clearTarget: true,
            message: 'NO RECORD FOUND',
          ),
        );

        return;
      }

      // Success
      print('====================================');
      print('TARGET SUCCESS');
      print('TARGET: ${result.totalTarget}');
      print('ACHIEVED: ${result.totalAchieved}');
      print('PENDING: ${result.totalPending}');
      print('PERCENTAGE: ${result.percentage}');
      print('====================================');

      emit(
        state.copyWith(
          targetStatus: CollectionTargetStatus.success,
          target: result,
          clearMessage: true,
        ),
      );
    } catch (e) {
      print('TARGET API ERROR: $e');

      emit(
        state.copyWith(
          targetStatus: CollectionTargetStatus.failure,
          clearTarget: true,
          message: e.toString(),
        ),
      );
    }
  }
}
