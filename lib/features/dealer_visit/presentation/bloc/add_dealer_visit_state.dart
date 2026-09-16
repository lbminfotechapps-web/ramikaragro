import 'package:demo/features/dealer_visit/domain/entities/add_dealer_visit_entity.dart';
import 'package:demo/features/dealer_visit/domain/entities/dealer_followup_list_entity.dart';
import 'package:demo/features/dealer_visit/domain/entities/visit_purpose_entity.dart';
import 'package:equatable/equatable.dart';



enum AddDealerVisitStatus {
  initial,
  loading,
  success,
  failure,
}

class AddDealerVisitState extends Equatable {
  final AddDealerVisitStatus addLeaveStatus;
  final List<AddDealerVisitEntity> leaves;
  final List<PurposeEntity> purpose;
  final List<DealerFollowupListEntity> followupList;
  final String? errorMessage;
  final String? successMessage;

  const AddDealerVisitState({
    this.addLeaveStatus = AddDealerVisitStatus.initial,
    this.leaves = const [],
    this.purpose = const [],
    this.followupList = const [],
    this.errorMessage,
    this.successMessage,
  });

  AddDealerVisitState copyWith({
    AddDealerVisitStatus? addLeaveStatus,
    List<AddDealerVisitEntity>? leaves,
    List<PurposeEntity>? purpose,
    List<DealerFollowupListEntity>? followupList,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AddDealerVisitState(
      addLeaveStatus: addLeaveStatus ?? this.addLeaveStatus,
      leaves: leaves ?? this.leaves,
      purpose: purpose ?? this.purpose,
      followupList: followupList ?? this.followupList,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        addLeaveStatus,
        leaves,
        purpose,
        followupList,
        errorMessage,
        successMessage,
      ];
}