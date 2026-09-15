import 'package:demo/features/salesreturnhistory/domain/entities/dealer_name_entity.dart';

class DealerNameModel extends DealerNameEntity {
  const DealerNameModel({
    required super.fldOutletId,
    required super.fldOutletName,
  });

  factory DealerNameModel.fromJson(Map<String, dynamic> json) {
    return DealerNameModel(
      fldOutletId: json['fld_outlet_id']?.toString() ?? '',
      fldOutletName: json['fld_outlet_name']?.toString() ?? '',
    );
  }
}
