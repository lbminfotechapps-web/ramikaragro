import 'package:demo/features/farmer/farmerregistration/domain/entity/district_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/farmer_details_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/state_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/repository/farmerregistration_repo.dart';

class StateListUsecase {
  final FarmerregistrationRepository farmerregistrationRepository;

  StateListUsecase(this.farmerregistrationRepository);
  Future<List<StateEntity>> getState(String userId) async {
    return farmerregistrationRepository.getStates(userId);
  }

  Future<List<DistrictEntity>> getDistrict(
    String userId,
    String stateId,
  ) async {
    return farmerregistrationRepository.getDistrict(userId, stateId);
  }

  Future<FarmerDetailsEntity> getFarmerDropData() async {
    return farmerregistrationRepository.getFarmerDropData();
  }

  Future<Map<String, dynamic>> saveFarmerDetails(
    Map<String, dynamic> jsonData,
  ) async {
    return farmerregistrationRepository.saveFarmerDetails(jsonData);
  }
}
