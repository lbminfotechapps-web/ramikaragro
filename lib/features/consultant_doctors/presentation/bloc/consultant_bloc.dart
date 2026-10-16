
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/consultant_doctor.dart';
import '../../domain/usecases/consultant_usecases.dart';
import '../../domain/usecases/add_doctor_usecase.dart';
import '../../domain/usecases/get_remote_consultants_usecase.dart';

// ==========================================================
// EVENTS
// ==========================================================

abstract class ConsultantEvent {
  const ConsultantEvent();
}

class LoadConsultants extends ConsultantEvent {
  final String userId;
  final String search;
  final String districtId;
  final String talukaId;

  const LoadConsultants({
    required this.userId,
    this.search = '',
    this.districtId = '',
    this.talukaId = '',
  });
}

class SaveConsultant extends ConsultantEvent {
  final ConsultantDoctor doctor;

  const SaveConsultant(this.doctor);
}

class AddDoctor extends ConsultantEvent {
  final String userId;
  final ConsultantDoctor consultant;
  final String remark;

  const AddDoctor({
    required this.userId,
    required this.consultant,
    required this.remark,
  });
}

// ==========================================================
// STATUS
// ==========================================================

enum ConsultantStatus {
  initial,
  loading,
  success,
  saving,
  saved,
  failure,
}

// ==========================================================
// STATE
// ==========================================================

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

// ==========================================================
// BLOC
// ==========================================================

class ConsultantBloc
    extends Bloc<ConsultantEvent, ConsultantState> {
  final GetRemoteConsultantsUseCase getRemoteConsultants;
  final SaveConsultantUseCase saveConsultant;
  final AddDoctorUseCase addDoctor;

  ConsultantBloc({
    required this.getRemoteConsultants,
    required this.saveConsultant,
    required this.addDoctor,
  }) : super(const ConsultantState()) {
    on<LoadConsultants>(_onLoadConsultants);
    on<SaveConsultant>(_onSaveConsultant);
    on<AddDoctor>(_onAddDoctor);
  }

  // ========================================================
  // LOAD SERVER DOCTOR LIST
  // ========================================================

  Future<void> _onLoadConsultants(
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
      final doctors = await getRemoteConsultants(
        userId: event.userId,
        search: event.search,
        districtId: event.districtId,
        talukaId: event.talukaId,
      );

      debugPrint('DOCTOR API COUNT: ${doctors.length}');

      emit(
        state.copyWith(
          status: ConsultantStatus.success,
          doctors: doctors,
          message: '',
        ),
      );
    } catch (error) {
      debugPrint('DOCTOR LIST API ERROR: $error');

      emit(
        state.copyWith(
          status: ConsultantStatus.failure,
          doctors: const [],
          message: _message(error),
        ),
      );
    }
  }

  // ========================================================
  // EXISTING SAVE EVENT
  // ========================================================

  Future<void> _onSaveConsultant(
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
          message: 'Consultant saved successfully.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ConsultantStatus.failure,
          message: _message(error),
        ),
      );
    }
  }

  // ========================================================
  // EXISTING ADD DOCTOR API
  // ========================================================

  Future<void> _onAddDoctor(
    AddDoctor event,
    Emitter<ConsultantState> emit,
  ) async {
    if (state.status == ConsultantStatus.saving) return;

    emit(
      state.copyWith(
        status: ConsultantStatus.saving,
        message: '',
      ),
    );

    try {
      final response = await addDoctor(
        userId: event.userId,
        consultant: event.consultant,
        remark: event.remark,
      );

      final doctor = event.consultant;

      final savedDoctor = ConsultantDoctor(
        id: response.doctorId,
        doctorName: doctor.doctorName,
        ownerName: doctor.ownerName,
        mobile: doctor.mobile,
        address: doctor.address,
        stateId: doctor.stateId,
        stateName: doctor.stateName,
        districtId: doctor.districtId,
        districtName: doctor.districtName,
        talukaId: doctor.talukaId,
        talukaName: doctor.talukaName,
        remark: event.remark,
        createdBy: event.userId,
        createdAt: doctor.createdAt,
      );

      // Retain local-save compatibility with existing form.
      // The list will never read from this cache.
      try {
        await saveConsultant(savedDoctor);
      } catch (error) {
        debugPrint('LOCAL SAVE WARNING: $error');
      }

      emit(
        state.copyWith(
          status: ConsultantStatus.saved,
          message: response.message.isNotEmpty
              ? response.message
              : 'Doctor added successfully.',
        ),
      );
    } catch (error) {
      debugPrint('ADD DOCTOR ERROR: $error');

      emit(
        state.copyWith(
          status: ConsultantStatus.failure,
          message: _message(error),
        ),
      );
    }
  }

  String _message(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
