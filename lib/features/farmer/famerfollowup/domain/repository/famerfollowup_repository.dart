import 'package:demo/features/farmer/famerfollowup/data/model/submitFollowup_mode.dart';

abstract class FamerfollowupRepository {
  Future<SubmitFollowupModel> submitFollowup({
    required int farmerId,
    required String userId,
    required String followUpDate,
    required String followUpType,
    required String remark,
    required double latitude,
    required double longitude,
    required double networkLatitude,
    required double networkLongitude,
    required double gpsLatitude,
    required double gpsLongitude,
    required String geoAddress,
    required String networkInfo,
    required String batteryInfo,
    required String differenceByAndroid,
    required String statusOfFarmer,
    required String activityId,
    String? imagePath,
  });
}
