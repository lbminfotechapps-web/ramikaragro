import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/scheme/data/model/scheme_model.dart';

class SchemeRemoteDataSource {
  final DioClient dioClient;

  SchemeRemoteDataSource({required this.dioClient});

  @override
  Future<List<SchemeResponseModel>> getScheme({
    required String year,
    required String month,
    required String stateId,
  }) async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getSchemedetails,
        data: {'year': year, 'month': month, 'state': stateId},
      );

      print('SCHEME API RESPONSE: ${response.data}');

      dynamic data = response.data;

      // Sometimes Dio receives JSON as String
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid scheme API response');
      }

      if (data['status'] != true) {
        return [];
      }

      final List<dynamic> result = data['result'] ?? [];

      return result.map((e) {
        return SchemeResponseModel.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    } catch (e) {
      print('SchemeRemoteDataSource Error: $e');

      rethrow;
    }
  }
}
