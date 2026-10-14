
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/consultant_doctor.dart';
import '../../domain/usecases/consultant_usecases.dart';

abstract class ConsultantEvent {
  const ConsultantEvent();
}

class LoadConsultants extends ConsultantEvent {
  const LoadConsultants();
}

class SaveConsultant extends ConsultantEvent {
  final ConsultantDoctor doctor;

  const SaveConsultant(this.doctor);
}

enum ConsultantStatus {
  initial,
  loading,
  success,
  saving,
  saved,
  failure,
}

class ConsultantState {
  final ConsultantStatus status;
  final List<ConsultantDoctor> doctors;
  final String message;

  const ConsultantState({
    this.status = ConsultantStatus.initial,
    this.doctors = const [],
    this.message = '',
  });

  ConsultantState copyWith({
    ConsultantStatus? status,
    List<ConsultantDoctor>? doctors,
    String? message,
  }) {
    return ConsultantState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      message: message ?? this.message,
    );
  }
}

class ConsultantBloc
    extends Bloc<ConsultantEvent, ConsultantState> {
  final GetConsultantsUseCase getConsultants;
  final SaveConsultantUseCase saveConsultant;

  ConsultantBloc({
    required this.getConsultants,
    required this.saveConsultant,
  }) : super(const ConsultantState()) {
    on<LoadConsultants>(_load);
    on<SaveConsultant>(_save);
  }

  Future<void> _load(
    LoadConsultants event,
    Emitter<ConsultantState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ConsultantStatus.loading,
        message: '',
      ),
    );

    try {
      final doctors = await getConsultants();

      emit(
        state.copyWith(
          status: ConsultantStatus.success,
          doctors: doctors,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultantStatus.failure,
          message: 'Load failed: $e',
        ),
      );
    }
  }

  Future<void> _save(
    SaveConsultant event,
    Emitter<ConsultantState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ConsultantStatus.saving,
        message: '',
      ),
    );

    try {
      await saveConsultant(event.doctor);

      emit(
        state.copyWith(
          status: ConsultantStatus.saved,
          message: 'Consultant saved successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultantStatus.failure,
          message: 'Save failed: $e',
        ),
      );
    }
  }
}
