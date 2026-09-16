import 'package:demo/features/sales_targrt_achievement/domain/entities/sales_target_entity.dart';
import 'package:equatable/equatable.dart';


import '../../domain/entities/target_date_entity.dart';

enum TargetDatesStatus {
  initial,
  loading,
  success,
  failure,
}

enum SalesTargetStatus {
  initial,
  loading,
  success,
  failure,
}

class SalesTargetState extends Equatable {
  final TargetDatesStatus datesStatus;
  final SalesTargetStatus targetStatus;

  final List<SalesTargetDateEntity> targetDates;

  final SalesTargetDateEntity? selectedDate;

  final SalesTargetEntity? target;

  final String? message;

  const SalesTargetState({
    this.datesStatus = TargetDatesStatus.initial,
    this.targetStatus = SalesTargetStatus.initial,
    this.targetDates = const [],
    this.selectedDate,
    this.target,
    this.message,
  });

  SalesTargetState copyWith({
    TargetDatesStatus? datesStatus,
    SalesTargetStatus? targetStatus,
    List<SalesTargetDateEntity>? targetDates,
    SalesTargetDateEntity? selectedDate,
    SalesTargetEntity? target,
    String? message,
    bool clearSelectedDate = false,
    bool clearTarget = false,
    bool clearMessage = false,
  }) {
    return SalesTargetState(
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
