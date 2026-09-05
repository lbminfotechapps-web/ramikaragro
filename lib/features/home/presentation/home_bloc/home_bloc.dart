import 'dart:async';

import 'package:demo/features/home/doman/home_usecases/get_menu_usecase.dart';
import 'package:demo/features/home/presentation/home_bloc/home_event.dart';
import 'package:demo/features/home/presentation/home_bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetMenuUsecase getMenuUsecase;

  HomeBloc(this.getMenuUsecase) : super(const HomeState()) {
    on<GetMenuEvent>(_onGetMenus);
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
}
