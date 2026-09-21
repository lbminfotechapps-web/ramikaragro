import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/check_expense_status_usecase.dart';
import '../../domain/usecases/get_da_amount_usecase.dart';
import '../../domain/usecases/get_expense_days_usecase.dart';
import '../../domain/usecases/get_expense_parameters_usecase.dart';
import '../../domain/usecases/get_expense_vehicle_usecase.dart';

import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpenseVehicleUseCase getVehicles;
  final GetExpenseParametersUseCase getParameters;
  final GetDAAmountUseCase getDAAmount;
  final GetExpenseDaysUseCase getExpenseDays;
  final CheckExpenseStatusUseCase checkStatus;
  final AddExpenseUseCase addExpense;

  ExpenseBloc({
    required this.getVehicles,
    required this.getParameters,
    required this.getDAAmount,
    required this.getExpenseDays,
    required this.checkStatus,
    required this.addExpense,
  }) : super(const ExpenseState()) {
    on<LoadExpenseEvent>(_onLoad);
    on<ChangeExpenseDateEvent>(_onChangeDate);
    on<UpdateExpenseParameterEvent>(_onUpdateExpenseParameter);
    on<SubmitExpenseEvent>(_onSubmit);
  }

  Future<void> _onLoad(
    LoadExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseStatus.loading));

    try {
      final results = await Future.wait([
        getVehicles(userId: event.userId, lastDate: event.date),
        getParameters(userId: event.userId),
        getDAAmount(userId: event.userId, expenseDate: event.date),
        getExpenseDays(userId: event.userId, expenseDate: event.date),
        checkStatus(userId: event.userId, expenseDate: event.date),
      ]);

      final vehicles = results[0] as List;
      final parameters = results[1] as List;
      final da = results[2] as Map<String, dynamic>;
      final days = results[3] as Map<String, dynamic>;

      // ============================================
      // EXPENSE ALLOWED DAYS
      // ============================================

      final result = days['result'];

      final allowedDays = result is List && result.isNotEmpty
          ? int.tryParse(result[0]['allow_day']?.toString() ?? '') ?? 0
          : 0;

      print('========== EXPENSE DAYS DEBUG ==========');
      print('days response: $days');
      print('allowedDays: $allowedDays');
      print('========================================');

      final expStatus = results[4] as int;

      dynamic selectedVehicle;

      for (final vehicle in vehicles) {
        if (vehicle.fldVehicleTypeIdAdmin == vehicle.fldVehicleTypeId) {
          selectedVehicle = vehicle;
          break;
        }
      }

      emit(
        state.copyWith(
          status: ExpenseStatus.loaded,
          vehicles: vehicles.cast(),
          expenses: parameters.cast(),
          selectedVehicle: selectedVehicle,

          expStatus: expStatus,

          // IMPORTANT
          allowedDays: allowedDays,

          localDa: double.tryParse(da['fld_da']?.toString() ?? '') ?? 0,

          nightDa:
              double.tryParse(da['fld_night_halt_da']?.toString() ?? '') ?? 0,

          apiKmLimit:
              double.tryParse(
                da['fld_daily_kilometer_limit']?.toString() ?? '',
              ) ??
              0,

          fldOpeningClosingKm: selectedVehicle?.fldOpeningClosingKm ?? '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ExpenseStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onChangeDate(
    ChangeExpenseDateEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    add(LoadExpenseEvent(userId: event.userId, date: event.date));
  }

  void _onUpdateExpenseParameter(
    UpdateExpenseParameterEvent event,
    Emitter<ExpenseState> emit,
  ) {
    final list = List.of(state.expenses);

    list[event.index] = list[event.index].copyWith(
      amount: event.amount,
      imageFile: event.image,
    );

    emit(state.copyWith(expenses: list));
  }

  Future<void> _onSubmit(
    SubmitExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseStatus.submitting));

    try {
      final success = await addExpense(fields: event.fields);

      if (success) {
        emit(
          state.copyWith(
            status: ExpenseStatus.success,
            successMessage: 'Expense Submit Successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ExpenseStatus.error,
            errorMessage: 'Expense submission failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: ExpenseStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
