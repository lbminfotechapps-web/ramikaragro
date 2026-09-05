import 'package:demo/features/farmer/farmerregistration/data/model/baseresponse_model.dart';

abstract class FarmerregistrationRepository {
  Future<BaseResponseModel> farmerRegistration({
    required Map<String, dynamic> data,
  });
}
