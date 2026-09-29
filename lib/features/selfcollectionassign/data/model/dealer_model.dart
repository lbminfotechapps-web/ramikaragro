import '../../domain/entities/dealer_entity.dart';

class DealerModel extends DealerEntity {
  const DealerModel({
    required super.outletId,
    required super.outletName,
    required super.outletMobile,
  });

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    return DealerModel(
      outletId: json['fld_outlet_id']?.toString() ?? '',
      outletName: json['fld_outlet_name']?.toString() ?? '',
      outletMobile: json['fld_outletper_mobile']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_outlet_id': outletId,
      'fld_outlet_name': outletName,
      'fld_outletper_mobile': outletMobile,
    };
  }
}
