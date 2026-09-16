import 'package:equatable/equatable.dart';

import '../../domain/entities/my_expense_entity.dart';

abstract class MyExpenseState extends Equatable {
  const MyExpenseState();

  @override
  List<Object?> get props => [];
}

class MyExpenseInitial extends MyExpenseState {}

class MyExpenseLoading extends MyExpenseState {}

class MyExpenseLoaded extends MyExpenseState {
  final List<MyExpenseEntity> expenses;

  const MyExpenseLoaded({
    required this.expenses,
  });

  @override
  List<Object?> get props => [
        expenses,
      ];
}

class MyExpenseEmpty extends MyExpenseState {}

class MyExpenseError extends MyExpenseState {
  final String message;

  const MyExpenseError({
    required this.message,
  });

  @override
  List<Object?> get props => [
        message,
      ];
}