import 'package:demo/features/scheme/data/model/statedata.dart';
import 'package:demo/features/scheme/domain/entity/scheme_entity.dart';
import 'package:equatable/equatable.dart';

abstract class SchemeState extends Equatable {
  const SchemeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SchemeInitial extends SchemeState {
  const SchemeInitial();
}

/// Assigned states loading
class SchemeStatesLoading extends SchemeState {
  const SchemeStatesLoading();
}

/// Assigned states loaded
class SchemeStatesLoaded extends SchemeState {
  final List<Statedata> states;
  final Statedata? selectedState;

  const SchemeStatesLoaded({required this.states, this.selectedState});

  @override
  List<Object?> get props => [states, selectedState];
}

/// Scheme API loading
class SchemeLoading extends SchemeState {
  const SchemeLoading();
}

/// Scheme API loaded
class SchemeLoaded extends SchemeState {
  final List<SchemeEntity> schemes;

  const SchemeLoaded({required this.schemes});

  @override
  List<Object?> get props => [schemes];
}

/// Scheme error
class SchemeError extends SchemeState {
  final String message;

  const SchemeError({required this.message});

  @override
  List<Object?> get props => [message];
}
