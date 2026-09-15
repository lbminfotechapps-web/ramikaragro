import 'package:equatable/equatable.dart';

abstract class OrderHistoryEvent extends Equatable {
  const OrderHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Initial search / refresh
class GetOrderHistoryEvent extends OrderHistoryEvent {
  final int userId;
  final String searchText;
  final String status;
  final String fromDate;
  final String toDate;
  final bool isRefresh;

  const GetOrderHistoryEvent({
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

/// Pagination
class LoadMoreOrderHistoryEvent extends OrderHistoryEvent {
  const LoadMoreOrderHistoryEvent();
}

/// Approve / Cancel order
class UpdateOrderStatusEvent extends OrderHistoryEvent {
  final int userId;
  final String orderId;
  final String orderStatus;
  final String remark;

  const UpdateOrderStatusEvent({
    required this.userId,
    required this.orderId,
    required this.orderStatus,
    required this.remark,
  });

  @override
  List<Object?> get props => [userId, orderId, orderStatus, remark];
}
