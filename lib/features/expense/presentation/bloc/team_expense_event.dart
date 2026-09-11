import 'package:equatable/equatable.dart';

abstract class TeamExpenseEvent extends Equatable {
  const TeamExpenseEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// GET TEAM EXPENSES
// ============================================================================

class GetTeamExpensesEvent extends TeamExpenseEvent {
  final int userId;
  final String fromDate;
  final String toDate;
  final String searchText;
  final int startLimit;
  final bool isLoadMore;

  const GetTeamExpensesEvent({
    required this.userId,
    required this.fromDate,
    required this.toDate,
    required this.searchText,
    required this.startLimit,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [
        userId,
        fromDate,
        toDate,
        searchText,
        startLimit,
        isLoadMore,
      ];
}

// ============================================================================
// APPROVE / REJECT TEAM EXPENSE
// ============================================================================

class UpdateTeamExpenseEvent extends TeamExpenseEvent {
  final int userId;
  final String expenseId;
  final String status;

  const UpdateTeamExpenseEvent({
    required this.userId,
    required this.expenseId,
    required this.status,
  });

  @override
  List<Object?> get props => [
        userId,
        expenseId,
        status,
      ];
}