import 'dart:io';

class ExpenseParameterEntity {
  final String fldExpId;
  final String fldExpName;
  final String fldImageName;
  final double amount;
  final File? imageFile;

  const ExpenseParameterEntity({
    required this.fldExpId,
    required this.fldExpName,
    required this.fldImageName,
    required this.amount,
    this.imageFile,
  });

  ExpenseParameterEntity copyWith({
    String? fldExpId,
    String? fldExpName,
    String? fldImageName,
    double? amount,
    File? imageFile,
  }) {
    return ExpenseParameterEntity(
      fldExpId: fldExpId ?? this.fldExpId,
      fldExpName: fldExpName ?? this.fldExpName,
      fldImageName: fldImageName ?? this.fldImageName,
      amount: amount ?? this.amount,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
