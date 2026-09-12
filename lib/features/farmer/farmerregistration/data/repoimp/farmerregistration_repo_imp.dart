import 'package:demo/features/farmer/farmerregistration/data/datasource/farmerregistration_datasource.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/baseresponse_model.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/district_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/farmer_details_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/state_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/repository/farmerregistration_repo.dart';

class FarmerregistrationRepositoryImpl implements FarmerregistrationRepository {
  final FarmerregistrationDatasource datasource;

  FarmerregistrationRepositoryImpl({required this.datasource});

  @override
  Future<BaseResponseModel> farmerRegistration({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await datasource.farmerRegistration(data: data);

      return response;
    } catch (e) {
      throw Exception('Farmer registration failed: $e');
    }
  }

  @override
  Future<List<StateEntity>> getStates(String userId) {
    return datasource.getStates(userId);
  }

  @override
  Future<List<DistrictEntity>> getDistrict(String userId, String stateId) {
    return datasource.getDistrict(userId, stateId);
  }

  @override
  Future<FarmerDetailsEntity> getFarmerDropData() {
    return datasource.getFarmerDropData();
  }

  @override
  Future<Map<String, dynamic>> saveFarmerDetails(
    Map<String, dynamic> jsonData,
  ) {
    return datasource.saveFarmerDetails(jsonData);
  }
}
