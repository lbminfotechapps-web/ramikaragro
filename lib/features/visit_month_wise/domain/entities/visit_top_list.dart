class VisitTopListReport {
  final VisitTopListGroup dealer;
  final VisitTopListGroup farmer;

  final String fromDate;
  final String toDate;

  const VisitTopListReport({
    required this.dealer,
    required this.farmer,
    required this.fromDate,
    required this.toDate,
  });
}

// ============================================================
// GROUP
// ============================================================

class VisitTopListGroup {
  final int count;

  final List<VisitTopListItem> items;

  final int totalVisits;

  const VisitTopListGroup({
    required this.count,
    required this.items,
    required this.totalVisits,
  });
}

// ============================================================
// ITEM
// ============================================================

class VisitTopListItem {
  final int rank;

  final String id;

  final String name;

  final int visitCount;

  const VisitTopListItem({
    required this.rank,
    required this.id,
    required this.name,
    required this.visitCount,
  });
}
