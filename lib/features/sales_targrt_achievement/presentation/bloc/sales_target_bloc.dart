import 'package:solufine/features/sales_targrt_achievement/domain/usecases/get_sales_wise_target.dart';
import 'package:solufine/features/sales_targrt_achievement/domain/usecases/get_target_dates.dart';
import 'package:solufine/features/sales_targrt_achievement/presentation/bloc/sales_target_event.dart';
import 'package:solufine/features/sales_targrt_achievement/presentation/bloc/sales_target_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SalesTargetBloc
    extends Bloc<SalesTargetEvent, SalesTargetState> {
  final GetTargetDates getTargetDates;
  final GeSalesWiseTarget getSalesWiseTarget;

  SalesTargetBloc({
    required this.getTargetDates,
    required this.getSalesWiseTarget,
  }) : super(const SalesTargetState()) {
    on<LoadTargetDatesEvent>(_onLoadTargetDates);
    on<SelectTargetDateEvent>(_onSelectTargetDate);
  }

  // ============================================================
  // LOAD TARGET DATES
  // ============================================================

  Future<void> _onLoadTargetDates(
    LoadTargetDatesEvent event,
    Emitter<SalesTargetState> emit,
  ) async {
    print('====================================');
    print('LOAD TARGET DATES');
    print('USER ID: ${event.userId}');
    print('====================================');

    emit(
      state.copyWith(
        datesStatus: TargetDatesStatus.loading,
        targetStatus: SalesTargetStatus.initial,
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
            targetStatus: SalesTargetStatus.failure,
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
          targetStatus: SalesTargetStatus.loading,
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
          targetStatus: SalesTargetStatus.failure,
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
    Emitter<SalesTargetState> emit,
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
        targetStatus: SalesTargetStatus.loading,
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
    required Emitter<SalesTargetState> emit,
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
            targetStatus: SalesTargetStatus.failure,
            clearTarget: true,
            message: 'Target ID is empty',
          ),
        );

        return;
      }

      final result = await getSalesWiseTarget(
        userId: userId,
        targetId: targetId,
      );

      // No record
      if (result == null) {
        print('TARGET RESULT: NULL');

        emit(
          state.copyWith(
            targetStatus: SalesTargetStatus.failure,
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
          targetStatus: SalesTargetStatus.success,
          target: result,
          clearMessage: true,
        ),
      );
    } catch (e) {
      print('TARGET API ERROR: $e');

      emit(
        state.copyWith(
          targetStatus: SalesTargetStatus.failure,
          clearTarget: true,
          message: e.toString(),
        ),
      );
    }
  }
}
