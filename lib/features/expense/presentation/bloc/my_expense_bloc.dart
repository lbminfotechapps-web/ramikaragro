import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_my_expenses_usecase.dart';
import 'my_expense_event.dart';
import 'my_expense_state.dart';

class MyExpenseBloc
    extends Bloc<MyExpenseEvent, MyExpenseState> {
  final GetMyExpensesUseCase getMyExpensesUseCase;

  MyExpenseBloc({
    required this.getMyExpensesUseCase,
  }) : super(MyExpenseInitial()) {
    on<GetMyExpensesEvent>(
      _getMyExpenses,
    );
  }

  Future<void> _getMyExpenses(
    GetMyExpensesEvent event,
    Emitter<MyExpenseState> emit,
  ) async {
    emit(MyExpenseLoading());

    try {
      final result =
          await getMyExpensesUseCase(
        userId: event.userId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        startLimit: event.startLimit,
      );

      if (result.isEmpty) {
        emit(MyExpenseEmpty());
        return;
      }

      emit(
        MyExpenseLoaded(
          expenses: result,
        ),
      );
    } catch (e) {
      print(
        'My Expense Error: $e',
      );

      emit(
        MyExpenseError(
          message: e.toString(),
        ),
      );
    }
  }
}