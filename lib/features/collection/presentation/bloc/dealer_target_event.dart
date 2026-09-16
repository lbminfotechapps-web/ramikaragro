import 'package:equatable/equatable.dart';

import '../../domain/entities/target_date_entity.dart';

abstract class DealerTargetEvent extends Equatable {
  const DealerTargetEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// LOAD TARGET DATES
// ============================================================

class LoadTargetDatesEvent extends DealerTargetEvent {
  final String userId;

  const LoadTargetDatesEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [
        userId,
      ];
}

// ============================================================
// SELECT TARGET DATE
// ============================================================

class SelectTargetDateEvent extends DealerTargetEvent {
  final TargetDateEntity selectedDate;
  final String userId;

  const SelectTargetDateEvent({
    required this.selectedDate,
    required this.userId,
  });

  @override
  List<Object?> get props => [
        selectedDate,
        userId,
      ];
}
