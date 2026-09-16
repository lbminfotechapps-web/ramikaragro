import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenseEvent extends ExpenseEvent {
  final String userId;
  final String date;

  const LoadExpenseEvent({required this.userId, required this.date});

  @override
  List<Object?> get props => [userId, date];
}

class ChangeExpenseDateEvent extends ExpenseEvent {
  final String userId;
  final String date;

  const ChangeExpenseDateEvent({required this.userId, required this.date});

  @override
  List<Object?> get props => [userId, date];
}

class UpdateExpenseParameterEvent extends ExpenseEvent {
  final int index;
  final double amount;
  final File? image;

  const UpdateExpenseParameterEvent({
    required this.index,
    required this.amount,
    this.image,
  });

  @override
  List<Object?> get props => [index, amount, image];
}

class SubmitExpenseEvent extends ExpenseEvent {
  final Map<String, String> fields;

  const SubmitExpenseEvent({required this.fields});

  @override
  List<Object?> get props => [fields];
}
