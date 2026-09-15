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
  final String fldFarmerName;
  final String fldAddress;
  final String userId;
  final String fldCategoryId;
  final String state;
  final String fldDemoTypeId;
  final String district;
  final String taluka;
  final String statusOfFarmer;
  final String campaignRadio;
  final String fldMobileNo;
  final String fldMobileNo2;
  final String fldTotalAcre;
  final String fldEmailId;
  final String fldTractorMode;
  final String fldVillage;

  final String selectedProductId;
  final String selectedCropId;
  final String selectedAcers;
  final String selectedSowingDates;
  final String selectedIrrigationId;
  final String selectedCattleId;
  final String selectedCattleCount;

  final String latitude;
  final String longitude;
  final String networkLatitude;
  final String networkLongitude;
  final String gpsLatitude;
  final String gpsLongitude;
  final String differenceByAndroid;

  final String contactPersonName;
  final String meetingLocation;
  final String marketNearby;
  final String aadhaarNo;
  final String remark;
  final String geoAddress;
  final String strNetworkInfo;
  final String currentProductUsed;
  final String strBatteryInfo;
  final String activityId;

  /// Farmer image
  final String image;

  FarmerSubmitDetailsEvent({
    required this.fldFarmerName,
    required this.fldAddress,
    required this.userId,
    required this.fldCategoryId,
    required this.state,
    required this.fldDemoTypeId,
    required this.district,
    required this.taluka,
    required this.statusOfFarmer,
    required this.campaignRadio,
    required this.fldMobileNo,
    required this.fldMobileNo2,
    required this.fldTotalAcre,
    required this.fldEmailId,
    required this.fldTractorMode,
    required this.fldVillage,
    required this.selectedProductId,
    required this.selectedCropId,
    required this.selectedAcers,
    required this.selectedSowingDates,
    required this.selectedIrrigationId,
    required this.selectedCattleId,
    required this.selectedCattleCount,
    required this.latitude,
    required this.longitude,
    required this.networkLatitude,
    required this.networkLongitude,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.differenceByAndroid,
    required this.contactPersonName,
    required this.meetingLocation,
    required this.marketNearby,
    required this.aadhaarNo,
    required this.remark,
    required this.geoAddress,
    required this.strNetworkInfo,
    required this.currentProductUsed,
    required this.strBatteryInfo,
    required this.activityId,
    required this.image,
  });

  @override
  List<Object?> get props => [
        fldFarmerName,
        fldAddress,
        userId,
        fldCategoryId,
        state,
        fldDemoTypeId,
        district,
        taluka,
        statusOfFarmer,
        campaignRadio,
        fldMobileNo,
        fldMobileNo2,
        fldTotalAcre,
        fldEmailId,
        fldTractorMode,
        fldVillage,
        selectedProductId,
        selectedCropId,
        selectedAcers,
        selectedSowingDates,
        selectedIrrigationId,
        selectedCattleId,
        selectedCattleCount,
        latitude,
        longitude,
        networkLatitude,
        networkLongitude,
        gpsLatitude,
        gpsLongitude,
        differenceByAndroid,
        contactPersonName,
        meetingLocation,
        marketNearby,
        aadhaarNo,
        remark,
        geoAddress,
        strNetworkInfo,
        currentProductUsed,
        strBatteryInfo,
        activityId,
        image,
      ];
}