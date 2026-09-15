import 'package:equatable/equatable.dart';

abstract class DispatchEvent extends Equatable {
  const DispatchEvent();

  @override
  List<Object?> get props => [];
}

class GetDispatchListEvent extends DispatchEvent {
  final int userId;
  final String searchText;
  final String status;
  final String fromDate;
  final String toDate;
  final bool isRefresh;

  const GetDispatchListEvent({
    required this.userId,
    this.searchText = '',
    this.status = '',
    this.fromDate = '',
    this.toDate = '',
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [
    userId,
    searchText,
    status,
    fromDate,
    toDate,
    isRefresh,
  ];
}

class LoadMoreDispatchEvent extends DispatchEvent {
  const LoadMoreDispatchEvent();
}
