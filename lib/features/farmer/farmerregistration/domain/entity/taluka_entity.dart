import 'package:equatable/equatable.dart';

class TalukaEntity extends Equatable {
  final String fldDiscId;
  final String fldTalukaId;
  final String fldName;

  const TalukaEntity({
    required this.fldDiscId,
    required this.fldTalukaId,
    required this.fldName,
  });

  @override
  List<Object?> get props => [
        fldDiscId,
        fldTalukaId,
        fldName,
      ];
}