import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/field_day_entry.dart';
import '../../domain/usecases/field_day_usecases.dart';

abstract class FieldDayEvent {
  const FieldDayEvent();
}

class SubmitFieldDayEvent extends FieldDayEvent {
  final FieldDayEntry entry;
  const SubmitFieldDayEvent(this.entry);
}

class SearchFarmersEvent extends FieldDayEvent {
  final String userId, query;
  const SearchFarmersEvent(this.userId, this.query);
}

class FieldDayState {
  final bool submitting, searching;
  final String? success, error;
  final List<FarmerOption> farmers;
  const FieldDayState({
    this.submitting = false,
    this.searching = false,
    this.success,
    this.error,
    this.farmers = const [],
  });
  FieldDayState copyWith({
    bool? submitting,
    bool? searching,
    String? success,
    String? error,
    List<FarmerOption>? farmers,
    bool clearMessages = false,
  }) => FieldDayState(
    submitting: submitting ?? this.submitting,
    searching: searching ?? this.searching,
    success: clearMessages ? null : success ?? this.success,
    error: clearMessages ? null : error ?? this.error,
    farmers: farmers ?? this.farmers,
  );
}

class FieldDayBloc extends Bloc<FieldDayEvent, FieldDayState> {
  int _searchVersion = 0;
  final SubmitFieldDay submitUsecase;
  final SearchFieldDayFarmers searchUsecase;
  FieldDayBloc(this.submitUsecase, this.searchUsecase)
    : super(const FieldDayState()) {
    on<SubmitFieldDayEvent>((event, emit) async {
      if (state.submitting) return;
      emit(state.copyWith(submitting: true, clearMessages: true));
      try {
        final message = await submitUsecase(event.entry);
        emit(state.copyWith(submitting: false, success: message));
      } catch (e) {
        emit(state.copyWith(submitting: false, error: e.toString()));
      }
    });
    on<SearchFarmersEvent>((event, emit) async {
      final version = ++_searchVersion;
      if (event.query.trim().length < 3) {
        emit(state.copyWith(farmers: [], searching: false));
        return;
      }
      emit(state.copyWith(searching: true, farmers: [], clearMessages: true));
      try {
        final farmers = await searchUsecase(event.userId, event.query);
        if (version != _searchVersion) return;
        emit(state.copyWith(farmers: farmers, searching: false));
      } catch (e) {
        if (version != _searchVersion) return;
        emit(
          state.copyWith(farmers: [], searching: false, error: e.toString()),
        );
      }
    });
  }
}
