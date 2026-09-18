import 'dart:convert';
import 'dart:io';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/dealer_visit/data/models/dealer_followup_list_model.dart';
import 'package:demo/features/dealer_visit/data/models/visit_purpose_model.dart';
import 'package:dio/dio.dart';

class DealerVisitDataSource {
  final DioClient dioClient;

  DealerVisitDataSource(this.dioClient);

  dynamic _parseResponse(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    }

    return data;
  }

  Future<Map<String, dynamic>> addRemark(Map<String, dynamic> jsonData) async {
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

        formData.fields.add(MapEntry(entry.key, value?.toString() ?? ''));
      }

      final closingFile = jsonData['selfie_capture_image'];

      if (closingFile is File) {
        final multipartFile = await MultipartFile.fromFile(
          closingFile.path,
          filename: 'closingKmImage.jpg',
        );

        formData.files.add(MapEntry('closingKmImage', multipartFile));
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
        ApiClient.add_remark,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      print(
        'Add Followup HTTP code: '
        '${response.statusCode}',
      );

      print(
        'Add Followup response: '
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
          result['message']?.toString() ?? 'Failed to save punch details',
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

  Future<List<PurposeModel>> getPurpose(String userId) async {
    final formData = FormData.fromMap({'userId': userId});

    print('userid $userId');

    final response = await dioClient.client.post(
      ApiClient.getdealervisitpurpose,
      data: formData,
    );

    print('status: ${response.statusCode}');
    print('response: ${response.data}');

    dynamic data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        throw const FormatException('Invalid JSON response from  API');
      }
    }

    if (data is! Map) {
      throw const FormatException('Menu API response is not a JSON object');
    }

    final result = data['result'];
    if (result is! List) {
      throw const FormatException('API result is not a List');
    }

    return result
        .whereType<Map>()
        .map((item) => PurposeModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

Future<List<DealerFollowupListModel>> getFollowupList(String outlet_id) async {
    final formData = FormData.fromMap({
      'outlet_id': outlet_id,
  
    });

    print('outlet_id $outlet_id');

    final response = await dioClient.client.post(
      ApiClient.remark_list,
      data: formData,
    );

    print('status: ${response.statusCode}');
    print('response: ${response.data}');

    dynamic data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        throw const FormatException('Invalid JSON response from  API');
      }
    }

    if (data is! Map) {
      throw const FormatException('Menu API response is not a JSON object');
    }

    final result = data['data'];
    if (result is! List) {
      throw const FormatException('API result is not a List');
    }

    return result
        .whereType<Map>()
        .map((item) => DealerFollowupListModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }



    Future<Map<String, dynamic>> addDealerFollowUp(
      Map<String, dynamic> jsonData,
    ) async {
      try {
        final formMap = Map<String, dynamic>.from(jsonData);

        print('========== FINAL DEALER FOLLOW UP FORM DATA ==========');

        formMap.forEach((key, value) {
          if (key == 'image' || key == 'file') {
            print('$key: FILE');
          } else {
            print('$key: $value');
          }
        });

        print('======================================');

        final formData = FormData.fromMap(formMap);

        print('========== DEALER FOLLOW UP MULTIPART FIELDS ==========');

        for (final field in formData.fields) {
          print('${field.key}: ${field.value}');
        }

        print('======================================');

        final response = await dioClient.client.post(
          ApiClient.addDealerFollowUp,
          data: formData,
        );

        print('ADD DEALER FOLLOW UP RESPONSE STATUS: ${response.statusCode}');

        print(
          'ADD DEALER FOLLOW UP RESPONSE TYPE: ${response.data.runtimeType}',
        );

        print('ADD DEALER FOLLOW UP RESPONSE: ${response.data}');

        dynamic responseData = response.data;

        if (responseData is String) {
          final responseString = responseData.trim();

          try {
            responseData = jsonDecode(responseString);
          } catch (e) {
            print('Normal JSON decode failed: $e');

            // Handles cases where backend prints
            // warning/error text before JSON.
            final jsonStart = responseString.indexOf('{');

            if (jsonStart != -1) {
              final jsonPart = responseString.substring(jsonStart).trim();

              print('Extracted JSON: $jsonPart');

              responseData = jsonDecode(jsonPart);
            } else {
              throw Exception(
                'Invalid dealer follow-up API response: $responseString',
              );
            }
          }
        }

        if (responseData is Map<String, dynamic>) {
          return responseData;
        }

        if (responseData is Map) {
          return Map<String, dynamic>.from(responseData);
        }

        throw Exception('Invalid dealer follow-up API response');
      } catch (e) {
        print('ADD DEALER FOLLOW UP ERROR: $e');
        rethrow;
      }
    }

    Future<Map<String, dynamic>> updateDealer(
      Map<String, dynamic> jsonData,
    ) async {
      try {
        final formMap = Map<String, dynamic>.from(jsonData);

        print('========== FINAL UPDATE DEALER FORM DATA ==========');

        formMap.forEach((key, value) {
          print('$key: $value');
        });

        print('====================================================');

        // ============================================
        // FORM DATA
        // ============================================
        final formData = FormData.fromMap(formMap);

        print('========== UPDATE DEALER MULTIPART FIELDS ==========');

        for (final field in formData.fields) {
          print('${field.key}: ${field.value}');
        }

        print('====================================================');

        // ============================================
        // API CALL
        // ============================================
        final response = await dioClient.client.post(
          ApiClient.updateDealerFollowUp,
          data: formData,
        );

        print(
          'UPDATE DEALER RESPONSE STATUS: '
          '${response.statusCode}',
        );

        print(
          'UPDATE DEALER RESPONSE TYPE: '
          '${response.data.runtimeType}',
        );

        print(
          'UPDATE DEALER RESPONSE: '
          '${response.data}',
        );

        // ============================================
        // RESPONSE PARSING
        // ============================================
        dynamic responseData = response.data;

        if (responseData is String) {
          final responseString = responseData.trim();

          try {
            responseData = jsonDecode(responseString);
          } catch (e) {
            print('Normal JSON decode failed: $e');

            // ============================================
            // HANDLE TEXT BEFORE JSON
            // ============================================
            final jsonStart = responseString.indexOf('{');

            if (jsonStart != -1) {
              final jsonPart = responseString.substring(jsonStart).trim();

              print('Extracted JSON: $jsonPart');

              responseData = jsonDecode(jsonPart);
            } else {
              throw Exception(
                'Invalid update dealer API response: '
                '$responseString',
              );
            }
          }
        }

        // ============================================
        // RETURN RESPONSE
        // ============================================
        if (responseData is Map<String, dynamic>) {
          return responseData;
        }

        if (responseData is Map) {
          return Map<String, dynamic>.from(responseData);
        }

        throw Exception('Invalid update dealer API response');
      } catch (e) {
        print('UPDATE DEALER ERROR: $e');

        rethrow;
      }
    }
  }

