import 'package:demo/features/farmer/farmerregistration/data/model/baseresponse_model.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/district_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/farmer_details_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/state_entity.dart';

abstract class FarmerregistrationRepository {
  Future<BaseResponseModel> farmerRegistration({
    required Map<String, dynamic> data,
  });

  Future<List<StateEntity>> getStates(String userId);

  Future<List<DistrictEntity>> getDistrict(String userId, String stateId);

  Future<FarmerDetailsEntity> getFarmerDropData();

  Future<Map<String, dynamic>> saveFarmerDetails(Map<String, dynamic>jsonData);
}
