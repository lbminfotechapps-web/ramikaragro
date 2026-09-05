import 'package:equatable/equatable.dart';

class AssignEmployee extends Equatable {
  final dynamic fldId;
  final String fldAdmName;

  const AssignEmployee({
    required this.fldId,
    required this.fldAdmName,
  });

  @override
  List<Object?> get props => [
        fldId,
        fldAdmName,
      ];
}