class CalendarPersonEntity {
  final String id;
  final String name;

  const CalendarPersonEntity({
    required this.id,
    required this.name,
  });
}

class CalendarDayEntity {
  final DateTime date;

  final int totalCount;

  final int dealerCount;

  final int farmerCount;

  final List<CalendarPersonEntity> dealers;

  final List<CalendarPersonEntity> farmers;

  const CalendarDayEntity({
    required this.date,
    required this.totalCount,
    required this.dealerCount,
    required this.farmerCount,
    required this.dealers,
    required this.farmers,
  });

  bool get hasDealer => dealerCount > 0;

  bool get hasFarmer => farmerCount > 0;

  bool get hasAnyVisit =>
      dealerCount > 0 || farmerCount > 0;
}