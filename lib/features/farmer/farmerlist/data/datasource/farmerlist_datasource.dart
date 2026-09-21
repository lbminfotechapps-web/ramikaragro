import 'dart:convert';

import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/farmer/farmerlist/data/model/farmerlist_model.dart';
import 'package:dio/dio.dart';

class FarmerListDataSource {
  final DioClient dioClient;

  FarmerListDataSource({required this.dioClient});

  Future<List<FarmerlistModel>> fetchFarmerList(
    int userId,
    int limit,
    String searchKey,
  ) async {
    try {
      // ------------------------------------------
      // FORM DATA
      // ------------------------------------------
      final formData = FormData.fromMap({
        'user_id': userId.toString(),

        'searchText': searchKey,
        'startLimit': limit.toString(),
      });

      print('userId%%%$userId');

      print('logitude%%%$searchKey');
      print('limit%%%$limit');
      final response = await dioClient.client.post(
        '/getFarmerDetails',
        data: formData,
      );

      print('farmer list response####$response');

      dynamic data = response.data;

      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (e) {
          throw const FormatException('Invalid JSON response from farmer API');
        }
      }

      if (data is! Map<String, dynamic>) {
        throw const FormatException('Farmer API response is not a JSON object');
      }

      final bool apiStatus = data['status'] == true;
      final bool apiResponse = data['response'] == true;

      final String message = data['message']?.toString() ?? '';

      final dynamic records = data['result'];

      if (apiStatus && !apiResponse && records is List && records.isEmpty) {
        print('========================================');
        print('NO FARMER RECORDS FOUND');
        print('Returning EMPTY LIST');
        print('========================================');

        return [];
      }

      if (!apiStatus || !apiResponse) {
        throw Exception(
          message.isNotEmpty ? message : 'Failed to fetch farmer list',
        );
      }

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

      return farmers;
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}
