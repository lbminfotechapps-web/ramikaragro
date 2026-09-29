import '../../domain/entities/target_group_entity.dart';

enum SelfTargetStatus {
  initial,
  loading,
  success,
  submitting,
  submitSuccess,
  failure,
}

class SelfTargetState {
  final SelfTargetStatus status;

  final List<TargetGroupEntity> groups;

  final String selectedMonth;

  final String message;

  const SelfTargetState({
    this.status =
        SelfTargetStatus.initial,

    this.groups =
        const [],

    this.selectedMonth =
        '',

    this.message =
        '',
  });

  SelfTargetState copyWith({
    SelfTargetStatus? status,

    List<TargetGroupEntity>? groups,

    String? selectedMonth,

    String? message,
  }) {
    return SelfTargetState(
      status:
          status ?? this.status,

      groups:
          groups ?? this.groups,

      selectedMonth:
          selectedMonth ??
          this.selectedMonth,

      message:
          message ?? this.message,
    );
  }
}