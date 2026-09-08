import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';

class PunchStatModel extends PunchStatEntity {
  const PunchStatModel({
    required super.dailyTranId,
    required super.date,
    required super.time,
    required super.inOutStatus,
    required super.macAddress,
    required super.startingKm,
  });

  factory PunchStatModel.fromJson(Map<String, dynamic> json) {
    return PunchStatModel(
      dailyTranId: json['fld_daily_tran_id']?.toString() ?? '',

      date: json['fld_date']?.toString() ?? '',

      time: json['fld_time']?.toString() ?? '',

      inOutStatus: json['fld_in_out_status']?.toString() ?? '',

      macAddress: json['fld_mac_address']?.toString() ?? '',

      startingKm: json['fld_starting_km']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_daily_tran_id': dailyTranId,
      'fld_date': date,
      'fld_time': time,
      'fld_in_out_status': inOutStatus,
      'fld_mac_address': macAddress,
      'fld_starting_km': startingKm,
    };
  }
}
