import 'dart:async';

import 'package:demo/features/home/doman/home_usecases/get_menu_usecase.dart';
import 'package:demo/features/home/presentation/home_bloc/home_event.dart';
import 'package:demo/features/home/presentation/home_bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetMenuUsecase getMenuUsecase;

  HomeBloc(this.getMenuUsecase) : super(const HomeState()) {
    on<GetMenuEvent>(_onGetMenus);
    on<VisitGraphCountEvent>(_onGetGraphCount);
    on<GetHomeVisitEvent>(_onGetHomeVisitCount);
  }

  Future<void> _onGetMenus(GetMenuEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final menus = await getMenuUsecase.getMenus(event.userId, event.menuType);
      print('bloc response$menus');
      emit(state.copyWith(status: HomeStatus.success, menus: menus));
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onGetGraphCount(
    VisitGraphCountEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final graphcount = await getMenuUsecase.getVisitCountGraph(
        event.userId,
        event.searchFromDate,
        event.searchToDate,
      );

      debugPrint('GRAPH API RESPONSE: $graphcount');

      final dealerCount =
          int.tryParse(graphcount['tot_dealer_cnt']?.toString() ?? '0') ?? 0;

      final farmerCount =
          int.tryParse(graphcount['tot_farmer_cnt']?.toString() ?? '0') ?? 0;

      emit(
        state.copyWith(
          status: HomeStatus.success,
          totalDealerCount: dealerCount.toString(),
          totalFarmerCount: farmerCount.toString(),
        ),
      );
    } catch (error) {
      debugPrint('GRAPH API ERROR: $error');

      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onGetHomeVisitCount(
    GetHomeVisitEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    final response = await getMenuUsecase.getHomeVisitCount(
      userId: event.userId,
    );
    // if (response.status == true) {
    print("Block Data ++++++> : $response");
    emit(state.copyWith(status: HomeStatus.success, homedata: response));
  }

  // else {
  //   emit(state.copyWith(status: HomeStatus.failure));
  // }
}
