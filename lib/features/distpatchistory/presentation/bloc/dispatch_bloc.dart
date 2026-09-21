import 'package:solufine/features/distpatchistory/domain/entities/dispatch_list_entity.dart';
import 'package:solufine/features/distpatchistory/domain/usecases/get_dispatch_list_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dispatch_event.dart';
import 'dispatch_state.dart';

class DispatchBloc extends Bloc<DispatchEvent, DispatchState> {
  final GetDispatchListUseCase getDispatchListUseCase;

  static const int pageSize = 20;

  int startLimit = 0;
  int? userId;

  String searchText = '';
  String status = '';
  String fromDate = '';
  String toDate = '';

  bool isLoading = false;
  bool isLastPage = false;

  final List<DispatchListEntity> dispatchList = [];

  DispatchBloc({required this.getDispatchListUseCase})
    : super(const DispatchInitial()) {
    on<GetDispatchListEvent>(_onGetDispatchList);
    on<LoadMoreDispatchEvent>(_onLoadMore);
  }

  Future<void> _onGetDispatchList(
    GetDispatchListEvent event,
    Emitter<DispatchState> emit,
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

    dispatchList.clear();

    isLoading = true;

    emit(const DispatchLoading());

    try {
      final result = await getDispatchListUseCase(
        userId: event.userId,
        searchText: searchText,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
        startLimit: startLimit,
      );

      isLoading = false;

      if (result.isEmpty) {
        isLastPage = true;
        emit(const DispatchEmpty());
        return;
      }

      dispatchList.addAll(result);

      isLastPage = result.length < pageSize;

      emit(
        DispatchLoaded(
          dispatchList: List.unmodifiable(dispatchList),
          hasMore: !isLastPage,
        ),
      );
    } catch (e) {
      isLoading = false;

      emit(DispatchError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreDispatchEvent event,
    Emitter<DispatchState> emit,
  ) async {
    if (isLoading || isLastPage || userId == null) {
      return;
    }

    isLoading = true;

    if (state is DispatchLoaded) {
      final current = state as DispatchLoaded;

      emit(current.copyWith(isLoadingMore: true));
    }

    try {
      startLimit += pageSize;

      final result = await getDispatchListUseCase(
        userId: userId!,
        searchText: searchText,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
        startLimit: startLimit,
      );

      isLoading = false;

      if (result.isEmpty) {
        isLastPage = true;

        if (state is DispatchLoaded) {
          final current = state as DispatchLoaded;

          emit(current.copyWith(hasMore: false, isLoadingMore: false));
        }

        return;
      }

      dispatchList.addAll(result);

      isLastPage = result.length < pageSize;

      emit(
        DispatchLoaded(
          dispatchList: List.unmodifiable(dispatchList),
          hasMore: !isLastPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      isLoading = false;

      if (state is DispatchLoaded) {
        final current = state as DispatchLoaded;

        emit(current.copyWith(isLoadingMore: false));
      }
    }
  }
}
