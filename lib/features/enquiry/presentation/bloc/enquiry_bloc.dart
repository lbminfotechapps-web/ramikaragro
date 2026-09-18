import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_districts_usecase.dart';
import '../../domain/usecases/get_states_usecase.dart';
import '../../domain/usecases/get_talukas_usecase.dart';
import '../../domain/usecases/submit_enquiry_usecase.dart';

import 'enquiry_event.dart';
import 'enquiry_state.dart';

class EnquiryBloc extends Bloc<EnquiryEvent, EnquiryState> {
  final GetStatesUseCase getStatesUseCase;
  final GetDistrictsUseCase getDistrictsUseCase;
  final GetTalukasUseCase getTalukasUseCase;
  final SubmitEnquiryUseCase submitEnquiryUseCase;

  EnquiryBloc({
    required this.getStatesUseCase,
    required this.getDistrictsUseCase,
    required this.getTalukasUseCase,
    required this.submitEnquiryUseCase,
  }) : super(const EnquiryState()) {
    // ============================================================
    // EVENTS
    // ============================================================

    on<GetStatesEvent>(_onGetStates);
    on<GetDistrictsEvent>(_onGetDistricts);
    on<GetTalukasEvent>(_onGetTalukas);
    on<SubmitEnquiryEvent>(_onSubmitEnquiry);
  }

  // ============================================================
  // GET STATES
  // ============================================================

  Future<void> _onGetStates(
    GetStatesEvent event,
    Emitter<EnquiryState> emit,
  ) async {
    emit(
      state.copyWith(
        stateStatus: EnquiryStatus.loading,
        errorMessage: '',
      ),
    );

    try {
      final states = await getStatesUseCase(
        userId: event.userId,
      );

      emit(
        state.copyWith(
          stateStatus: EnquiryStatus.success,
          states: states,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          stateStatus: EnquiryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // GET DISTRICTS
  // ============================================================

  Future<void> _onGetDistricts(
    GetDistrictsEvent event,
    Emitter<EnquiryState> emit,
  ) async {
    emit(
      state.copyWith(
        districtStatus: EnquiryStatus.loading,
        districts: const [],
        talukas: const [],
        talukaStatus: EnquiryStatus.initial,
        errorMessage: '',
      ),
    );

    try {
      final districts = await getDistrictsUseCase(
        userId: event.userId,
        stateId: event.stateId,
      );

      emit(
        state.copyWith(
          districtStatus: EnquiryStatus.success,
          districts: districts,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          districtStatus: EnquiryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // GET TALUKAS
  // ============================================================

  Future<void> _onGetTalukas(
    GetTalukasEvent event,
    Emitter<EnquiryState> emit,
  ) async {
    emit(
      state.copyWith(
        talukaStatus: EnquiryStatus.loading,
        talukas: const [],
        errorMessage: '',
      ),
    );

    try {
      final talukas = await getTalukasUseCase(
        userId: event.userId,
        districtId: event.districtId,
      );

      emit(
        state.copyWith(
          talukaStatus: EnquiryStatus.success,
          talukas: talukas,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          talukaStatus: EnquiryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // SUBMIT ENQUIRY
  // ============================================================

  Future<void> _onSubmitEnquiry(
    SubmitEnquiryEvent event,
    Emitter<EnquiryState> emit,
  ) async {
    emit(
      state.copyWith(
        submitStatus: SubmitEnquiryStatus.loading,
        submitMessage: '',
      ),
    );

    try {
      final response = await submitEnquiryUseCase(
        params: event.params,
      );

      if (response.status) {
        emit(
          state.copyWith(
            submitStatus: SubmitEnquiryStatus.success,
            submitMessage: response.message.isNotEmpty
                ? response.message
                : 'Record Submitted Successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            submitStatus: SubmitEnquiryStatus.error,
            submitMessage: response.message.isNotEmpty
                ? response.message
                : 'Something Went Wrong',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          submitStatus: SubmitEnquiryStatus.error,
          submitMessage: e.toString(),
        ),
      );
    }
  }
}