import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/target_group_entity.dart';
import '../../domain/usecases/get_self_target.dart';
import '../../domain/usecases/submit_self_target.dart';

import 'self_target_event.dart';
import 'self_target_state.dart';

class SelfTargetBloc
    extends Bloc<SelfTargetEvent, SelfTargetState> {
  final GetSelfTarget getSelfTarget;

  final SubmitSelfTarget submitSelfTarget;

  SelfTargetBloc({
    required this.getSelfTarget,
    required this.submitSelfTarget,
  }) : super(
          const SelfTargetState(),
        ) {
    on<GetSelfTargetEvent>(
      _onGetSelfTarget,
    );

    on<ChangeSelfTargetMonthEvent>(
      _onChangeMonth,
    );

    on<SubmitSelfTargetEvent>(
      _onSubmit,
    );
  }

  // ============================================================
  // GET PRODUCT GROUPS
  // ============================================================

  Future<void> _onGetSelfTarget(
    GetSelfTargetEvent event,
    Emitter<SelfTargetState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            SelfTargetStatus.loading,
        message: '',
      ),
    );

    try {
      final List<TargetGroupEntity> groups =
          await getSelfTarget();

      emit(
        state.copyWith(
          status:
              SelfTargetStatus.success,
          groups:
              groups,
          message:
              '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              SelfTargetStatus.failure,
          message:
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),
        ),
      );
    }
  }

  // ============================================================
  // CHANGE MONTH
  // ============================================================

  void _onChangeMonth(
    ChangeSelfTargetMonthEvent event,
    Emitter<SelfTargetState> emit,
  ) {
    emit(
      state.copyWith(
        selectedMonth:
            event.month,
        status:
            SelfTargetStatus.success,
        message:
            '',
      ),
    );
  }

 // ============================================================
// SUBMIT
// ============================================================

Future<void> _onSubmit(
  SubmitSelfTargetEvent event,
  Emitter<SelfTargetState> emit,
) async {
  // ==========================================================
  // USER VALIDATION
  // ==========================================================

  if (event.userId.trim().isEmpty) {
    emit(
      state.copyWith(
        status:
            SelfTargetStatus.failure,

        message:
            'User information not available',
      ),
    );

    return;
  }

  // // ==========================================================
  // // GROUP VALIDATION
  // // ==========================================================

  // if (event.groupId.trim().isEmpty) {
  //   emit(
  //     state.copyWith(
  //       status:
  //           SelfTargetStatus.failure,

  //       message:
  //           'Please select product group',
  //     ),
  //   );

  //   return;
  // }

  // ==========================================================
  // MONTH VALIDATION
  // ==========================================================

  if (event.month.trim().isEmpty) {
    emit(
      state.copyWith(
        status:
            SelfTargetStatus.failure,

        message:
            'Please select target month',
      ),
    );

    return;
  }

  // ==========================================================
  // POINT VALIDATION
  // ==========================================================

  final String points =
      event.points.trim();

  if (points.isEmpty) {
    emit(
      state.copyWith(
        status:
            SelfTargetStatus.failure,

        message:
            'Please enter target point',
      ),
    );

    return;
  }

  final double? value =
      double.tryParse(
    points,
  );

  if (value == null ||
      value <= 0) {
    emit(
      state.copyWith(
        status:
            SelfTargetStatus.failure,

        message:
            'Please enter valid target point',
      ),
    );

    return;
  }

  // ==========================================================
  // LOADING
  // ==========================================================

  emit(
    state.copyWith(
      status:
          SelfTargetStatus.submitting,

      message:
          '',
    ),
  );

  try {
    debugPrint(
      '========================================',
    );

    debugPrint(
      'SELF TARGET SUBMIT',
    );

    debugPrint(
      'USER ID = ${event.userId}',
    );

    debugPrint(
      'GROUP ID = ${event.groupId}',
    );

    debugPrint(
      'MONTH = ${event.month}',
    );

    debugPrint(
      'POINTS = $points',
    );

    debugPrint(
      '========================================',
    );

    // ========================================================
    // CALL USE CASE
    // ========================================================

    final String result =
        await submitSelfTarget(
      userId:
          event.userId,

      // groupId:
      //     event.groupId,

      month:
          event.month,

      points:
          points,
    );

    // ========================================================
    // SUCCESS
    // ========================================================

    emit(
      state.copyWith(
        status:
            SelfTargetStatus.submitSuccess,

        message:
            result,
      ),
    );
  } catch (e, stackTrace) {
    debugPrint(
      'SELF TARGET SUBMIT ERROR = $e',
    );

    debugPrint(
      '$stackTrace',
    );

    emit(
      state.copyWith(
        status:
            SelfTargetStatus.failure,

        message:
            e
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