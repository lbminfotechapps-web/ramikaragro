import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/features/home/data/home_model/punch_stat_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class QuickAccessDatasource {
  final DioClient dioClient;

  QuickAccessDatasource(this.dioClient);

  Future<PunchStatModel> getPunchStatus(int userId) async {
    final formData = FormData.fromMap({'userId': userId});

    print('Punch status request userId: $userId');

    final response = await dioClient.client.post(
      ApiClient.punchStatus,
      data: formData,
    );

    print('Punch status HTTP code: ${response.statusCode}');
    print('Punch status response: ${response.data}');

    dynamic data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        throw const FormatException('Invalid JSON response from punch API');
      }
    }

    if (data is! Map) {
      throw const FormatException('Punch API response is not a JSON object');
    }

    if (data['status'] != true) {
      throw FormatException(
        data['message']?.toString() ?? 'Punch status request failed',
      );
    }

    final result = data['result'];
    if (result is! List || result.isEmpty) {
      throw const FormatException('Punch API result is empty or invalid');
    }

    final transaction = result.first;
    if (transaction is! Map) {
      throw const FormatException('Punch API transaction is invalid');
    }

    return PunchStatModel.fromJson(
      Map<String, dynamic>.from(transaction),
    );
  }
}
