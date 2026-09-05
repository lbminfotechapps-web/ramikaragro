import 'package:equatable/equatable.dart';

import '../../domain/entities/employee_activity.dart';

enum EmployeeActivityStatus {
  initial,
  loading,
  success,
  failure,
}

class EmployeeActivityState
    extends Equatable {

  final EmployeeActivityStatus status;

  final List<EmployeeActivity> activities;

  final String? errorMessage;

  const EmployeeActivityState({
    this.status =
        EmployeeActivityStatus.initial,
    this.activities = const [],
    this.errorMessage,
  });

  EmployeeActivityState copyWith({
    EmployeeActivityStatus? status,
    List<EmployeeActivity>? activities,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return EmployeeActivityState(
      status: status ?? this.status,

      activities:
          activities ?? this.activities,

      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activities,
        errorMessage,
      ];
}