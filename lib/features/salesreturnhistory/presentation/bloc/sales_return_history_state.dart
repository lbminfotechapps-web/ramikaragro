import 'package:demo/features/salesreturnhistory/domain/entities/dealer_name_entity.dart';
import 'package:demo/features/salesreturnhistory/domain/entities/sales_return_history_entity.dart';
import 'package:equatable/equatable.dart';

enum SalesReturnHistoryStatus { initial, loading, success, failure }

class SalesReturnHistoryState extends Equatable {
  final SalesReturnHistoryStatus status;

  final List<SalesReturnHistoryEntity> salesReturns;

  final List<DealerNameEntity> dealers;

  final bool isPaginationLoading;
  final bool hasReachedEnd;

  final String? errorMessage;

  const SalesReturnHistoryState({
    this.status = SalesReturnHistoryStatus.initial,
    this.salesReturns = const [],
    this.dealers = const [],
    this.isPaginationLoading = false,
    this.hasReachedEnd = false,
    this.errorMessage,
  });

  SalesReturnHistoryState copyWith({
    SalesReturnHistoryStatus? status,
    List<SalesReturnHistoryEntity>? salesReturns,
    List<DealerNameEntity>? dealers,
    bool? isPaginationLoading,
    bool? hasReachedEnd,
    String? errorMessage,
  }) {
    return SalesReturnHistoryState(
      status: status ?? this.status,
      salesReturns: salesReturns ?? this.salesReturns,
      dealers: dealers ?? this.dealers,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    salesReturns,
    dealers,
    isPaginationLoading,
    hasReachedEnd,
    errorMessage,
  ];
}
