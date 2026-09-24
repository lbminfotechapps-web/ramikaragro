import 'package:equatable/equatable.dart';

abstract class DealerEevent extends Equatable {
  const DealerEevent();

  @override
  List<Object?> get props => [];
}

class DealerListEvent extends DealerEevent {
  final String user_id;
  final String latitude;
  final String longitude;
  final String searchText;
  final String type;

  const DealerListEvent({
    required this.user_id,
    required this.latitude,
    required this.longitude,
    required this.searchText,
    required this.type,
  });

  @override
  List<Object> get props => [user_id, latitude, longitude, searchText, type];
}

class AddDealerLocation extends DealerEevent {
  final String dealerId;
  final String userId;
  final String locationHistoryString;

  final String latitude;
  final String longitude;

  final String networkLatitude;
  final String networkLongitude;

  final String gpsLatitude;
  final String gpsLongitude;

  final String geoAddress;

  final String mobileInfo;
  final String mobileImei;

  final String networkInfo;
  final String batteryInfo;

  const AddDealerLocation({
    required this.dealerId,
    required this.userId,
    required this.locationHistoryString,
    required this.latitude,
    required this.longitude,
    required this.networkLatitude,
    required this.networkLongitude,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.geoAddress,
    this.mobileInfo = '',
    this.mobileImei = '',
    required this.networkInfo,
    required this.batteryInfo,
  });

  @override
  List<Object?> get props => [
    dealerId,
    userId,
    locationHistoryString,
    latitude,
    longitude,
    networkLatitude,
    networkLongitude,
    gpsLatitude,
    gpsLongitude,
    geoAddress,
    mobileInfo,
    mobileImei,
    networkInfo,
    batteryInfo,
  ];
}
