import 'package:equatable/equatable.dart';

abstract class AddDealerRemarkEvent extends Equatable {
  const AddDealerRemarkEvent();

  @override
  List<Object?> get props => [];
}

class AddDealerRemarkSubmitEvent extends AddDealerRemarkEvent {
  final String userId;
  final String outletId;
  final String purposeId;
  final String amount;
  final String followUpDate;
  final String followUpType;
  final String remark;
  final String latitude;
  final String longitude;
  final String networkLatitude;
  final String networkLongitude;
  final String gpsLatitude;
  final String gpsLongitude;
  final String geoAddress;
  final String strNetworkInfo;
  final String strBatteryInfo;
  final String activityId;

  const AddDealerRemarkSubmitEvent({
    required this.userId,
    required this.outletId,
    required this.purposeId,
    required this.amount,
    required this.followUpDate,
    required this.followUpType,
    required this.remark,
    required this.latitude,
    required this.longitude,
    required this.networkLatitude,
    required this.networkLongitude,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.geoAddress,
    required this.strNetworkInfo,
    required this.strBatteryInfo,
    required this.activityId,
  });
}
 

class ClearLeaveMessageEvent extends AddDealerRemarkEvent {
  const ClearLeaveMessageEvent();
}


class GetPurposeEvent extends AddDealerRemarkEvent{
   final String userId;

 const GetPurposeEvent(this.userId);



}
