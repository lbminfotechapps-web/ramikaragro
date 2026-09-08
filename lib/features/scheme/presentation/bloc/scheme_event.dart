import 'package:equatable/equatable.dart';

abstract class SchemeEvent extends Equatable {
  const SchemeEvent();

  @override
  List<Object?> get props => [];
}

/// Load assigned states from local session
class LoadAssignedStatesEvent extends SchemeEvent {
  const LoadAssignedStatesEvent();
}

/// Get schemes from API
class GetSchemeEvent extends SchemeEvent {
  final String year;
  final String month;
  final String stateId;

  const GetSchemeEvent({
    required this.year,
    required this.month,
    required this.stateId,
  });

  @override
  List<Object?> get props => [year, month, stateId];
}
