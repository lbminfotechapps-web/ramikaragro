
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/location_entities.dart';
import '../../domain/usecases/location_usecases.dart';

class LocationState {
  final List<StateEntity> states;
  final List<DistrictEntity> districts;
  final List<TalukaEntity> talukas;

  final String? stateId;
  final String? districtId;
  final String? talukaId;

  final bool statesLoading;
  final bool districtsLoading;
  final String error;

  const LocationState({
    this.states = const [],
    this.districts = const [],
    this.talukas = const [],
    this.stateId,
    this.districtId,
    this.talukaId,
    this.statesLoading = false,
    this.districtsLoading = false,
    this.error = '',
  });

  StateEntity? get selectedState {
    for (final item in states) {
      if (item.id == stateId) return item;
    }
    return null;
  }

  DistrictEntity? get selectedDistrict {
    for (final item in districts) {
      if (item.id == districtId) return item;
    }
    return null;
  }

  TalukaEntity? get selectedTaluka {
    for (final item in talukas) {
      if (item.id == talukaId) return item;
    }
    return null;
  }

  LocationState copyWith({
    List<StateEntity>? states,
    List<DistrictEntity>? districts,
    List<TalukaEntity>? talukas,
    String? stateId,
    String? districtId,
    String? talukaId,
    bool resetState = false,
    bool resetDistrict = false,
    bool resetTaluka = false,
    bool? statesLoading,
    bool? districtsLoading,
    String? error,
  }) {
    return LocationState(
      states: states ?? this.states,
      districts: districts ?? this.districts,
      talukas: talukas ?? this.talukas,
      stateId: resetState ? null : stateId ?? this.stateId,
      districtId:
          resetDistrict ? null : districtId ?? this.districtId,
      talukaId: resetTaluka ? null : talukaId ?? this.talukaId,
      statesLoading: statesLoading ?? this.statesLoading,
      districtsLoading:
          districtsLoading ?? this.districtsLoading,
      error: error ?? this.error,
    );
  }
}

class LocationCubit extends Cubit<LocationState> {
  final GetStatesUseCase getStates;
  final GetDistrictsAndTalukasUseCase getDistricts;

  int _requestGeneration = 0;
  String _userId = '';

  LocationCubit({
    required this.getStates,
    required this.getDistricts,
  }) : super(const LocationState());

  Future<void> initialize({
    required String userId,
    String? stateId,
    String? districtId,
    String? talukaId,
  }) async {
    _userId = userId;
    final generation = ++_requestGeneration;

    emit(const LocationState(statesLoading: true));

    try {
      final states = await getStates(userId);

      if (isClosed || generation != _requestGeneration) {
        return;
      }

      final validState = states.any(
        (item) => item.id == stateId,
      );

      emit(
        LocationState(
          states: states,
          stateId: validState ? stateId : null,
        ),
      );

      if (validState && stateId != null) {
        await changeState(
          stateId,
          initialDistrictId: districtId,
          initialTalukaId: talukaId,
        );
      }
    } catch (e) {
      if (isClosed || generation != _requestGeneration) {
        return;
      }

      emit(
        const LocationState().copyWith(
          error: 'Unable to load states: $e',
        ),
      );
    }
  }

  Future<void> changeState(
    String? id, {
    String? initialDistrictId,
    String? initialTalukaId,
  }) async {
    final generation = ++_requestGeneration;

    emit(
      state.copyWith(
        stateId: id,
        resetState: id == null,
        districts: [],
        talukas: [],
        resetDistrict: true,
        resetTaluka: true,
        districtsLoading: id != null,
        error: '',
      ),
    );

    if (id == null) return;

    try {
      final districts = await getDistricts(
        userId: _userId,
        stateId: id,
      );

      if (isClosed || generation != _requestGeneration) {
        return;
      }

      emit(
        state.copyWith(
          districts: districts,
          districtsLoading: false,
        ),
      );

      if (initialDistrictId != null) {
        changeDistrict(
          initialDistrictId,
          initialTalukaId: initialTalukaId,
        );
      }
    } catch (e) {
      if (isClosed || generation != _requestGeneration) {
        return;
      }

      emit(
        state.copyWith(
          districtsLoading: false,
          error: 'Unable to load districts: $e',
        ),
      );
    }
  }

  void changeDistrict(
    String? id, {
    String? initialTalukaId,
  }) {
    DistrictEntity? selected;

    for (final district in state.districts) {
      if (district.id == id) {
        selected = district;
        break;
      }
    }

    final talukas = selected?.talukas ?? <TalukaEntity>[];

    final validTaluka = talukas.any(
      (item) => item.id == initialTalukaId,
    );

    emit(
      state.copyWith(
        districtId: selected?.id,
        resetDistrict: selected == null,
        talukas: talukas,
        talukaId: validTaluka ? initialTalukaId : null,
        resetTaluka: !validTaluka,
        error: '',
      ),
    );
  }

  void changeTaluka(String? id) {
    final valid = state.talukas.any(
      (item) => item.id == id,
    );

    emit(
      state.copyWith(
        talukaId: valid ? id : null,
        resetTaluka: !valid,
        error: '',
      ),
    );
  }
}
