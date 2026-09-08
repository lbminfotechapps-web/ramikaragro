import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_employee_activity_details.dart';

import 'employee_activity_event.dart';
import 'employee_activity_state.dart';

class EmployeeActivityBloc
    extends Bloc<
        EmployeeActivityEvent,
        EmployeeActivityState> {

  final GetEmployeeActivityDetails
      getEmployeeActivityDetails;

  EmployeeActivityBloc(
    this.getEmployeeActivityDetails,
  ) : super(
          const EmployeeActivityState(),
        ) {

    on<GetEmployeeActivityEvent>(
      _getEmployeeActivity,
    );
  }

  Future<void> _getEmployeeActivity(
    GetEmployeeActivityEvent event,
    Emitter<EmployeeActivityState> emit,
  ) async {

    print('');
    print('========================================');
    print('BLOC → EMPLOYEE ACTIVITY');
    print('========================================');

    print(
      'User ID     : ${event.userId}',
    );

    print(
      'Search Date : ${event.searchDate}',
    );

    print(
      'Log User ID : ${event.logUserId}',
    );

    print('========================================');

    emit(
      state.copyWith(
        status:
            EmployeeActivityStatus.loading,
        activities: [],
        clearErrorMessage: true,
      ),
    );

    try {

      final activities =
          await getEmployeeActivityDetails(
        userId: event.userId,
        searchDate: event.searchDate,
        logUserId: event.logUserId,
      );

      print('');
      print('========================================');
      print('EMPLOYEE ACTIVITY SUCCESS');
      print('========================================');

      print(
        'Total records : ${activities.length}',
      );

      print('========================================');

      emit(
        state.copyWith(
          status:
              EmployeeActivityStatus.success,
          activities: activities,
          clearErrorMessage: true,
        ),
      );

    } catch (e) {

      print('');
      print('========================================');
      print('EMPLOYEE ACTIVITY FAILURE');
      print('========================================');

      print(e);

      print('========================================');

      emit(
        state.copyWith(
          status:
              EmployeeActivityStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}