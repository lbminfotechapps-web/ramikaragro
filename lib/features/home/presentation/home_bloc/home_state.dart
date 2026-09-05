import 'package:equatable/equatable.dart';
import 'package:demo/features/home/doman/home_entity/menu_entity.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<MenuEntity> menus;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.menus = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<MenuEntity>? menus,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      menus: menus ?? this.menus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, menus, errorMessage];
}