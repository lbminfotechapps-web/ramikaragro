import 'package:equatable/equatable.dart';

abstract class FollowupEvent extends Equatable {
  const FollowupEvent();

  @override
  List<Object?> get props => [];
}

class GetUpcomingFollowupEvent
    extends FollowupEvent {
  final String fromDate;
  final String toDate;
  final String type;
  final String userId;

  const GetUpcomingFollowupEvent({
    required this.fromDate,
    required this.toDate,
    required this.type,
    required this.userId,
  });

  @override
  List<Object?> get props => [
        fromDate,
        toDate,
        type,
        userId,
      ];
}