class VisitGeoWiseReport {
  final VisitGeoSection stateSection;
  final VisitGeoSection districtSection;
  final VisitGeoSection talukaSection;
  final String fromDate;
  final String toDate;

  const VisitGeoWiseReport({
    required this.stateSection,
    required this.districtSection,
    required this.talukaSection,
    required this.fromDate,
    required this.toDate,
  });
}

class VisitGeoSection {
  final int count;
  final List<VisitGeoItem> items;
  final VisitGeoTotal total;

  const VisitGeoSection({
    required this.count,
    required this.items,
    required this.total,
  });
}

class VisitGeoItem {
  final String id;
  final String name;
  final int dealerVisits;
  final int farmerVisits;
  final int totalVisits;
  final int unique;

  const VisitGeoItem({
    required this.id,
    required this.name,
    required this.dealerVisits,
    required this.farmerVisits,
    required this.totalVisits,
    required this.unique,
  });
}

class VisitGeoTotal {
  final int dealerVisits;
  final int farmerVisits;
  final int totalVisits;
  final int unique;

  const VisitGeoTotal({
    required this.dealerVisits,
    required this.farmerVisits,
    required this.totalVisits,
    required this.unique,
  });
}