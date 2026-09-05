import 'package:equatable/equatable.dart';

abstract class NotVisitedDealerEvent extends Equatable {
  const NotVisitedDealerEvent();

  @override
  List<Object?> get props => [];
}

// =============================================================
// FIRST PAGE / REFRESH
// =============================================================

class GetNotVisitedDealersEvent extends NotVisitedDealerEvent {
  final int days;
  final int startLimit;

  const GetNotVisitedDealersEvent({
    required this.days,
    required this.startLimit,
  });

  @override
  List<Object?> get props => [
        days,
        startLimit,
      ];
}

// =============================================================
// LOAD MORE
// =============================================================

class GetMoreNotVisitedDealersEvent extends NotVisitedDealerEvent {
  final int days;

  const GetMoreNotVisitedDealersEvent({
    required this.days,
  });

  @override
  List<Object?> get props => [
        days,
      ];
}