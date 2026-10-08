import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/growth_dealer_search.dart';
import '../../domain/entities/growth_report.dart';

import '../../domain/usecases/get_growth_report_usecase.dart';
import '../../domain/usecases/search_growth_dealers_usecase.dart';

import 'growth_report_event.dart';
import 'growth_report_state.dart';

class GrowthReportBloc
    extends Bloc<
        GrowthReportEvent,
        GrowthReportState> {
  final GetGrowthReportUseCase
      getGrowthReportUseCase;

  final SearchGrowthDealersUseCase
      searchGrowthDealersUseCase;

  GrowthReportBloc({
    required this.getGrowthReportUseCase,
    required this.searchGrowthDealersUseCase,
  }) : super(
          const GrowthReportState(),
        ) {
    on<GetGrowthReportEvent>(
      _getGrowthReport,
    );

    on<LoadMoreGrowthReportEvent>(
      _loadMoreGrowth,
    );

    on<SearchGrowthDealersEvent>(
      _searchDealers,
    );

    on<LoadMoreGrowthDealersEvent>(
      _loadMoreDealers,
    );

    on<ClearGrowthDealerSearchEvent>(
      _clearDealerSearch,
    );

    on<ResetGrowthReportEvent>(
      _reset,
    );
  }

  // ============================================================
  // GROWTH FIRST LOAD
  // ============================================================

  Future<void> _getGrowthReport(
    GetGrowthReportEvent event,
    Emitter<GrowthReportState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            GrowthReportStatus.loading,

        dealers:
            [],

        totals:
            [],

        compareYears:
            [],

        userId:
            event.userId,

        selectedYears:
            event.years,

        selectedDealerId:
            event.dealerId,

        startLimit:
            0,

        totalRows:
            0,

        loadingMore:
            false,

        hasMore:
            true,

        errorMessage:
            '',
      ),
    );

    try {
      final GrowthReport result =
          await getGrowthReportUseCase(
        userId:
            event.userId,

        years:
            event.years,

        dealerId:
            event.dealerId,

        startLimit:
            0,
      );

      final int loaded =
          result.dealers.length;

      emit(
        state.copyWith(
          status:
              GrowthReportStatus.success,

          dealers:
              result.dealers,

          totals:
              result.totals,

          compareYears:
              result.compareYears,

          yearsSelected:
              result.yearsSelected,

          fromYear:
              result.fromYear,

          toYear:
              result.toYear,

          totalRows:
              result.totalRows,

          startLimit:
              loaded,

          hasMore:
              loaded <
                  result.totalRows,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              GrowthReportStatus.failure,

          errorMessage:
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),
        ),
      );
    }
  }

  // ============================================================
  // GROWTH PAGINATION
  // ============================================================

  Future<void> _loadMoreGrowth(
    LoadMoreGrowthReportEvent event,
    Emitter<GrowthReportState> emit,
  ) async {
    if (state.loadingMore ||
        !state.hasMore ||
        state.userId.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        loadingMore:
            true,
      ),
    );

    try {
      final GrowthReport result =
          await getGrowthReportUseCase(
        userId:
            state.userId,

        years:
            state.selectedYears,

        dealerId:
            state.selectedDealerId,

        startLimit:
            state.startLimit,
      );

      final Map<String, GrowthDealer>
          map = {
        for (final item
            in state.dealers)
          item.dealerId:
              item,
      };

      for (final item
          in result.dealers) {
        map[item.dealerId] =
            item;
      }

      final combined =
          map.values.toList();

      emit(
        state.copyWith(
          dealers:
              combined,

          totals:
              result.totals.isEmpty
                  ? state.totals
                  : result.totals,

          totalRows:
              result.totalRows,

          startLimit:
              combined.length,

          hasMore:
              combined.length <
                      result.totalRows &&
                  result.dealers
                      .isNotEmpty,

          loadingMore:
              false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadingMore:
              false,
        ),
      );
    }
  }

  // ============================================================
  // DEALER FIRST SEARCH
  // ============================================================

  Future<void> _searchDealers(
    SearchGrowthDealersEvent event,
    Emitter<GrowthReportState> emit,
  ) async {
    emit(
      state.copyWith(
        dealerSearchStatus:
            GrowthDealerSearchStatus.loading,

        dealerSuggestions:
            [],

        dealerSearchText:
            event.searchText,

        dealerStartLimit:
            0,

        dealerLoadingMore:
            false,

        dealerHasMore:
            true,

        dealerError:
            '',
      ),
    );

    try {
      final List<GrowthDealerSearch>
          result =
          await searchGrowthDealersUseCase(
        userId:
            event.userId,

        searchText:
            event.searchText,

        startLimit:
            0,
      );

      emit(
        state.copyWith(
          dealerSearchStatus:
              GrowthDealerSearchStatus.success,

          dealerSuggestions:
              result,

          dealerStartLimit:
              result.length,

          // Your API does not return total count.
          // If result is empty, pagination definitely ended.
          dealerHasMore:
              result.isNotEmpty,

          dealerLoadingMore:
              false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          dealerSearchStatus:
              GrowthDealerSearchStatus.failure,

          dealerError:
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),
        ),
      );
    }
  }

  // ============================================================
  // DEALER PAGINATION
  // ============================================================

  Future<void> _loadMoreDealers(
    LoadMoreGrowthDealersEvent event,
    Emitter<GrowthReportState> emit,
  ) async {
    if (state.dealerLoadingMore ||
        !state.dealerHasMore ||
        state.userId.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        dealerLoadingMore:
            true,
      ),
    );

    try {
      final result =
          await searchGrowthDealersUseCase(
        userId:
            state.userId,

        searchText:
            state.dealerSearchText,

        startLimit:
            state.dealerStartLimit,
      );

      final Map<String, GrowthDealerSearch>
          map = {
        for (final item
            in state.dealerSuggestions)
          item.dealerId:
              item,
      };

      for (final item in result) {
        map[item.dealerId] =
            item;
      }

      final combined =
          map.values.toList();

      emit(
        state.copyWith(
          dealerSuggestions:
              combined,

          dealerStartLimit:
              combined.length,

          dealerHasMore:
              result.isNotEmpty,

          dealerLoadingMore:
              false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          dealerLoadingMore:
              false,
        ),
      );
    }
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void _clearDealerSearch(
    ClearGrowthDealerSearchEvent event,
    Emitter<GrowthReportState> emit,
  ) {
    emit(
      state.copyWith(
        dealerSearchStatus:
            GrowthDealerSearchStatus.initial,

        dealerSuggestions:
            [],

        dealerSearchText:
            '',

        dealerStartLimit:
            0,

        dealerLoadingMore:
            false,

        dealerHasMore:
            true,

        dealerError:
            '',
      ),
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  void _reset(
    ResetGrowthReportEvent event,
    Emitter<GrowthReportState> emit,
  ) {
    emit(
      const GrowthReportState(),
    );
  }
}