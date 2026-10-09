class VisitFrequencyReport {
  final VisitFrequencyGroup dealer;
  final VisitFrequencyGroup farmer;

  final String fromDate;
  final String toDate;

  const VisitFrequencyReport({
    required this.dealer,
    required this.farmer,
    required this.fromDate,
    required this.toDate,
  });
}

// ============================================================
// GROUP
// ============================================================

class VisitFrequencyGroup {
  final int total;

  final List<VisitFrequencyBucket>
      buckets;

  const VisitFrequencyGroup({
    required this.total,
    required this.buckets,
  });
}

// ============================================================
// BUCKET
// ============================================================

class VisitFrequencyBucket {
  final String key;

  final String label;

  final int count;

  final double percentage;

  const VisitFrequencyBucket({
    required this.key,
    required this.label,
    required this.count,
    required this.percentage,
  });
}