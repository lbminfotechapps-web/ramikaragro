import '../../domain/entities/growth_dealer_search.dart';
import '../../domain/entities/growth_report.dart';

enum GrowthReportStatus {
  initial,
  loading,
  success,
  failure,
}

enum GrowthDealerSearchStatus {
  initial,
  loading,
  success,
  failure,
}

class GrowthReportState {
  // ==========================================================
  // GROWTH
  // ==========================================================

  final GrowthReportStatus status;

  final List<GrowthDealer> dealers;

  final List<GrowthYearData> totals;

  final List<int> compareYears;

  final int yearsSelected;

  final int fromYear;

  final int toYear;

  final int totalRows;

  final bool loadingMore;

  final bool hasMore;

  final String errorMessage;

  // ==========================================================
  // CURRENT GROWTH FILTER
  // ==========================================================

  final String userId;

  final String selectedYears;

  final String selectedDealerId;

  final int startLimit;

  // ==========================================================
  // DEALER SEARCH
  // ==========================================================

  final GrowthDealerSearchStatus
      dealerSearchStatus;

  final List<GrowthDealerSearch>
      dealerSuggestions;

  final String dealerSearchText;

  final int dealerStartLimit;

  final bool dealerLoadingMore;

  final bool dealerHasMore;

  final String dealerError;

  const GrowthReportState({
    this.status =
        GrowthReportStatus.initial,

    this.dealers =
        const [],

    this.totals =
        const [],

    this.compareYears =
        const [],

    this.yearsSelected =
        0,

    this.fromYear =
        0,

    this.toYear =
        0,

    this.totalRows =
        0,

    this.loadingMore =
        false,

    this.hasMore =
        true,

    this.errorMessage =
        '',

    this.userId =
        '',

    this.selectedYears =
        'Last 2 Year',

    this.selectedDealerId =
        '',

    this.startLimit =
        0,

    // DEALERS
    this.dealerSearchStatus =
        GrowthDealerSearchStatus.initial,

    this.dealerSuggestions =
        const [],

    this.dealerSearchText =
        '',

    this.dealerStartLimit =
        0,

    this.dealerLoadingMore =
        false,

    this.dealerHasMore =
        true,

    this.dealerError =
        '',
  });

  GrowthReportState copyWith({
    GrowthReportStatus? status,

    List<GrowthDealer>? dealers,

    List<GrowthYearData>? totals,

    List<int>? compareYears,

    int? yearsSelected,

    int? fromYear,

    int? toYear,

    int? totalRows,

    bool? loadingMore,

    bool? hasMore,

    String? errorMessage,

    String? userId,

    String? selectedYears,

    String? selectedDealerId,

    int? startLimit,

    GrowthDealerSearchStatus?
        dealerSearchStatus,

    List<GrowthDealerSearch>?
        dealerSuggestions,

    String? dealerSearchText,

    int? dealerStartLimit,

    bool? dealerLoadingMore,

    bool? dealerHasMore,

    String? dealerError,
  }) {
    return GrowthReportState(
      status:
          status ??
              this.status,

      dealers:
          dealers ??
              this.dealers,

      totals:
          totals ??
              this.totals,

      compareYears:
          compareYears ??
              this.compareYears,

      yearsSelected:
          yearsSelected ??
              this.yearsSelected,

      fromYear:
          fromYear ??
              this.fromYear,

      toYear:
          toYear ??
              this.toYear,

      totalRows:
          totalRows ??
              this.totalRows,

      loadingMore:
          loadingMore ??
              this.loadingMore,

      hasMore:
          hasMore ??
              this.hasMore,

      errorMessage:
          errorMessage ??
              this.errorMessage,

      userId:
          userId ??
              this.userId,

      selectedYears:
          selectedYears ??
              this.selectedYears,

      selectedDealerId:
          selectedDealerId ??
              this.selectedDealerId,

      startLimit:
          startLimit ??
              this.startLimit,

      dealerSearchStatus:
          dealerSearchStatus ??
              this.dealerSearchStatus,

      dealerSuggestions:
          dealerSuggestions ??
              this.dealerSuggestions,

      dealerSearchText:
          dealerSearchText ??
              this.dealerSearchText,

      dealerStartLimit:
          dealerStartLimit ??
              this.dealerStartLimit,

      dealerLoadingMore:
          dealerLoadingMore ??
              this.dealerLoadingMore,

      dealerHasMore:
          dealerHasMore ??
              this.dealerHasMore,

      dealerError:
          dealerError ??
              this.dealerError,
    );
  }
}