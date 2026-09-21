import 'dart:async';

import 'package:solufine/features/home/doman/home_usecases/get_inpunch_pending_usecase.dart';
import 'package:solufine/features/home/doman/home_usecases/get_menu_usecase.dart';
import 'package:solufine/features/home/presentation/home_bloc/home_event.dart';
import 'package:solufine/features/home/presentation/home_bloc/home_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetMenuUsecase getMenuUsecase;
  final GetInpunchPendingUseCase getInpunchPendingUseCase;

  HomeBloc(this.getMenuUsecase, this.getInpunchPendingUseCase)
    : super(const HomeState()) {
    on<GetMenuEvent>(_onGetMenus);
    on<VisitGraphCountEvent>(_onGetGraphCount);
    on<GetHomeVisitEvent>(_onGetHomeVisitCount);
    on<GetInpunchPendingEvent>(_getInpunchPending);
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

  FutureOr<void> _getInpunchPending(
    GetInpunchPendingEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final result = await getInpunchPendingUseCase.getInpunchPending(
        event.userId,
      );

      print('========================================');
      print('INPUNCH PENDING RESPONSE');
      print('Status: ${result.status}');
      print('Message: ${result.message}');
      print(
        'Total Recursive Employee: '
        '${result.totalRecursiveEmployee}',
      );
      print(
        'Pending Inpunch Count: '
        '${result.pendingInpunchCount}',
      );
      print('Inpunch Time: ${result.inpunchTime}');
      print('Address: ${result.address}');
      print('Result List Size: ${result.result.length}');
      print('========================================');

      emit(state.copyWith(status: HomeStatus.success, data: result));
    } catch (e) {
      debugPrint('INPUNCH PENDING API ERROR: $e');

      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
