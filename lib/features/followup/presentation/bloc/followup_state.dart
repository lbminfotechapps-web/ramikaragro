import 'package:equatable/equatable.dart';

import '../../domain/entities/followup_entity.dart';

abstract class FollowupState extends Equatable {
  const FollowupState();

  @override
  List<Object?> get props => [];
}

class FollowupInitial extends FollowupState {}

class FollowupLoading extends FollowupState {}

class FollowupSuccess extends FollowupState {
  final List<FollowupEntity> followups;

  const FollowupSuccess({
    required this.followups,
  });

  @override
  List<Object?> get props => [
        followups,
      ];
}

class FollowupEmpty extends FollowupState {
  final String message;

  const FollowupEmpty({
    this.message = 'No followup records found',
  });

  @override
  List<Object?> get props => [
        message,
      ];
}

class FollowupError extends FollowupState {
  final String message;

  const FollowupError({
    required this.message,
  });

  @override
  List<Object?> get props => [
        message,
      ];
}