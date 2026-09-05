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
