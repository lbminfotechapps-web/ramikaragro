import 'package:equatable/equatable.dart';

import '../../domain/entities/district_entity.dart';
import '../../domain/entities/state_entity.dart';
import '../../domain/entities/taluka_entity.dart';

enum EnquiryStatus {
  initial,
  loading,
  success,
  error,
}

enum SubmitEnquiryStatus {
  initial,
  loading,
  success,
  error,
}

class EnquiryState extends Equatable {
  // ============================================================
  // API STATUS
  // ============================================================

  final EnquiryStatus stateStatus;
  final EnquiryStatus districtStatus;
  final EnquiryStatus talukaStatus;

  final SubmitEnquiryStatus submitStatus;

  // ============================================================
  // DATA
  // ============================================================

  final List<StateEntity> states;
  final List<DistrictEntity> districts;
  final List<TalukaEntity> talukas;

  // ============================================================
  // MESSAGES
  // ============================================================

  final String errorMessage;
  final String submitMessage;

  const EnquiryState({
    this.stateStatus = EnquiryStatus.initial,
    this.districtStatus = EnquiryStatus.initial,
    this.talukaStatus = EnquiryStatus.initial,
    this.submitStatus = SubmitEnquiryStatus.initial,
    this.states = const [],
    this.districts = const [],
    this.talukas = const [],
    this.errorMessage = '',
    this.submitMessage = '',
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  EnquiryState copyWith({
    EnquiryStatus? stateStatus,
    EnquiryStatus? districtStatus,
    EnquiryStatus? talukaStatus,
    SubmitEnquiryStatus? submitStatus,
    List<StateEntity>? states,
    List<DistrictEntity>? districts,
    List<TalukaEntity>? talukas,
    String? errorMessage,
    String? submitMessage,
  }) {
    return EnquiryState(
      stateStatus: stateStatus ?? this.stateStatus,
      districtStatus:
          districtStatus ?? this.districtStatus,
      talukaStatus:
          talukaStatus ?? this.talukaStatus,
      submitStatus:
          submitStatus ?? this.submitStatus,
      states: states ?? this.states,
      districts: districts ?? this.districts,
      talukas: talukas ?? this.talukas,
      errorMessage:
          errorMessage ?? this.errorMessage,
      submitMessage:
          submitMessage ?? this.submitMessage,
    );
  }

  // ============================================================
  // EQUATABLE
  // ============================================================

  @override
  List<Object?> get props => [
        stateStatus,
        districtStatus,
        talukaStatus,
        submitStatus,
        states,
        districts,
        talukas,
        errorMessage,
        submitMessage,
      ];
}