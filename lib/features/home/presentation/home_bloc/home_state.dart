import 'package:solufine/features/home/doman/home_entity/homevisit_entity.dart';
import 'package:solufine/features/home/doman/home_entity/inpunch_pending_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:solufine/features/home/doman/home_entity/menu_entity.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<MenuEntity> menus;
  final String? errorMessage;
  final String? totalDealerCount;
  final String? totalFarmerCount;
  final HomeVisitEntity? homedata;

  final InpunchPendingResponseEntity? data;

  const HomeState({
    this.status = HomeStatus.initial,
    this.menus = const [],
    this.errorMessage,
    this.totalDealerCount,
    this.totalFarmerCount,
    this.homedata,
    this.data,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<MenuEntity>? menus,
    String? errorMessage,
    String? totalDealerCount,
    String? totalFarmerCount,
    HomeVisitEntity? homedata,
    InpunchPendingResponseEntity? data,
  }) {
    return HomeState(
      status: status ?? this.status,
      menus: menus ?? this.menus,
      errorMessage: errorMessage ?? this.errorMessage,
      totalDealerCount: totalDealerCount ?? this.totalDealerCount,
      totalFarmerCount: totalFarmerCount ?? this.totalFarmerCount,
      homedata: homedata ?? this.homedata,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
    status,
    menus,
    errorMessage,
    totalDealerCount,
    totalFarmerCount,
    homedata,
    data,
  ];
}
