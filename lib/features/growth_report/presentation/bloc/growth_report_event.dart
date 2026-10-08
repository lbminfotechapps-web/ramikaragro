abstract class GrowthReportEvent {
  const GrowthReportEvent();
}

// ============================================================
// GROWTH REPORT
// ============================================================

class GetGrowthReportEvent
    extends GrowthReportEvent {
  final String userId;

  final String years;

  final String dealerId;

  const GetGrowthReportEvent({
    required this.userId,
    required this.years,
    required this.dealerId,
  });
}

// ============================================================
// GROWTH LOAD MORE
// ============================================================

class LoadMoreGrowthReportEvent
    extends GrowthReportEvent {
  const LoadMoreGrowthReportEvent();
}

// ============================================================
// DEALER SEARCH
// ============================================================

class SearchGrowthDealersEvent
    extends GrowthReportEvent {
  final String userId;

  final String searchText;

  const SearchGrowthDealersEvent({
    required this.userId,
    required this.searchText,
  });
}

// ============================================================
// LOAD MORE DEALERS
// ============================================================

class LoadMoreGrowthDealersEvent
    extends GrowthReportEvent {
  const LoadMoreGrowthDealersEvent();
}

// ============================================================
// CLEAR DEALER SEARCH
// ============================================================

class ClearGrowthDealerSearchEvent
    extends GrowthReportEvent {
  const ClearGrowthDealerSearchEvent();
}

// ============================================================
// RESET
// ============================================================

class ResetGrowthReportEvent
    extends GrowthReportEvent {
  const ResetGrowthReportEvent();
}