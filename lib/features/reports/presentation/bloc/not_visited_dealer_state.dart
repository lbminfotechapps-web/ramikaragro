import 'package:equatable/equatable.dart';

import '../../domain/entities/not_visited_dealer.dart';

enum DealerStatus {
  initial,
  loading,
  success,
  loadingMore,
  failure,
}

class DealerState extends Equatable {
  final DealerStatus status;
  final List<NotVisitedDealer> dealers;
  final String? errorMessage;
  final int startLimit;
  final int pageSize;
  final bool hasReachedMax;

  const DealerState({
    this.status = DealerStatus.initial,
    this.dealers = const [],
    this.errorMessage,
    this.startLimit = 0,
    this.pageSize = 20,
    this.hasReachedMax = false,
  });

  DealerState copyWith({
    DealerStatus? status,
    List<NotVisitedDealer>? dealers,
    String? errorMessage,
    int? startLimit,
    int? pageSize,
    bool? hasReachedMax,

    // IMPORTANT
    bool clearErrorMessage = false,
  }) {
    return DealerState(
      status: status ?? this.status,

      dealers: dealers ?? this.dealers,

      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,

      startLimit: startLimit ?? this.startLimit,

      pageSize: pageSize ?? this.pageSize,

      hasReachedMax:
          hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        status,
        dealers,
        errorMessage,
        startLimit,
        pageSize,
        hasReachedMax,
      ];
}