import 'package:demo/features/farmer/farmerregistration/domain/entity/state_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/repository/farmerregistration_repo.dart';

class StateListUsecase {
  final FarmerregistrationRepository farmerregistrationRepository;

  StateListUsecase(this.farmerregistrationRepository);
  Future<List<StateEntity>> getState(String userId) async {
    return farmerregistrationRepository.getStates(userId);
  }
}
