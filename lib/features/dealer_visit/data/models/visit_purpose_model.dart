import 'package:demo/features/dealer_visit/domain/entities/visit_purpose_entity.dart';

class PurposeModel extends PurposeEntity {
  const PurposeModel({
    required super.purposeId,
    required super.purpose,
    required super.amtFlag,
  });

  factory PurposeModel.fromJson(Map<String, dynamic> json) {
    return PurposeModel(
      purposeId: json['fld_purpose_id']?.toString() ?? '',
      purpose: json['fld_purpose']?.toString() ?? '',
      amtFlag: json['fld_amt_flag']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_purpose_id': purposeId,
      'fld_purpose': purpose,
      'fld_amt_flag': amtFlag,
    };
  }
}