import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/team_expense_entity.dart';
import '../../domain/usecases/get_team_expenses_usecase.dart';
import '../../domain/usecases/update_team_expense_usecase.dart';
import 'team_expense_event.dart';
import 'team_expense_state.dart';

class TeamExpenseBloc
    extends Bloc<TeamExpenseEvent, TeamExpenseState> {
  final GetTeamExpensesUsecase getTeamExpensesUsecase;
  final UpdateTeamExpenseUsecase updateTeamExpenseUsecase;

  TeamExpenseBloc({
    required this.getTeamExpensesUsecase,
    required this.updateTeamExpenseUsecase,
  }) : super(TeamExpenseInitial()) {
    on<GetTeamExpensesEvent>(_getTeamExpenses);
    on<UpdateTeamExpenseEvent>(_updateTeamExpense);
  }

  // ============================================================
  // GET TEAM EXPENSES
  // ============================================================

  Future<void> _getTeamExpenses(
    GetTeamExpensesEvent event,
    Emitter<TeamExpenseState> emit,
  ) async {
    final currentState = state;

    if (!event.isLoadMore) {
      emit(TeamExpenseLoading());
    } else {
      if (currentState is TeamExpenseLoaded) {
        emit(
          TeamExpenseLoaded(
            expenses: currentState.expenses,
            isLoadingMore: true,
            hasReachedEnd: currentState.hasReachedEnd,
          ),
        );
      }
    }

    try {
      final newExpenses = await getTeamExpensesUsecase(
        userId: event.userId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        searchText: event.searchText,
        startLimit: event.startLimit,
      );

      // ========================================================
      // LOAD MORE
      // ========================================================

      if (event.isLoadMore &&
          currentState is TeamExpenseLoaded) {
        final allExpenses = [
          ...currentState.expenses,
          ...newExpenses,
        ];

        emit(
          TeamExpenseLoaded(
            expenses: allExpenses,
            isLoadingMore: false,
            hasReachedEnd: newExpenses.isEmpty,
          ),
        );
      }

      // ========================================================
      // FIRST LOAD / SEARCH
      // ========================================================

      else {
        if (newExpenses.isEmpty) {
          emit(TeamExpenseEmpty());
        } else {
          emit(
            TeamExpenseLoaded(
              expenses: newExpenses,
              isLoadingMore: false,
              hasReachedEnd: false,
            ),
          );
        }
      }
    } catch (e) {
      emit(
        TeamExpenseError(
          e.toString().replaceFirst(
                'Exception: ',
                '',
              ),
        ),
      );
    }
  }

  // ============================================================
  // APPROVE / REJECT EXPENSE
  // ============================================================


Future<void> _updateTeamExpense(
  UpdateTeamExpenseEvent event,
  Emitter<TeamExpenseState> emit,
) async {
  final currentState = state;

  List<TeamExpenseEntity> currentExpenses = [];

  if (currentState is TeamExpenseLoaded) {
    currentExpenses = currentState.expenses;
  } else if (currentState is TeamExpenseUpdateLoading) {
    currentExpenses = currentState.expenses;
  } else if (currentState is TeamExpenseUpdateSuccess) {
    currentExpenses = currentState.expenses;
  } else if (currentState is TeamExpenseUpdateError) {
    currentExpenses = currentState.expenses;
  }

  try {
    // ============================================================
    // SHOW BUTTON LOADER
    // ============================================================

    emit(
      TeamExpenseUpdateLoading(
        expenses: List<TeamExpenseEntity>.from(
          currentExpenses,
        ),
        expenseId: event.expenseId,
      ),
    );

    // ============================================================
    // CALL UPDATE API
    // ============================================================

    final response = await updateTeamExpenseUsecase(
      userId: event.userId,
      expenseId: event.expenseId,
      expenseJson: event.expenseJson,
      expenseStatus: event.status,
      remark: event.remark,
    );

    debugPrint(
      '==========================================',
    );
    debugPrint(
      'TEAM EXPENSE UPDATE RESPONSE: $response',
    );
    debugPrint(
      'USER ID: ${event.userId}',
    );
    debugPrint(
      'EXPENSE ID: ${event.expenseId}',
    );
    debugPrint(
      'STATUS: ${event.status}',
    );
    debugPrint(
      'EXPENSE JSON: ${event.expenseJson}',
    );
    debugPrint(
      'REMARK: ${event.remark}',
    );
    debugPrint(
      '==========================================',
    );

    // ============================================================
    // SUCCESS MESSAGE
    // ============================================================

    String message;

    if (event.status == '1') {
      message = 'Expense approved successfully';
    } else if (event.status == '2') {
      message = 'Expense rejected successfully';
    } else {
      message = 'Expense updated successfully';
    }

    // ============================================================
    // SUCCESS STATE
    // ============================================================

    emit(
      TeamExpenseUpdateSuccess(
        expenses: List<TeamExpenseEntity>.from(
          currentExpenses,
        ),
        message: message,
      ),
    );
  } catch (e) {
    debugPrint(
      'TEAM EXPENSE UPDATE ERROR: $e',
    );

    // ============================================================
    // ERROR STATE
    // ============================================================

    emit(
      TeamExpenseUpdateError(
        expenses: List<TeamExpenseEntity>.from(
          currentExpenses,
        ),
        message: e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      ),
    );
  }
}


}