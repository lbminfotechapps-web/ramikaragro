import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/baseresponse_model.dart';

class FarmerregistrationDatasource {
  final DioClient dioClient;

  FarmerregistrationDatasource({required this.dioClient});

  Future<BaseResponseModel> farmerRegistration({
    required Map<String, dynamic> data,
  }) async {
    final response = await dioClient.client.post(
      '/farmer-registration',
      data: data,
    );

    return BaseResponseModel.fromJson(response.data);
  }
}
