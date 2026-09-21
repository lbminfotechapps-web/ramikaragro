import 'package:solufine/features/orderhistory/domain/entities/order_history_entity.dart';
import 'package:solufine/features/orderhistory/domain/usecases/get_order_history_usecase.dart';
import 'package:solufine/features/orderhistory/domain/usecases/update_order_status_usecase.dart';
import 'package:solufine/features/orderhistory/presentation/bloc/order_history_event.dart';
import 'package:solufine/features/orderhistory/presentation/bloc/order_history_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  final GetOrderHistoryUseCase getOrderHistoryUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;

  static const int pageSize = 20;

  int startLimit = 0;

  int? userId;

  String searchText = '';
  String status = '';
  String fromDate = '';
  String toDate = '';

  List<OrderHistoryEntity> orders = [];

  bool isLoading = false;
  bool isLastPage = false;

  OrderHistoryBloc({
    required this.getOrderHistoryUseCase,
    required this.updateOrderStatusUseCase,
  }) : super(OrderHistoryInitial()) {
    on<GetOrderHistoryEvent>(_onGetOrderHistory);
    on<LoadMoreOrderHistoryEvent>(_onLoadMore);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
  }

  Future<void> _onGetOrderHistory(
    GetOrderHistoryEvent event,
    Emitter<OrderHistoryState> emit,
  ) async {
    if (isLoading && !event.isRefresh) {
      return;
    }

    userId = event.userId;

    searchText = event.searchText;
    status = event.status;
    fromDate = event.fromDate;
    toDate = event.toDate;

    startLimit = 0;
    isLastPage = false;

    orders.clear();

    isLoading = true;

    emit(OrderHistoryLoading());

    try {
      final result = await getOrderHistoryUseCase(
        userId: event.userId,
        searchText: searchText,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
        startLimit: startLimit,
        pageSize: pageSize,
      );

      isLoading = false;

      if (result.isEmpty) {
        isLastPage = true;
        emit(OrderHistoryEmpty());
        return;
      }

      orders = List<OrderHistoryEntity>.from(result);

      isLastPage = result.length < pageSize;

      emit(
        OrderHistoryLoaded(
          orders: List.unmodifiable(orders),
          hasMore: !isLastPage,
        ),
      );
    } catch (e) {
      isLoading = false;

      emit(OrderHistoryError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreOrderHistoryEvent event,
    Emitter<OrderHistoryState> emit,
  ) async {
    if (isLoading || isLastPage || userId == null) {
      return;
    }

    isLoading = true;

    if (state is OrderHistoryLoaded) {
      final currentState = state as OrderHistoryLoaded;

      emit(currentState.copyWith(isLoadingMore: true));
    }

    try {
      startLimit += pageSize;

      final result = await getOrderHistoryUseCase(
        userId: userId!,
        searchText: searchText,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
        startLimit: startLimit,
        pageSize: pageSize,
      );

      isLoading = false;

      if (result.isEmpty) {
        isLastPage = true;

        if (state is OrderHistoryLoaded) {
          final currentState = state as OrderHistoryLoaded;

          emit(currentState.copyWith(hasMore: false, isLoadingMore: false));
        }

        return;
      }

      orders.addAll(result);

      isLastPage = result.length < pageSize;

      emit(
        OrderHistoryLoaded(
          orders: List.unmodifiable(orders),
          hasMore: !isLastPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      isLoading = false;

      if (state is OrderHistoryLoaded) {
        final currentState = state as OrderHistoryLoaded;

        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderHistoryState> emit,
  ) async {
    try {
      emit(OrderStatusUpdating(List.unmodifiable(orders)));

      final message = await updateOrderStatusUseCase(
        userId: event.userId,
        orderId: event.orderId,
        orderStatus: event.orderStatus,
        remark: event.remark,
      );

      emit(
        OrderStatusUpdated(orders: List.unmodifiable(orders), message: message),
      );

      add(
        GetOrderHistoryEvent(
          userId: event.userId,
          searchText: searchText,
          status: status,
          fromDate: fromDate,
          toDate: toDate,
          isRefresh: true,
        ),
      );
    } catch (e) {
      emit(OrderHistoryError(e.toString()));
    }
  }
}
