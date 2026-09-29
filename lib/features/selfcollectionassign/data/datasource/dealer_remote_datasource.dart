import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/features/selfcollectionassign/data/model/dealer_response_model.dart';

abstract class DealerRemoteDataSource {
  Future<DealerResponseModel> getDealerList({required int userId});
}

class DealerRemoteDataSourceImpl implements DealerRemoteDataSource {
  final Dio dio;

  DealerRemoteDataSourceImpl({required this.dio});

  @override
  Future<DealerResponseModel> getDealerList({required int userId}) async {
    try {
      final response = await dio.post(
        ApiClient.getDealerForSalesTarget,
        data: FormData.fromMap({
          'user_id': userId.toString(),
          'searchText': '',
          'startLimit': 0,
        }),
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200) {
        dynamic data = response.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } on FormatException {
            throw Exception(
              'The dealer service returned an invalid response. Please try again later.',
            );
          }
        }
        if (data is! Map) {
          throw const FormatException('Expected a dealer response JSON object');
        }
        return DealerResponseModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception('Failed to load dealer list');
    } on DioException catch (e) {
      dynamic data = e.response?.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } on FormatException {
          // Non-JSON error bodies should fall back to Dio's error message.
        }
      }
      throw Exception(
        (data is Map ? data['message']?.toString() : null) ??
            e.message ??
            'Something went wrong',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
