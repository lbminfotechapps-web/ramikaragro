import 'package:demo/features/orderhistory/domain/entities/order_history_entity.dart';
import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

abstract class OrderHistoryState extends Equatable {
  const OrderHistoryState();

  @override
  List<Object?> get props => [];
}

// Initial state
class OrderHistoryInitial extends OrderHistoryState {
  const OrderHistoryInitial();
}

// Loading
class OrderHistoryLoading extends OrderHistoryState {
  const OrderHistoryLoading();
}

// Data loaded
class OrderHistoryLoaded extends OrderHistoryState {
  final List<OrderHistoryEntity> orders;
  final bool hasMore;
  final bool isLoadingMore;

  const OrderHistoryLoaded({
    required this.orders,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  OrderHistoryLoaded copyWith({
    List<OrderHistoryEntity>? orders,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return OrderHistoryLoaded(
      orders: orders ?? this.orders,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [orders, hasMore, isLoadingMore];
}

// Empty
class OrderHistoryEmpty extends OrderHistoryState {
  const OrderHistoryEmpty();
}

// Error
class OrderHistoryError extends OrderHistoryState {
  final String message;

  const OrderHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// Updating order status
class OrderStatusUpdating extends OrderHistoryState {
  final List<OrderHistoryEntity> orders;

  const OrderStatusUpdating(this.orders);

  @override
  List<Object?> get props => [orders];
}

// Order status updated
class OrderStatusUpdated extends OrderHistoryState {
  final List<OrderHistoryEntity> orders;
  final String message;

  const OrderStatusUpdated({required this.orders, required this.message});

  @override
  List<Object?> get props => [orders, message];
}
