import '../../domain/entities/not_visited_dealer.dart';

class NotVisitedDealerModel extends NotVisitedDealer {
  const NotVisitedDealerModel({
    required super.mobile,
    required super.outletName,
    required super.outletId,
    required super.address,
    required super.lastTransactionDate,
  });

  factory NotVisitedDealerModel.fromJson( Map<String, dynamic> json,) {
    return NotVisitedDealerModel(
      mobile: json['fld_outletper_mobile']?.toString().trim() ??'',
      outletName: json['fld_outlet_name']?.toString().trim() ??'',
      outletId: json['fld_outlet_id'] ?.toString().trim() ??'',
      address: json['fld_outlet_address']?.toString() .trim() ??'',
      lastTransactionDate:json['last_transaction_date']?.toString().trim(),
    );
  }
}