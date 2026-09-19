import 'package:equatable/equatable.dart';

class TalukaEntity extends Equatable {
  final String talukaId;
  final String name;

  const TalukaEntity({
    required this.talukaId,
    required this.name,
  });

  @override
  List<Object?> get props => [
        talukaId,
        name,
      ];
}