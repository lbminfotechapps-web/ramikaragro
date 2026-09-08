import 'package:demo/features/farmer/famerfollowup/data/model/followuplist_model.dart';
import 'package:equatable/equatable.dart';

enum FamerfollowupStatus { initial, loading, success, failure }

enum FollowupHistoryStatus { initial, loading, success, failure }

class FamerfollowupState extends Equatable {
  // =========================
  // Submit Follow-up
  // =========================
  final FamerfollowupStatus status;
  final String? errorMessage;
  final String? successMessage;

  // =========================
  // Follow-up History
  // =========================
  final FollowupHistoryStatus historyStatus;
  final List<RemarkListModel> historyList;
  final String? historyError;

  const FamerfollowupState({
    this.status = FamerfollowupStatus.initial,
    this.errorMessage,
    this.successMessage,

    this.historyStatus = FollowupHistoryStatus.initial,
    this.historyList = const [],
    this.historyError,
  });

  FamerfollowupState copyWith({
    FamerfollowupStatus? status,
    String? errorMessage,
    String? successMessage,

    FollowupHistoryStatus? historyStatus,
    List<RemarkListModel>? historyList,
    String? historyError,
  }) {
    return FamerfollowupState(
      // Submit
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,

      // History
      historyStatus: historyStatus ?? this.historyStatus,
      historyList: historyList ?? this.historyList,
      historyError: historyError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    successMessage,
    historyStatus,
    historyList,
    historyError,
  ];
}
