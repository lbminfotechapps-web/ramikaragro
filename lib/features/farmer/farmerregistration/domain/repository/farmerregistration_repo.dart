// import 'package:solufine/features/farmer/farmerregistration/data/model/baseresponse_model.dart';
// import 'package:solufine/features/farmer/farmerregistration/domain/entity/district_entity.dart';
// import 'package:solufine/features/farmer/farmerregistration/domain/entity/farmer_details_entity.dart';
// import 'package:solufine/features/farmer/farmerregistration/domain/entity/state_entity.dart';

// abstract class FarmerregistrationRepository {
//   Future<BaseResponseModel> farmerRegistration({
//     required Map<String, dynamic> data,
//   });

//   Future<List<StateEntity>> getStates(String userId);

//   Future<List<DistrictEntity>> getDistrict(String userId, String stateId);

//   Future<FarmerDetailsEntity> getFarmerDropData();

//   Future<Map<String, dynamic>> saveFarmerDetails(Map<String, dynamic> jsonData);

//   Future<Map<String, dynamic>> updateFarmerDetails(
//     Map<String, dynamic> jsonData,
//   );
// }


import 'dart:io';

import 'package:solufine/features/farmer/farmerregistration/data/model/baseresponse_model.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/entity/district_entity.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/entity/farmer_details_entity.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/entity/state_entity.dart';

abstract class FarmerregistrationRepository {
  Future<BaseResponseModel> farmerRegistration({
    required Map<String, dynamic> data,
  });

  Future<List<StateEntity>> getStates(
    String userId,
  );

  Future<List<DistrictEntity>> getDistrict(
    String userId,
    String stateId,
  );

  Future<FarmerDetailsEntity> getFarmerDropData();

  // ============================================================
  // CHANGED HERE
  // Fields + actual image file
  // ============================================================

  Future<Map<String, dynamic>> saveFarmerDetails(
    Map<String, dynamic> jsonData,
    File? image,
  );

  Future<Map<String, dynamic>> updateFarmerDetails(
    Map<String, dynamic> jsonData,
  );
}