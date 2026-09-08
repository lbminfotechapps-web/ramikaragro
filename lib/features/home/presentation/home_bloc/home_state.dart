import 'package:equatable/equatable.dart';
import 'package:demo/features/home/doman/home_entity/menu_entity.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<MenuEntity> menus;
  final String? errorMessage;
  final String? totalDealerCount;
  final String? totalFarmerCount;

  const HomeState({
    this.status = HomeStatus.initial,
    this.menus = const [],
    this.errorMessage,
    this.totalDealerCount,
    this.totalFarmerCount,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<MenuEntity>? menus,
    String? errorMessage,
    String? totalDealerCount,
    String? totalFarmerCount,
  }) {
    return HomeState(
      status: status ?? this.status,
      menus: menus ?? this.menus,
      errorMessage: errorMessage ?? this.errorMessage,
      totalDealerCount: totalDealerCount ?? this.totalDealerCount,
      totalFarmerCount: totalFarmerCount ?? this.totalFarmerCount,
    );
  }

  @override
  List<Object?> get props => [
    status,
    menus,
    errorMessage,
    totalDealerCount,
    totalFarmerCount,
  ];
}
