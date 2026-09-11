import 'package:equatable/equatable.dart';

class TeamExpenseDetailEntity extends Equatable {
  final String expId;
  final String expenseId;
  final String amount;
  final String expenseRemark;
  final String expenseImage;
  final String expName;

  const TeamExpenseDetailEntity({
    required this.expId,
    required this.expenseId,
    required this.amount,
    required this.expenseRemark,
    required this.expenseImage,
    required this.expName,
  });

  @override
  List<Object?> get props => [
        expId,
        expenseId,
        amount,
        expenseRemark,
        expenseImage,
        expName,
      ];
}