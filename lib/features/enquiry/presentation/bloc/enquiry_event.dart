import 'package:equatable/equatable.dart';

abstract class EnquiryEvent extends Equatable {
  const EnquiryEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// GET STATES
// ============================================================

class GetStatesEvent extends EnquiryEvent {
  final String userId;

  const GetStatesEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [
        userId,
      ];
}

// ============================================================
// GET DISTRICTS
// ============================================================

class GetDistrictsEvent extends EnquiryEvent {
  final String userId;
  final String stateId;

  const GetDistrictsEvent({
    required this.userId,
    required this.stateId,
  });

  @override
  List<Object?> get props => [
        userId,
        stateId,
      ];
}

// ============================================================
// GET TALUKAS
// ============================================================

class GetTalukasEvent extends EnquiryEvent {
  final String userId;
  final String districtId;

  const GetTalukasEvent({
    required this.userId,
    required this.districtId,
  });

  @override
  List<Object?> get props => [
        userId,
        districtId,
      ];
}

// ============================================================
// SUBMIT ENQUIRY
// ============================================================

class SubmitEnquiryEvent extends EnquiryEvent {
  final Map<String, String> params;

  const SubmitEnquiryEvent({
    required this.params,
  });

  @override
  List<Object?> get props => [
        params,
      ];
}