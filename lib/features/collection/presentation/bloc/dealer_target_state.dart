import 'package:equatable/equatable.dart';

import '../../domain/entities/collection_target_entity.dart';
import '../../domain/entities/target_date_entity.dart';

enum TargetDatesStatus {
  initial,
  loading,
  success,
  failure,
}

enum CollectionTargetStatus {
  initial,
  loading,
  success,
  failure,
}

class DealerTargetState extends Equatable {
  final TargetDatesStatus datesStatus;
  final CollectionTargetStatus targetStatus;

  final List<TargetDateEntity> targetDates;

  final TargetDateEntity? selectedDate;

  final CollectionTargetEntity? target;

  final String? message;

  const DealerTargetState({
    this.datesStatus = TargetDatesStatus.initial,
    this.targetStatus = CollectionTargetStatus.initial,
    this.targetDates = const [],
    this.selectedDate,
    this.target,
    this.message,
  });

  DealerTargetState copyWith({
    TargetDatesStatus? datesStatus,
    CollectionTargetStatus? targetStatus,
    List<TargetDateEntity>? targetDates,
    TargetDateEntity? selectedDate,
    CollectionTargetEntity? target,
    String? message,
    bool clearSelectedDate = false,
    bool clearTarget = false,
    bool clearMessage = false,
  }) {
    return DealerTargetState(
      datesStatus: datesStatus ?? this.datesStatus,

      targetStatus: targetStatus ?? this.targetStatus,

      targetDates: targetDates ?? this.targetDates,

      selectedDate: clearSelectedDate
          ? null
          : selectedDate ?? this.selectedDate,

      target: clearTarget
          ? null
          : target ?? this.target,

      message: clearMessage
          ? null
          : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        datesStatus,
        targetStatus,
        targetDates,
        selectedDate,
        target,
        message,
      ];
}
