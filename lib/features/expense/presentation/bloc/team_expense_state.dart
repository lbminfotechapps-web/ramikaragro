import 'package:equatable/equatable.dart';

import '../../domain/entities/team_expense_entity.dart';

abstract class TeamExpenseState extends Equatable {
  const TeamExpenseState();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// INITIAL
// ============================================================================

class TeamExpenseInitial extends TeamExpenseState {}

// ============================================================================
// LOADING
// ============================================================================

class TeamExpenseLoading extends TeamExpenseState {}

// ============================================================================
// LOADED
// ============================================================================

class TeamExpenseLoaded extends TeamExpenseState {
  final List<TeamExpenseEntity> expenses;
  final bool isLoadingMore;
  final bool hasReachedEnd;

  const TeamExpenseLoaded({
    required this.expenses,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
  });

  @override
  List<Object?> get props => [
        expenses,
        isLoadingMore,
        hasReachedEnd,
      ];
}

// ============================================================================
// EMPTY
// ============================================================================

class TeamExpenseEmpty extends TeamExpenseState {}

// ============================================================================
// ERROR
// ============================================================================

class TeamExpenseError extends TeamExpenseState {
  final String message;

  const TeamExpenseError(this.message);

  @override
  List<Object?> get props => [
        message,
      ];
}

// ============================================================================
// UPDATE LOADING
// ============================================================================

class TeamExpenseUpdateLoading extends TeamExpenseState {
  final List<TeamExpenseEntity> expenses;
  final String expenseId;

  const TeamExpenseUpdateLoading({
    required this.expenses,
    required this.expenseId,
  });

  @override
  List<Object?> get props => [
        expenses,
        expenseId,
      ];
}

// ============================================================================
// UPDATE SUCCESS
// ============================================================================

class TeamExpenseUpdateSuccess extends TeamExpenseState {
  final List<TeamExpenseEntity> expenses;
  final String message;

  const TeamExpenseUpdateSuccess({
    required this.expenses,
    required this.message,
  });

  @override
  List<Object?> get props => [
        expenses,
        message,
      ];
}

// ============================================================================
// UPDATE ERROR
// ============================================================================

class TeamExpenseUpdateError extends TeamExpenseState {
  final List<TeamExpenseEntity> expenses;
  final String message;

  const TeamExpenseUpdateError({
    required this.expenses,
    required this.message,
  });

  @override
  List<Object?> get props => [
        expenses,
        message,
      ];
}