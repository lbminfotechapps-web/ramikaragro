import 'package:equatable/equatable.dart';

class QuickAccessEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PunchStatEvent extends QuickAccessEvent {
  final int userId;

  PunchStatEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class VehicleTypeEvent extends QuickAccessEvent {
  final int userId;
  final String lastDate;

  VehicleTypeEvent(this.userId, this.lastDate);

  @override
  List<Object?> get props => [userId, lastDate];
}

class PunchInOutDetailsAddEvent extends QuickAccessEvent {
  final int userId;
  final String inOutStatus;
  final String differenceByAndroid;
  final String locationHistoryString;
  final String batteryInfo;
  final String networkInfo;
  final String pinRemark;
  final String startingClosingKmAmount;
  final String vehicleTypeId;
  final String route;
  final String latitude;
  final String longitude;
  final String networkLatitude;
  final String networkLongitude;
  final String gpsLatitude;
  final String gpsLongitude;
  final String geoAddress;
  final String startingKmImage;
  final String closingKmImage;
  final String activityId;

  PunchInOutDetailsAddEvent({
    required this.userId,
    required this.inOutStatus,
    this.differenceByAndroid = '0.0',
    this.locationHistoryString = '',
    required this.batteryInfo,
    required this.networkInfo,
    required this.pinRemark,
    required this.startingClosingKmAmount,
    required this.vehicleTypeId,
    required this.route,
    required this.latitude,
    required this.longitude,
    required this.networkLatitude,
    required this.networkLongitude,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.geoAddress,
    required this.startingKmImage,
    required this.closingKmImage,
    required this.activityId,
  });

  @override
  List<Object?> get props => [
    userId,
    inOutStatus,
    differenceByAndroid,
    locationHistoryString,
    batteryInfo,
    networkInfo,
    pinRemark,
    startingClosingKmAmount,
    vehicleTypeId,
    route,
    latitude,
    longitude,
    networkLatitude,
    networkLongitude,
    gpsLatitude,
    gpsLongitude,
    geoAddress,
    startingKmImage,
    closingKmImage,
    activityId,
  ];
}
