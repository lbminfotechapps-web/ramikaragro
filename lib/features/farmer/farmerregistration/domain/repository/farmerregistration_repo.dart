import 'package:demo/features/farmer/farmerregistration/data/model/baseresponse_model.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/state_entity.dart';

abstract class FarmerregistrationRepository {
  Future<BaseResponseModel> farmerRegistration({
    required Map<String, dynamic> data,
  });

  Future<List<StateEntity>> getStates(String userId);
}
