import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/top_ten_dealer_model.dart';

abstract class TopTenDealerRemoteDataSource {
  Future<List<TopTenDealerModel>> getTopTenDealerVisit({
    required String userId,
    required int days,
  });
}

class TopTenDealerRemoteDataSourceImpl
    implements TopTenDealerRemoteDataSource {
  final DioClient dioClient;

  TopTenDealerRemoteDataSourceImpl({
    required this.dioClient,
  });

  dynamic _parseResponse(dynamic data) {
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (e) {
        throw ServerException(
          'Invalid JSON response from server',
        );
      }
    }

    return data;
  }

  @override
  Future<List<TopTenDealerModel>> getTopTenDealerVisit({
    required String userId,
    required int days,
  }) async {
    final requestData = {
      'user_id': userId,
      'days': days.toString(),
    };

    try {
      print('');
      print('========================================');
      print('TOP TEN DEALER REQUEST');
      print('========================================');
      print(
        'BASE URL = ${ApiClient.baseUrl}',
      );
      print(
        'ENDPOINT = ${ApiClient.getTopTenDealerVisit}',
      );
      print(
        'FULL URL = ${ApiClient.baseUrl}${ApiClient.getTopTenDealerVisit}',
      );
      print(
        'METHOD = POST',
      );
      print(
        'REQUEST = $requestData',
      );
      print('========================================');

      final response = await dioClient.client.post(
        ApiClient.getTopTenDealerVisit,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,

          // IMPORTANT:
          // Don't let Dio throw automatically for 404.
          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );

      print('');
      print('========================================');
      print('TOP TEN DEALER RESPONSE');
      print('========================================');
      print(
        'URL = ${response.requestOptions.uri}',
      );
      print(
        'STATUS CODE = ${response.statusCode}',
      );
      print(
        'RESPONSE = ${response.data}',
      );
      print('========================================');

      // ------------------------------------
      // HTTP ERROR
      // ------------------------------------

      if (response.statusCode != 200) {
        throw ServerException(
          'Server error: ${response.statusCode}\n'
          'URL: ${response.requestOptions.uri}\n'
          'Response: ${response.data}',
        );
      }

      // ------------------------------------
      // PARSE RESPONSE
      // ------------------------------------

      final data = _parseResponse(response.data);

      if (data is! Map) {
        throw ServerException(
          'Invalid server response',
        );
      }

      // ------------------------------------
      // API STATUS
      // ------------------------------------

      final apiStatus = data['status'];

      if (apiStatus != true) {
        throw ServerException(
          data['message']?.toString() ??
              'No dealer records found',
        );
      }

      // ------------------------------------
      // RESULT
      // ------------------------------------

      final result = data['result'];

      if (result == null) {
        return [];
      }

      if (result is! List) {
        throw ServerException(
          'Invalid dealer list response',
        );
      }

      // ------------------------------------
      // MODEL MAPPING
      // ------------------------------------

      final List<TopTenDealerModel> dealers = [];

      for (final item in result) {
        if (item is Map) {
          dealers.add(
            TopTenDealerModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }

      print(
        'TOTAL DEALERS = ${dealers.length}',
      );

      return dealers;
    }

    // --------------------------------------
    // DIO ERROR
    // --------------------------------------

    on DioException catch (e) {
      print('');
      print('========================================');
      print('TOP TEN DEALER DIO ERROR');
      print('========================================');
      print(
        'URL = ${e.requestOptions.uri}',
      );
      print(
        'METHOD = ${e.requestOptions.method}',
      );
      print(
        'REQUEST = ${e.requestOptions.data}',
      );
      print(
        'STATUS = ${e.response?.statusCode}',
      );
      print(
        'RESPONSE = ${e.response?.data}',
      );
      print(
        'MESSAGE = ${e.message}',
      );
      print(
        'TYPE = ${e.type}',
      );
      print('========================================');

      throw NetworkException(
        e.response?.data?.toString() ??
            e.message ??
            'Network error occurred',
      );
    }

    // --------------------------------------
    // SERVER ERROR
    // --------------------------------------

    on ServerException {
      rethrow;
    }

    // --------------------------------------
    // OTHER ERROR
    // --------------------------------------

    catch (e) {
      print('');
      print('========================================');
      print('TOP TEN DEALER UNKNOWN ERROR');
      print('========================================');
      print(e);
      print('========================================');

      throw NetworkException(
        e.toString(),
      );
    }
  }
}