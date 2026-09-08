import 'dart:convert';

import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/features/scheme/data/model/statedata.dart';
import 'package:demo/features/scheme/domain/usercases/schemeusecase.dart';
import 'package:demo/features/scheme/presentation/bloc/scheme_event.dart';
import 'package:demo/features/scheme/presentation/bloc/scheme_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchemeBloc extends Bloc<SchemeEvent, SchemeState> {
  final GetSchemeUseCase getSchemeUseCase;

  SchemeBloc({required this.getSchemeUseCase}) : super(const SchemeInitial()) {
    on<LoadAssignedStatesEvent>(_onLoadAssignedStates);

    on<GetSchemeEvent>(_onGetScheme);
  }

  // ============================================================
  // LOAD ASSIGNED STATES
  // ============================================================

  Future<void> _onLoadAssignedStates(
    LoadAssignedStatesEvent event,
    Emitter<SchemeState> emit,
  ) async {
    emit(const SchemeStatesLoading());
    try {
      final userData = await SecureStorage.instance.getUserData();
      final String assignedStates = userData!['assignedStates'];

      if (assignedStates.isEmpty) {
        emit(const SchemeStatesLoaded(states: [], selectedState: null));

        return;
      }

      final List<dynamic> jsonList = jsonDecode(assignedStates);

      final List<Statedata> states = jsonList
          .map((e) => Statedata.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      Statedata? selectedState;

      if (states.isNotEmpty) {
        selectedState = states.first;
      }

      print('Assigned States: $states');

      print(
        'Selected State: '
        '${selectedState?.stateName}',
      );

      print(
        'Selected State ID: '
        '${selectedState?.stateId}',
      );

      emit(SchemeStatesLoaded(states: states, selectedState: selectedState));
    } catch (e) {
      print('LoadAssignedStates Error: $e');

      emit(const SchemeStatesLoaded(states: [], selectedState: null));
    }
  }

  // ============================================================
  // GET SCHEME
  // ============================================================

  Future<void> _onGetScheme(
    GetSchemeEvent event,
    Emitter<SchemeState> emit,
  ) async {
    emit(const SchemeLoading());

    try {
      print('Get Scheme Request:');

      print('Year: ${event.year}');

      print('Month: ${event.month}');

      print('State ID: ${event.stateId}');

      final schemes = await getSchemeUseCase(
        year: event.year,
        month: event.month,
        stateId: event.stateId,
      );

      print('Scheme Count: ${schemes.length}');

      emit(SchemeLoaded(schemes: schemes));
    } catch (e) {
      print('GetScheme Error: $e');

      emit(const SchemeError(message: 'Something went wrong'));
    }
  }
}
