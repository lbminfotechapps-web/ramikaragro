class HomeVisitEntity {
  final bool status;
  final String message;

  final String todayTotalVisit;
  final String todayDealerCnt;
  final String todayFarmerCnt;

  final String monthlyTotalVisit;
  final String monthlyDealerCnt;
  final String monthlyFarmerCnt;

  final String monthlyUniqueDealerCnt;
  final String monthlyUniqueFarmerCnt;

  const HomeVisitEntity({
    required this.status,
    required this.message,
    required this.todayTotalVisit,
    required this.todayDealerCnt,
    required this.todayFarmerCnt,
    required this.monthlyTotalVisit,
    required this.monthlyDealerCnt,
    required this.monthlyFarmerCnt,
    required this.monthlyUniqueDealerCnt,
    required this.monthlyUniqueFarmerCnt,
  });
}
