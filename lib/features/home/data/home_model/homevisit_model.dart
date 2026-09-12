import 'package:demo/features/home/doman/home_entity/homevisit_entity.dart';

class HomeVisitModel extends HomeVisitEntity {
  const HomeVisitModel({
    required super.status,
    required super.message,
    required super.todayTotalVisit,
    required super.todayDealerCnt,
    required super.todayFarmerCnt,
    required super.monthlyTotalVisit,
    required super.monthlyDealerCnt,
    required super.monthlyFarmerCnt,
    required super.monthlyUniqueDealerCnt,
    required super.monthlyUniqueFarmerCnt,
  });

  factory HomeVisitModel.fromJson(Map<String, dynamic> json) {
    return HomeVisitModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',

      todayTotalVisit: json['today_total_visit']?.toString() ?? '0',

      todayDealerCnt: json['today_dealer_cnt']?.toString() ?? '0',

      todayFarmerCnt: json['today_farmer_cnt']?.toString() ?? '0',

      monthlyTotalVisit: json['monthly_total_visit']?.toString() ?? '0',

      monthlyDealerCnt: json['monthly_dealer_cnt']?.toString() ?? '0',

      monthlyFarmerCnt: json['monthly_farmer_cnt']?.toString() ?? '0',

      monthlyUniqueDealerCnt:
          json['monthly_unique_dealer_cnt']?.toString() ?? '0',

      monthlyUniqueFarmerCnt:
          json['monthly_unique_farmer_cnt']?.toString() ?? '0',
    );
  }
}
