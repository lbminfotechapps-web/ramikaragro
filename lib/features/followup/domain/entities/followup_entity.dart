import 'package:equatable/equatable.dart';

class FollowupEntity extends Equatable {
  final String name;
  final String type;
  final String date;
  final String time;
  final String remark;
  final String followupType;
  final String followupDate;
  final String outletId;
  final String farmerId;
  final String mobileNo;

  const FollowupEntity({
    required this.name,
    required this.type,
    required this.date,
    required this.time,
    required this.remark,
    required this.followupType,
    required this.followupDate,
    required this.outletId,
    required this.farmerId,
    required this.mobileNo,
  });

  @override
  List<Object?> get props => [
        name,
        type,
        date,
        time,
        remark,
        followupType,
        followupDate,
        outletId,
        farmerId,
        mobileNo,
      ];
}