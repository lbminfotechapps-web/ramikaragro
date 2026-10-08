import '../../domain/entities/growth_dealer_search.dart';

class GrowthDealerSearchModel
    extends GrowthDealerSearch {
  const GrowthDealerSearchModel({
    required super.dealerId,
    required super.dealerName,
    required super.personName,
    required super.personMobile,
    required super.outletMobile,
    required super.address,
    required super.districtName,
    required super.talukaName,
    required super.code,
    required super.outletType,
    required super.lastVisitDateTime,
  });

  factory GrowthDealerSearchModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GrowthDealerSearchModel(
      dealerId:
          json['fld_outlet_id']
                  ?.toString()
                  .trim() ??
              '',

      dealerName:
          json['fld_outlet_name']
                  ?.toString()
                  .trim() ??
              '',

      personName:
          json['fld_outlet_person']
                  ?.toString()
                  .trim() ??
              '',

      personMobile:
          json['fld_outletper_mobile']
                  ?.toString()
                  .trim() ??
              '',

      outletMobile:
          json['fld_outlet_mobile']
                  ?.toString()
                  .trim() ??
              '',

      address:
          json['fld_outlet_address']
                  ?.toString()
                  .trim() ??
              '',

      districtName:
          json['fld_dist_name']
                  ?.toString()
                  .trim() ??
              '',

      talukaName:
          json['fld_name']
                  ?.toString()
                  .trim() ??
              '',

      code:
          json['fld_code']
                  ?.toString()
                  .trim() ??
              '',

      outletType:
          json['fld_outlet_type']
                  ?.toString()
                  .trim() ??
              '',

      lastVisitDateTime:
          json['last_visit_date_time']
                  ?.toString()
                  .trim() ??
              '',
    );
  }
}