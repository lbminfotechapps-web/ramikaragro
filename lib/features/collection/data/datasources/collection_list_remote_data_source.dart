import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';

import '../models/collection_list_model.dart';

abstract class CollectionListRemoteDataSource {
  Future<List<CollectionListModel>> getCollectionList({
    required String userId,
    required String strMonth,
    required String strStatus,
    required int startLimit,
    required int pageSize,
  });
}

class CollectionListRemoteDataSourceImpl
    implements CollectionListRemoteDataSource {
  final DioClient dioClient;

  CollectionListRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<CollectionListModel>> getCollectionList({
    required String userId,
    required String strMonth,
    required String strStatus,
    required int startLimit,
    required int pageSize,
  }) async {
    try {
      print('==========================================');
      print('COLLECTION API REQUEST');
      print('URL: ${ApiClient.baseUrl}${ApiClient.getCollectionList}');
      print('userId: $userId');
      print('strMonth: $strMonth');
      print('strStatus: $strStatus');
      print('startLimit: $startLimit');
      print('pageSize: $pageSize');
      print('==========================================');

      final response = await dioClient.client.post(
        ApiClient.getCollectionList,

        // IMPORTANT:
        // PHP API expects form-urlencoded data.
        data: {
          'userId': userId,
          'strMonth': strMonth,
          'strStatus': strStatus,
          'startLimit': startLimit.toString(),
          'pageSize': pageSize.toString(),
        },

        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,

          // Don't let Dio throw immediately for 500.
          // This allows us to print the PHP error response.
          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );

      print('==========================================');
      print('COLLECTION API RESPONSE');
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE TYPE: ${response.data.runtimeType}');
      print('RESPONSE DATA:');
      print(response.data);
      print('==========================================');

      // ----------------------------------------------------------
      // HTTP ERROR
      // ----------------------------------------------------------

      if (response.statusCode != 200) {
        throw Exception(
          'Collection API failed. '
          'Status Code: ${response.statusCode}\n'
          'Response: ${response.data}',
        );
      }

      // ----------------------------------------------------------
      // RESPONSE
      // ----------------------------------------------------------

      dynamic responseData = response.data;

      // Because responseType is plain, response.data will normally
      // be a String.
      if (responseData is String) {
        responseData = responseData.trim();

        if (responseData.isEmpty) {
          throw Exception(
            'Collection API returned empty response.',
          );
        }

        // --------------------------------------------------------
        // Normal JSON response
        // --------------------------------------------------------

        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          print('JSON DECODE ERROR: $e');

          throw Exception(
            'Unable to decode Collection API response.\n'
            'Raw response:\n$responseData',
          );
        }
      }

      // ----------------------------------------------------------
      // Validate JSON object
      // ----------------------------------------------------------

      if (responseData is! Map<String, dynamic>) {
        throw Exception(
          'Invalid Collection API response format.',
        );
      }

      final bool status =
          responseData['status'] == true ||
          responseData['status'].toString().toLowerCase() == 'true';

      print('API STATUS: $status');
      print('API MESSAGE: ${responseData['message']}');

      // ----------------------------------------------------------
      // NO RECORD
      // ----------------------------------------------------------

      if (!status) {
        print(
          'COLLECTION API: '
          '${responseData['message'] ?? 'No Record Found'}',
        );

        return [];
      }

      // ----------------------------------------------------------
      // RESULT
      // ----------------------------------------------------------

      final result = responseData['result'];

      if (result == null) {
        print('COLLECTION API: result is null');
        return [];
      }

      if (result is! List) {
        throw Exception(
          'Invalid result format from Collection API.',
        );
      }

      print('TOTAL RECORDS: ${result.length}');

      // ----------------------------------------------------------
      // CONVERT JSON -> MODEL
      // ----------------------------------------------------------

      final List<CollectionListModel> collectionList =
          result
              .whereType<Map<String, dynamic>>()
              .map(
                (json) => CollectionListModel.fromJson(json),
              )
              .toList();

      print(
        'PARSED COLLECTION RECORDS: '
        '${collectionList.length}',
      );

      for (final item in collectionList) {
        print(
          'ID: ${item.id} | '
          'Outlet: ${item.outletName} | '
          'Amount: ${item.paymentAmount} | '
          'Mode: ${item.paymentMode} | '
          'Status: ${item.status}',
        );
      }

      print('==========================================');

      return collectionList;
    } on DioException catch (e) {
      print('==========================================');
      print('COLLECTION DIO ERROR');
      print('TYPE: ${e.type}');
      print('MESSAGE: ${e.message}');
      print('STATUS CODE: ${e.response?.statusCode}');
      print('SERVER RESPONSE: ${e.response?.data}');
      print('REQUEST URL: ${e.requestOptions.uri}');
      print('REQUEST DATA: ${e.requestOptions.data}');
      print(
        'CONTENT TYPE: '
        '${e.requestOptions.contentType}',
      );
      print('==========================================');

      throw Exception(
        e.response?.data?.toString() ??
            e.message ??
            'Collection API request failed.',
      );
    } catch (e) {
      print('==========================================');
      print('COLLECTION API ERROR');
      print('ERROR: $e');
      print('==========================================');

      rethrow;
    }
  }
}