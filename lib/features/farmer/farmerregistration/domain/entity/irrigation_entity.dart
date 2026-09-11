import 'package:equatable/equatable.dart';

class IrrigationEntity extends Equatable {
  final String fldId;
  final String fldIrrigationName;

  const IrrigationEntity({
    required this.fldId,
    required this.fldIrrigationName,
  });

  @override
  List<Object?> get props => [
        fldId,
        fldIrrigationName,
      ];
}