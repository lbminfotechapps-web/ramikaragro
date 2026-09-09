import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/baseresponse_model.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/state_model.dart';
import 'package:dio/dio.dart';

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

  Future<List<StateModel>> getStates(String userId) async {
    final formData = FormData.fromMap({'user_id': userId});

    final response = await dioClient.client.post(
      ApiClient.getState,
      data: formData,
    );
    print('response $response');
    final data = response.data;
    final List<dynamic> result = data['result'] ?? [];
    return result
        .map((json) => StateModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}
