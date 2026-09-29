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
  final String outletId;
  final String collectionTypeId;

  const LoadTargetDatesEvent({
    required this.userId,
    this.outletId = '',
    this.collectionTypeId = '',
  });

  @override
  List<Object?> get props => [
        userId,
        outletId,
        collectionTypeId,
      ];
}

// ============================================================
// SELECT TARGET DATE
// ============================================================

class SelectTargetDateEvent extends DealerTargetEvent {
  final TargetDateEntity selectedDate;
  final String userId;
  final String outletId;
  final String collectionTypeId;

  const SelectTargetDateEvent({
    required this.selectedDate,
    required this.userId,
    this.outletId = '',
    this.collectionTypeId = '',
  });

  @override
  List<Object?> get props => [
        selectedDate,
        userId,
        outletId,
        collectionTypeId,
      ];
}
