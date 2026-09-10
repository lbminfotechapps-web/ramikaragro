import 'dart:async';

import 'package:demo/features/farmer/farmerregistration/domain/repository/farmerregistration_repo.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/state_event.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/states_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StateBloc extends Bloc<StatesEvent, StatsState> {
  final FarmerregistrationRepository repositoryProvider;

  StateBloc({required this.repositoryProvider}) : super(StatsState()) {
    on<StateListEvent>(_onStateListGet);
    on<DistrictEvent>(_onDistrictGet);
  }

  Future<void> _onStateListGet(
    StateListEvent event,
    Emitter<StatsState> emit,
  ) async {
    print('================================');
    print('STATE API CALLED');
    print('USER ID: ${event.userId}');
    print('================================');

    emit(state.copyWith(status: StatesStatus.initial));

    try {
      final response = await repositoryProvider.getStates(event.userId);

      print('REPOSITORY RESPONSE LENGTH: ${response.length}');

      for (final item in response) {
        print(
          'REPOSITORY ITEM -> ID: ${item.stateId} | NAME: ${item.stateName}',
        );
      }

      if (response.isEmpty) {
        print('STATE RESPONSE EMPTY');

        emit(state.copyWith(status: StatesStatus.failed, statentity: []));

        return;
      }

      emit(state.copyWith(status: StatesStatus.sucess, statentity: response));

      print('================================');
      print('BLOC STATUS: SUCCESS');
      print('BLOC STATE COUNT: ${state.statentity.length}');
      print('================================');
    } catch (e, stackTrace) {
      print('STATE BLOC ERROR: $e');
      print(stackTrace);

      emit(state.copyWith(status: StatesStatus.failed, statentity: []));
    }
  }

  Future<void> _onDistrictGet(
    DistrictEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(status: StatesStatus.initial));
  }
}
