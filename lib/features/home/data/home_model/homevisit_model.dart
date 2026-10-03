// import 'package:solufine/features/home/doman/home_entity/homevisit_entity.dart';

// class HomeVisitModel extends HomeVisitEntity {
//   const HomeVisitModel({
//     required super.status,
//     required super.message,
//     required super.todayTotalVisit,
//     required super.todayDealerCnt,
//     required super.todayFarmerCnt,
//     required super.monthlyTotalVisit,
//     required super.monthlyDealerCnt,
//     required super.monthlyFarmerCnt,
//     required super.monthlyUniqueDealerCnt,
//     required super.monthlyUniqueFarmerCnt,
    
//     required super.lastThirNotVisitDealer,
//     required super.lastThirNotVisitFarmer
//   });

//   factory HomeVisitModel.fromJson(Map<String, dynamic> json) {
//     return HomeVisitModel(
//       status: json['status'] == true,
//       message: json['message']?.toString() ?? '',

//       todayTotalVisit: json['today_total_visit']?.toString() ?? '0',

//       todayDealerCnt: json['today_dealer_cnt']?.toString() ?? '0',

//       todayFarmerCnt: json['today_farmer_cnt']?.toString() ?? '0',

//       monthlyTotalVisit: json['monthly_total_visit']?.toString() ?? '0',

//       monthlyDealerCnt: json['monthly_dealer_cnt']?.toString() ?? '0',

//       monthlyFarmerCnt: json['monthly_farmer_cnt']?.toString() ?? '0',

//       monthlyUniqueDealerCnt:
//           json['monthly_unique_dealer_cnt']?.toString() ?? '0',

//       monthlyUniqueFarmerCnt:
//           json['monthly_unique_farmer_cnt']?.toString() ?? '0',
//           lastThirNotVisitDealer: json['last_30_days_not_visited_dealer_cnt']?.toString() ?? '0',
//           lastThirNotVisitFarmer: json['last_30_days_not_visited_farmer_cnt']?.toString() ?? '0',
//     );
//   }
// }

import 'package:solufine/features/home/doman/home_entity/homevisit_entity.dart';

class HomeVisitModel extends HomeVisitEntity {
  const HomeVisitModel({
    required super.status,
    required super.message,

    // EXISTING
    required super.todayTotalVisit,
    required super.todayDealerCnt,
    required super.todayFarmerCnt,

    required super.monthlyTotalVisit,
    required super.monthlyDealerCnt,
    required super.monthlyFarmerCnt,

    required super.monthlyUniqueDealerCnt,
    required super.monthlyUniqueFarmerCnt,

    required super.lastThirNotVisitDealer,
    required super.lastThirNotVisitFarmer,

    // NEW
    required super.totalDealerCount,
    required super.totalFarmerCount,
    required super.dayWise,
  });

  factory HomeVisitModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return HomeVisitModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',

      // ============================================================
      // EXISTING FIELDS
      // ============================================================

      todayTotalVisit:
          json['today_total_visit']
                  ?.toString() ??
              '0',

      todayDealerCnt:
          json['today_dealer_cnt']
                  ?.toString() ??
              '0',

      todayFarmerCnt:
          json['today_farmer_cnt']
                  ?.toString() ??
              '0',

      monthlyTotalVisit:
          json['monthly_total_visit']
                  ?.toString() ??
              '0',

      monthlyDealerCnt:
          json['monthly_dealer_cnt']
                  ?.toString() ??
              '0',

      monthlyFarmerCnt:
          json['monthly_farmer_cnt']
                  ?.toString() ??
              '0',

      monthlyUniqueDealerCnt:
          json['monthly_unique_dealer_cnt']
                  ?.toString() ??
              '0',

      monthlyUniqueFarmerCnt:
          json['monthly_unique_farmer_cnt']
                  ?.toString() ??
              '0',

      lastThirNotVisitDealer:
          json['last_30_days_not_visited_dealer_cnt']
                  ?.toString() ??
              '0',

      lastThirNotVisitFarmer:
          json['last_30_days_not_visited_farmer_cnt']
                  ?.toString() ??
              '0',

      // ============================================================
      // NEW VISIT GRAPH FIELDS
      // ============================================================

      totalDealerCount:
          json['tot_dealer_cnt']
                  ?.toString() ??
              '0',

      totalFarmerCount:
          json['tot_farmer_cnt']
                  ?.toString() ??
              '0',

      dayWise:
          (json['day_wise'] as List? ?? [])
              .whereType<Map>()
              .map(
                (item) =>
                    DayWiseVisitModel.fromJson(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ),
              )
              .toList(),
    );
  }
}

class DayWiseVisitModel
    extends DayWiseVisitEntity {
  const DayWiseVisitModel({
    required super.date,
    required super.dealerCount,
    required super.farmerCount,
  });

  factory DayWiseVisitModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DayWiseVisitModel(
      date:
          json['date']?.toString() ?? '',

      dealerCount:
          json['tot_dealer_cnt']
                  ?.toString() ??
              '0',

      farmerCount:
          json['tot_farmer_cnt']
                  ?.toString() ??
              '0',
    );
  }
}
