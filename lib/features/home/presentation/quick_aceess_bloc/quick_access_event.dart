import 'package:equatable/equatable.dart';

class QuickAccessEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PunchStatEvent extends QuickAccessEvent {
  final int userId;

  PunchStatEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
