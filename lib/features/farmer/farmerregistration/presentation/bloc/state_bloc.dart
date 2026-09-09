import 'dart:async';

import 'package:demo/features/farmer/farmerregistration/presentation/bloc/state_event.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/states_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StateBloc extends Bloc<StatesEvent, StatsState> {
  StateBloc() : super(StatsState()) {
    on<StateListEvent>(_onStateListGet);
  }

  FutureOr<void> _onStateListGet(
    StateListEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(status: StatesStatus.initial));
  }

  Future<void> _onDistrictGet(
    DistrictEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(status: StatesStatus.initial));
  }
}
