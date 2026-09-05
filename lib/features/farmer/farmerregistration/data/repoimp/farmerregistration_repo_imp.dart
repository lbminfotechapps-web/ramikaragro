import 'package:demo/features/farmer/farmerregistration/data/datasource/farmerregistration_datasource.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/baseresponse_model.dart';
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
}
