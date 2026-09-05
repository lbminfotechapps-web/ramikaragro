import 'dart:convert';

import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/farmer/farmerlist/data/model/farmerlist_model.dart';
import 'package:dio/dio.dart';

class FarmerListDataSource {
  final DioClient dioClient;

  FarmerListDataSource({required this.dioClient});

  Future<List<FarmerlistModel>> fetchFarmerList(
    int userId,
    String lattitude,
    String logitude,
    int limit,
    String searchKey,
  ) async {
    try {
      print('========================================');
      print('FARMER API REQUEST');
      print('========================================');
      print('user_id    : $userId');
      print('currentLat : $lattitude');
      print('currentLong: $logitude');
      print('searchText : $searchKey');
      print('startLimit : $limit');
      print('========================================');

      // ------------------------------------------
      // FORM DATA
      // ------------------------------------------
      final formData = FormData.fromMap({
        'user_id': userId.toString(),
        'currentLat': lattitude,
        'currentLong': logitude,
        'searchText': searchKey,
        'startLimit': limit.toString(),
      });

      // ------------------------------------------
      // API CALL
      // ------------------------------------------
      final response = await dioClient.client.post(
        '/getFarmerDetails',
        data: formData,
      );

      dynamic data = response.data;

      print('========================================');
      print('FARMER API RESPONSE');
      print('========================================');
      print('RAW RESPONSE: $data');
      print('RESPONSE TYPE: ${data.runtimeType}');
      print('========================================');

      // ------------------------------------------
      // If response is String, decode JSON
      // ------------------------------------------
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (e) {
          throw const FormatException('Invalid JSON response from farmer API');
        }
      }

      // ------------------------------------------
      // Validate response object
      // ------------------------------------------
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Farmer API response is not a JSON object');
      }

      // ------------------------------------------
      // Read API fields
      // ------------------------------------------
      final bool apiStatus = data['status'] == true;
      final bool apiResponse = data['response'] == true;

      final String message = data['message']?.toString() ?? '';

      final dynamic records = data['result'];

      print('========================================');
      print('FARMER API STATUS');
      print('========================================');
      print('status   : ${data['status']}');
      print('response : ${data['response']}');
      print('message  : $message');
      print('result   : $records');
      print('resultType: ${records.runtimeType}');
      print('========================================');

      // =====================================================
      // IMPORTANT:
      //
      // API returns:
      //
      // status   = true
      // response = false
      // result   = []
      // message  = Record Not Found
      //
      // This is NOT an API error.
      // It means there are simply no matching farmers.
      // =====================================================

      if (apiStatus && !apiResponse && records is List && records.isEmpty) {
        print('========================================');
        print('NO FARMER RECORDS FOUND');
        print('Returning EMPTY LIST');
        print('========================================');

        return [];
      }

      // ------------------------------------------
      // Actual API error
      // ------------------------------------------
      if (!apiStatus || !apiResponse) {
        throw Exception(
          message.isNotEmpty ? message : 'Failed to fetch farmer list',
        );
      }

      // ------------------------------------------
      // Validate result
      // ------------------------------------------
      if (records is! List) {
        throw FormatException(
          'Farmer result is not a List. '
          'Actual type: ${records.runtimeType}',
        );
      }

      print('TOTAL FARMER RECORDS: ${records.length}');

      // ------------------------------------------
      // Empty result
      // ------------------------------------------
      if (records.isEmpty) {
        print('NO FARMER RECORDS FOUND');
        return [];
      }

      // ------------------------------------------
      // Convert JSON → Model
      // ------------------------------------------
      final List<FarmerlistModel> farmers = [];

      for (final item in records) {
        if (item is Map<String, dynamic>) {
          try {
            final farmer = FarmerlistModel.fromJson(item);

            farmers.add(farmer);

            print(
              'PARSED FARMER -> '
              'ID: ${farmer.farmerId}, '
              'NAME: ${farmer.farmerName}',
            );
          } catch (e) {
            print('FAILED TO PARSE FARMER RECORD: $e');
          }
        } else {
          print(
            'SKIPPED INVALID FARMER RECORD: '
            '${item.runtimeType}',
          );
        }
      }

      print('========================================');
      print('FARMER PARSING COMPLETE');
      print('TOTAL PARSED: ${farmers.length}');
      print('========================================');

      return farmers;
    } catch (e, stackTrace) {
      print('========================================');
      print('FARMER API ERROR');
      print('ERROR: $e');
      print('STACK TRACE: $stackTrace');
      print('========================================');

      rethrow;
    }
  }
}
