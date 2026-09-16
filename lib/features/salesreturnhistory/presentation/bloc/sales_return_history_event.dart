import 'package:equatable/equatable.dart';

abstract class SalesReturnHistoryEvent extends Equatable {
  const SalesReturnHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesReturnHistoryEvent extends SalesReturnHistoryEvent {
  final String userId;
  final String outletId;
  final String fromDate;
  final String toDate;
  final int startLimit;
  final String status;
  final bool isRefresh;

  const LoadSalesReturnHistoryEvent({
    required this.userId,
    required this.outletId,
    required this.fromDate,
    required this.toDate,
    required this.startLimit,
    required this.status,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [
    userId,
    outletId,
    fromDate,
    toDate,
    startLimit,
    status,
    isRefresh,
  ];
}

class SearchSalesReturnDealerEvent extends SalesReturnHistoryEvent {
  final String userId;
  final String searchText;

  const SearchSalesReturnDealerEvent({
    required this.userId,
    required this.searchText,
  });

  @override
  List<Object?> get props => [userId, searchText];
}

class ClearDealerSearchEvent extends SalesReturnHistoryEvent {}
