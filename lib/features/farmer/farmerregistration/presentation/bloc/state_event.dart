// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';

class StatesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StateListEvent extends StatesEvent {
  final String userId;
  StateListEvent({required this.userId});
}

class DistrictEvent extends StatesEvent
{
  final String stateId;

  DistrictEvent({required this.stateId});
}