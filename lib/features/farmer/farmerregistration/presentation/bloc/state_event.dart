// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:equatable/equatable.dart';

class StatesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StateListEvent extends StatesEvent {
  final String userId;
  StateListEvent({required this.userId});
}

class DistrictEvent extends StatesEvent {
  final String userId;
  final String stateId;

  DistrictEvent({required this.stateId, required this.userId});
}

class FarmerDropEvent extends StatesEvent {}

class FarmerSubmitDetailsEvent extends StatesEvent {
  final String selectedSowingDates;
  final String marketNearby;
  final String gpsLongitude;
  final String networkLatitude;
  final String latitude;
  final String statusOfFarmer;
  final String fldTractorMode;
  final String remark;
  final String selectedAcers;
  final String selectedCattleCount;
  final String selectedIrrigationId;
  final String selectedProductId;
  final String activityId;
  final String campaignRadio;
  final String currentProductUsed;
  final String selectedCattleId;
  final String fldCategoryId;
  final String state;
  final String fldDemoTypeId;
  final String fldVillage;
  final String geoAddress;
  final String strNetworkInfo;
  final String longitude;
  final String gpsLatitude;
  final String fldTotalAcre;
  final String aadhaarNo;
  final String fldEmailId;
  final String fldAddress;
  final String fldMobileNo;
  final String strBatteryInfo;
  final String differenceByAndroid;
  final String contactPersonName;
  final String userId;
  final String fldFarmerName;
  final String district;
  final String taluka;
  final String fldMobileNo2;
  final String networkLongitude;

  /// Farmer image
  final String image;

  FarmerSubmitDetailsEvent({
    required this.selectedSowingDates,
    required this.marketNearby,
    required this.gpsLongitude,
    required this.networkLatitude,
    required this.latitude,
    required this.statusOfFarmer,
    required this.fldTractorMode,
    required this.remark,
    required this.selectedAcers,
    required this.selectedCattleCount,
    required this.selectedIrrigationId,
    required this.selectedProductId,
    required this.activityId,
    required this.campaignRadio,
    required this.currentProductUsed,
    required this.selectedCattleId,
    required this.fldCategoryId,
    required this.state,
    required this.fldDemoTypeId,
    required this.fldVillage,
    required this.geoAddress,
    required this.strNetworkInfo,
    required this.longitude,
    required this.gpsLatitude,
    required this.fldTotalAcre,
    required this.aadhaarNo,
    required this.fldEmailId,
    required this.fldAddress,
    required this.fldMobileNo,
    required this.strBatteryInfo,
    required this.differenceByAndroid,
    required this.contactPersonName,
    required this.userId,
    required this.fldFarmerName,
    required this.district,
    required this.taluka,
    required this.fldMobileNo2,
    required this.networkLongitude,
    required this.image,
  });

  @override
  List<Object?> get props => [
    selectedSowingDates,
    marketNearby,
    gpsLongitude,
    networkLatitude,
    latitude,
    statusOfFarmer,
    fldTractorMode,
    remark,
    selectedAcers,
    selectedCattleCount,
    selectedIrrigationId,
    selectedProductId,
    activityId,
    campaignRadio,
    currentProductUsed,
    selectedCattleId,
    fldCategoryId,
    state,
    fldDemoTypeId,
    fldVillage,
    geoAddress,
    strNetworkInfo,
    longitude,
    gpsLatitude,
    fldTotalAcre,
    aadhaarNo,
    fldEmailId,
    fldAddress,
    fldMobileNo,
    strBatteryInfo,
    differenceByAndroid,
    contactPersonName,
    userId,
    fldFarmerName,
    district,
    taluka,
    fldMobileNo2,
    networkLongitude,
    image,
  ];
}
