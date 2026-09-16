import 'package:equatable/equatable.dart';

abstract class MyExpenseEvent extends Equatable {
  const MyExpenseEvent();

  @override
  List<Object?> get props => [];
}

class GetMyExpensesEvent extends MyExpenseEvent {
  final int userId;
  final String fromDate;
  final String toDate;
  final int startLimit;

  const GetMyExpensesEvent({
    required this.userId,
    required this.fromDate,
    required this.toDate,
    required this.startLimit,
  });

  @override
  List<Object?> get props => [
        userId,
        fromDate,
        toDate,
        startLimit,
      ];
}