import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/scheme/data/model/scheme_model.dart';
import 'package:dio/dio.dart';

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
      final requestData = {
        'year': year,
        'month': month,
        'state': stateId,
        'state_id': stateId,
      };

      print('SCHEME API URL: ${ApiClient.getSchemedetails}');
      print('SCHEME API REQUEST: $requestData');

      final response = await dioClient.client.post(
        ApiClient.getSchemedetails,
        data: FormData.fromMap(requestData),
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );

      print('SCHEME API STATUS CODE: ${response.statusCode}');
      print('SCHEME API RAW RESPONSE: ${response.data}');

      dynamic data = response.data;

      if (data is String) {
        final trimmed = data.trimLeft();
        if (trimmed.startsWith('<')) {
          throw FormatException(
            'Scheme API returned HTML error instead of JSON. ${trimmed.substring(0, trimmed.length > 180 ? 180 : trimmed.length)}',
          );
        }

        data = jsonDecode(data);
      }

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid scheme API response');
      }

      print('SCHEME API STATUS: ${data['status']}');

      if (data['status'] != true) {
        print('SCHEME API RESULT: empty because status is not true');
        return [];
      }

      final List<dynamic> result = data['result'] ?? [];

      print('SCHEME API RESULT COUNT: ${result.length}');

      return result.map((e) {
        return SchemeResponseModel.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    } catch (e) {
      print('SCHEME API ERROR: $e');

      rethrow;
    }
  }
}
