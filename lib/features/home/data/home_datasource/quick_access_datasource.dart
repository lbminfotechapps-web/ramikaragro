import 'dart:io';

import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/features/home/data/home_model/punch_stat_model.dart';
import 'package:demo/features/home/data/home_model/vehicle_type_model.dart';
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

    return PunchStatModel.fromJson(Map<String, dynamic>.from(transaction));
  }

  Future<List<VehicleTypeModel>> getVehicleType(
    int userId,
    String lastDate,
  ) async {
    final formData = FormData.fromMap({'userId': userId, 'lastDate': lastDate});

    print('Vehicle type request userId: $userId, lastDate: $lastDate');

    final response = await dioClient.client.post(
      ApiClient.getVehicleType,
      data: formData,
    );

    print('Vehicle type HTTP code: ${response.statusCode}');
    print('Vehicle type response: ${response.data}');

    dynamic data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        throw const FormatException('Invalid JSON response from vehicle API');
      }
    }

    if (data is! Map) {
      throw const FormatException('Vehicle API response is not a JSON object');
    }

    if (data['status'] != true) {
      throw FormatException(
        data['message']?.toString() ?? 'Vehicle type request failed',
      );
    }

    final result = data['result'];
    if (result is! List) {
      throw const FormatException('Vehicle API result is invalid');
    }

    print('Vehicle type result count: ${result.length}');

    return result
        .whereType<Map>()
        .map(
          (item) => VehicleTypeModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

Future<Map<String, dynamic>> savePunchDetails(
  Map<String, dynamic> jsonData,
) async {
  try {
    final formData = FormData();

    // ============================================
    // NORMAL FORM FIELDS
    // ============================================
    for (final entry in jsonData.entries) {
      final value = entry.value;

      if (value is File) {
        continue;
      }

      formData.fields.add(
        MapEntry(
          entry.key,
          value?.toString() ?? '',
        ),
      );
    }

    // ============================================
    // STARTING KM IMAGE
    // ============================================
    final startingFile = jsonData['startingKmImage'];

    if (startingFile is File) {
      final multipartFile = await MultipartFile.fromFile(
        startingFile.path,
        filename: 'startingKmImage.jpg',
      );

      formData.files.add(
        MapEntry(
          'startingKmImage',
          multipartFile,
        ),
      );
    }

    // ============================================
    // CLOSING KM IMAGE
    // ============================================
    final closingFile = jsonData['closingKmImage'];

    if (closingFile is File) {
      final multipartFile = await MultipartFile.fromFile(
        closingFile.path,
        filename: 'closingKmImage.jpg',
      );

      formData.files.add(
        MapEntry(
          'closingKmImage',
          multipartFile,
        ),
      );
    }

    // ============================================
    // DEBUG REQUEST
    // ============================================
    print('========== MULTIPART REQUEST ==========');

    for (final field in formData.fields) {
      print('${field.key}: ${field.value}');
    }

    for (final file in formData.files) {
      print(
        '${file.key}: '
        '${file.value.filename}',
      );
    }

    print('========================================');

    // ============================================
    // API CALL
    // ============================================
    final response = await dioClient.client.post(
      ApiClient.punchAddInOut,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    print(
      'Save punch HTTP code: '
      '${response.statusCode}',
    );

    print(
      'Save punch response: '
      '${response.data}',
    );

    dynamic data = response.data;

    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (e) {
        throw const FormatException(
          'Invalid JSON response from save punch API',
        );
      }
    }

    if (data is! Map) {
      throw const FormatException(
        'Save punch API response is not a JSON object',
      );
    }

    final result = Map<String, dynamic>.from(data);

    if (result['status'] != true) {
      throw FormatException(
        result['message']?.toString() ??
            'Failed to save punch details',
      );
    }

    return result;
  } on DioException catch (e) {
    print('========== DIO ERROR ==========');
    print('URL: ${e.requestOptions.uri}');
    print('Method: ${e.requestOptions.method}');
    print('Status: ${e.response?.statusCode}');
    print('Response: ${e.response?.data}');
    print('Error Type: ${e.type}');
    print('Message: ${e.message}');
    print('================================');

    throw Exception(
      'API Error ${e.response?.statusCode}: '
      '${e.response?.data ?? e.message}',
    );
  } catch (e) {
    print('Save punch unexpected error: $e');
    rethrow;
  }
}
}
