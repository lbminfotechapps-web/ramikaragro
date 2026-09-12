import 'package:equatable/equatable.dart';

class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetMenuEvent extends HomeEvent {
  final int userId;
  final String menuType;

  GetMenuEvent(this.userId, this.menuType);
}

class VisitGraphCountEvent extends HomeEvent {
  final int userId;
  final String searchFromDate;
  final String searchToDate;

  VisitGraphCountEvent(this.userId, this.searchFromDate, this.searchToDate);
}

class GetHomeVisitEvent extends HomeEvent {
  final String userId;

  GetHomeVisitEvent(this.userId);
}
