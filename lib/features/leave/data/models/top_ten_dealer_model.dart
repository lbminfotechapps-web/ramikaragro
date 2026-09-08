import '../../domain/entities/top_ten_dealer.dart';
import 'pre_details_model.dart';

class TopTenDealerModel extends TopTenDealer {
  const TopTenDealerModel({
    required super.outletName,
    required super.outletAddress,
    required super.visitCount,
    required super.preDetails,
  });

  factory TopTenDealerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> preDetailsJson =
        json['preDetails'] is List
            ? json['preDetails']
            : [];

    return TopTenDealerModel(
      outletName:
          json['fld_outlet_name']?.toString() ??
              json['outlet_name']?.toString() ??
              json['fldOutletName']?.toString() ??
              '',
      outletAddress:
          json['fld_outlet_address']?.toString() ??
              json['outlet_address']?.toString() ??
              json['fldOutletAddress']?.toString() ??
              '',
      visitCount:
          json['visitCount']?.toString() ??
              json['visit_count']?.toString() ??
              json['fld_visit_count']?.toString() ??
              '0',
      preDetails: preDetailsJson
          .map(
            (e) => PreDetailsModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }
}