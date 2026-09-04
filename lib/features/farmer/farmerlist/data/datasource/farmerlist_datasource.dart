import 'dart:ffi';

import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/farmer/farmerlist/data/model/farmerlist_model.dart';

import 'dart:convert';
import 'dart:convert';

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
      // FORM DATA
      final formData = FormData.fromMap({
        'user_id': userId.toString(),
        'currentLat': lattitude,
        'currentLong': logitude,
        'searchText': searchKey,
        'startLimit': limit.toString(),
      });

      final response = await dioClient.client.post(
        '/getFarmerDetails',
        data: formData,
      );

      dynamic data = response.data;

      // ------------------------------------------
      // If response is String, decode JSON
      // ------------------------------------------
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (e) {
          throw FormatException('Invalid JSON response from farmer API');
        }
      }

      // ------------------------------------------
      // Validate response object
      // ------------------------------------------
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Farmer API response is not a JSON object');
      }

      // ------------------------------------------
      // Check API status
      // ------------------------------------------
      final apiStatus = data['status'];
      final apiResponse = data['response'];
      final message = data['message'];

      if (apiStatus != true || apiResponse != true) {
        throw Exception(message?.toString() ?? 'Failed to fetch farmer list');
      }

      // ------------------------------------------
      // Get result
      // ------------------------------------------
      final records = data['result'];

      print('========================================');
      print('RESULT DETAILS');
      print('========================================');

      print('RESULT      : $records');
      print('RESULT TYPE : ${records.runtimeType}');

      if (records is! List) {
        throw FormatException(
          'Farmer result is not a List. '
          'Actual type: ${records.runtimeType}',
        );
      }

      print('TOTAL FARMER RECORDS: ${records.length}');

      if (records.isEmpty) {
        print('NO FARMER RECORDS FOUND');
        return [];
      }

      // ------------------------------------------
      // Convert JSON → Model
      // ------------------------------------------
      final farmers = records.whereType<Map<String, dynamic>>().map((json) {
        final farmer = FarmerlistModel.fromJson(json);

        print(
          'PARSED FARMER -> '
          'ID: ${farmer.farmerId}, '
          'NAME: ${farmer.farmerName}',
        );

        return farmer;
      }).toList();

      return farmers;
    } catch (e, stackTrace) {
      print('ERROR: $e');
      print('STACK TRACE: $stackTrace');

      rethrow;
    }
  }
}
