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

  final String lastThirNotVisitDealer;
  final String lastThirNotVisitFarmer;

  final String totalDealerCount;
  final String totalFarmerCount;
  final String currentMonth;

  final List<DayWiseVisitEntity> dayWise;

  const HomeVisitEntity({
    this.status = false,
    this.message = '',

    this.todayTotalVisit = '0',
    this.todayDealerCnt = '0',
    this.todayFarmerCnt = '0',

    this.monthlyTotalVisit = '0',
    this.monthlyDealerCnt = '0',
    this.monthlyFarmerCnt = '0',

    this.monthlyUniqueDealerCnt = '0',
    this.monthlyUniqueFarmerCnt = '0',

    this.lastThirNotVisitDealer = '0',
    this.lastThirNotVisitFarmer = '0',

    this.totalDealerCount = '0',
    this.totalFarmerCount = '0',
    this.currentMonth = '',

    this.dayWise = const [],
  });
}

class DayWiseVisitEntity {
  final String date;
  final String dealerCount;
  final String farmerCount;

  const DayWiseVisitEntity({
    this.date = '',
    this.dealerCount = '0',
    this.farmerCount = '0',
  });
}
