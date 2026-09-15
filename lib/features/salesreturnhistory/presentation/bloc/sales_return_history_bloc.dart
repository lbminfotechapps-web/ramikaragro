import 'dart:async';

import 'package:demo/features/salesreturnhistory/domain/usecases/get_sales_return_history_usecase.dart';
import 'package:demo/features/salesreturnhistory/domain/usecases/search_sales_return_dealer_usecase.dart';
import 'package:demo/features/salesreturnhistory/presentation/bloc/sales_return_history_event.dart';
import 'package:demo/features/salesreturnhistory/presentation/bloc/sales_return_history_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesReturnHistoryBloc
    extends Bloc<SalesReturnHistoryEvent, SalesReturnHistoryState> {
  final GetSalesReturnHistoryUseCase getSalesReturnHistoryUseCase;
  final SearchSalesReturnDealerUseCase searchDealerUseCase;

  Timer? _dealerSearchTimer;

  SalesReturnHistoryBloc({
    required this.getSalesReturnHistoryUseCase,
    required this.searchDealerUseCase,
  }) : super(const SalesReturnHistoryState()) {
    on<LoadSalesReturnHistoryEvent>(_loadSalesReturnHistory);

    on<SearchSalesReturnDealerEvent>(_searchDealer);

    on<ClearDealerSearchEvent>(_clearDealerSearch);
  }

  Future<void> _loadSalesReturnHistory(
    LoadSalesReturnHistoryEvent event,
    Emitter<SalesReturnHistoryState> emit,
  ) async {
    final bool isFirstPage = event.startLimit == 0;

    if (isFirstPage) {
      emit(
        state.copyWith(
          status: SalesReturnHistoryStatus.loading,
          salesReturns: [],
          hasReachedEnd: false,
        ),
      );
    } else {
      emit(state.copyWith(isPaginationLoading: true));
    }

    try {
      final result = await getSalesReturnHistoryUseCase(
        userId: event.userId,
        outletId: event.outletId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        startLimit: event.startLimit.toString(),
        status: event.status,
      );

      if (result.isEmpty) {
        emit(
          state.copyWith(
            status: SalesReturnHistoryStatus.failure,
            salesReturns: [],
            isPaginationLoading: false,
            hasReachedEnd: true,
            errorMessage: 'No sales return history found',
          ),
        );
        return;
      }

      final updatedList = isFirstPage
          ? result
          : [...state.salesReturns, ...result];

      emit(
        state.copyWith(
          status: SalesReturnHistoryStatus.success,
          salesReturns: updatedList,
          isPaginationLoading: false,
          hasReachedEnd: result.length < 20,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SalesReturnHistoryStatus.failure,
          salesReturns: [],
          isPaginationLoading: false,
          hasReachedEnd: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _searchDealer(
    SearchSalesReturnDealerEvent event,
    Emitter<SalesReturnHistoryState> emit,
  ) async {
    if (event.searchText.trim().length < 3) {
      emit(state.copyWith(dealers: []));
      return;
    }

    try {
      final result = await searchDealerUseCase(
        userId: event.userId,
        searchText: event.searchText.trim(),
      );

      emit(state.copyWith(dealers: result));
    } catch (e) {
      emit(state.copyWith(dealers: []));
    }
  }

  void _clearDealerSearch(
    ClearDealerSearchEvent event,
    Emitter<SalesReturnHistoryState> emit,
  ) {
    emit(state.copyWith(dealers: []));
  }

  @override
  Future<void> close() {
    _dealerSearchTimer?.cancel();
    return super.close();
  }
}
