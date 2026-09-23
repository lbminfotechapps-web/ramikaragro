import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/dealer_visit/data/models/dealer_followup_list_model.dart';
import 'package:solufine/features/dealer_visit/data/models/visit_purpose_model.dart';
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

        // Don't add File as normal field.
        if (value is File) {
          continue;
        }

        formData.fields.add(MapEntry(entry.key, value?.toString() ?? ''));
      }

      // ============================================
      // IMAGE
      // ============================================

      final imageValue = jsonData['selfie_capture_image'];

      debugPrint('==========================================');
      debugPrint('DEALER FOLLOWUP IMAGE CHECK');
      debugPrint('IMAGE VALUE: $imageValue');
      debugPrint('IMAGE VALUE TYPE: ${imageValue.runtimeType}');
      debugPrint('==========================================');

      if (imageValue is File) {
        final File imageFile = imageValue;

        debugPrint('IMAGE PATH: ${imageFile.path}');

        final bool imageExists = await imageFile.exists();

        debugPrint('IMAGE EXISTS: $imageExists');

        if (imageExists) {
          final int imageSize = await imageFile.length();

          debugPrint('IMAGE SIZE: $imageSize bytes');

          // ========================================
          // GET FILE EXTENSION
          // ========================================

          String extension = '.jpg';

          final String path = imageFile.path;

          final int dotIndex = path.lastIndexOf('.');

          if (dotIndex != -1) {
            extension = path.substring(dotIndex);
          }

          // ========================================
          // CREATE FILE NAME
          // ========================================

          final DateTime now = DateTime.now();

          final String day = now.day.toString().padLeft(2, '0');

          final String month = now.month.toString().padLeft(2, '0');

          final String year = now.year.toString();

          final String date = '$day$month$year';

          final String timestamp = (now.millisecondsSinceEpoch ~/ 1000)
              .toString();

          final String fileName =
              'DealerFollowupPhoto'
              '${date}_'
              '$timestamp'
              '$extension';

          debugPrint('UPLOAD FILE NAME: $fileName');

          // ========================================
          // CREATE MULTIPART FILE
          // ========================================

          final MultipartFile multipartFile = await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
          );

          // ========================================
          // IMPORTANT
          // SAME PARAMETER AS jsonData
          // ========================================

          formData.files.add(MapEntry('selfie_capture_image', multipartFile));

          debugPrint('IMAGE ADDED AS MULTIPART FILE');

          debugPrint('PARAMETER NAME: selfie_capture_image');

          debugPrint('FILE NAME: $fileName');

          debugPrint('FILE SIZE: $imageSize bytes');
        } else {
          debugPrint('IMAGE FILE DOES NOT EXIST');
        }
      } else {
        debugPrint('NO IMAGE FILE RECEIVED');
      }

      // ============================================
      // DEBUG REQUEST
      // ============================================

      debugPrint('');
      debugPrint('========== MULTIPART REQUEST ==========');

      debugPrint('========== NORMAL FIELDS ==============');

      for (final field in formData.fields) {
        debugPrint('${field.key}: ${field.value}');
      }

      debugPrint('========== MULTIPART FILES ============');

      if (formData.files.isEmpty) {
        debugPrint('NO FILES IN MULTIPART REQUEST');
      }

      for (final file in formData.files) {
        debugPrint('PARAMETER: ${file.key}');

        debugPrint('FILENAME: ${file.value.filename}');

        debugPrint('LENGTH: ${file.value.length}');
      }

      debugPrint('========================================');

      // ============================================
      // API CALL
      // ============================================

      final response = await dioClient.client.post(
        ApiClient.add_remark,
        data: formData,

        // You can actually omit this because Dio
        // automatically handles FormData multipart.
        options: Options(contentType: 'multipart/form-data'),
      );

      // ============================================
      // RESPONSE DEBUG
      // ============================================

      debugPrint(
        'Add Followup HTTP code: '
        '${response.statusCode}',
      );

      debugPrint(
        'Add Followup response: '
        '${response.data}',
      );

      // ============================================
      // PARSE RESPONSE
      // ============================================

      dynamic data = response.data;

      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (e) {
          throw const FormatException(
            'Invalid JSON response from add remark API',
          );
        }
      }

      if (data is! Map) {
        throw const FormatException(
          'Add remark API response is not a JSON object',
        );
      }

      final result = Map<String, dynamic>.from(data);

      // ============================================
      // CHECK API STATUS
      // ============================================

      final responseStatus =
          result['status']?.toString().trim().toLowerCase() ?? '';

      debugPrint('FULL API STATUS: "$responseStatus"');

      // success-48 -> success
      // success-47 -> success
      // success-25 -> success
      // success    -> success

      final mainStatus = responseStatus.split('-').first.trim();

      debugPrint('MAIN API STATUS: "$mainStatus"');

      // ============================================
      // SUCCESS
      // ============================================

      if (mainStatus == 'success') {
        return result;
      }

      // ============================================
      // FAILURE
      // ============================================

      throw FormatException(
        result['message']?.toString() ?? 'Failed to save dealer remark',
      );
    } on DioException catch (e) {
      debugPrint('========== DIO ERROR ==========');

      debugPrint('URL: ${e.requestOptions.uri}');

      debugPrint('Method: ${e.requestOptions.method}');

      debugPrint('Status: ${e.response?.statusCode}');

      debugPrint('Response: ${e.response?.data}');

      debugPrint('Error Type: ${e.type}');

      debugPrint('Message: ${e.message}');

      debugPrint('================================');

      throw Exception(
        'API Error ${e.response?.statusCode}: '
        '${e.response?.data ?? e.message}',
      );
    } catch (e) {
      debugPrint('Add remark unexpected error: $e');

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

  Future<List<DealerFollowupListModel>> getFollowupList(
    String outlet_id,
  ) async {
    final formData = FormData.fromMap({'outlet_id': outlet_id});

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
        .map(
          (item) =>
              DealerFollowupListModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<Map<String, dynamic>> addDealerFollowUp(
  Map<String, dynamic> jsonData,
  File? image,
) async {
  try {
    // ============================================================
    // COPY NORMAL REQUEST DATA
    // ============================================================

    final Map<String, dynamic> formMap =
        Map<String, dynamic>.from(jsonData);

    // Safety:
    // Image must NOT be sent as normal FormData field.
    formMap.remove('selfie_capture_image');
    formMap.remove('image');
    formMap.remove('file');

    print(
      '========== FINAL DEALER FOLLOW UP FORM DATA ==========',
    );

    formMap.forEach((key, value) {
      print('$key: $value');
    });

    print(
      '======================================================',
    );

    // ============================================================
    // CREATE FORM DATA FOR NORMAL FIELDS
    // ============================================================

    final FormData formData =
        FormData.fromMap(formMap);

    // ============================================================
    // ADD SELFIE IMAGE AS MULTIPART FILE
    // ============================================================

    if (image != null) {
      print(
        '========== SELFIE IMAGE CHECK ==========',
      );

      print(
        'IMAGE PATH: ${image.path}',
      );

      final bool exists =
          await image.exists();

      print(
        'IMAGE EXISTS: $exists',
      );

      if (exists) {
        final int imageSize =
            await image.length();

        print(
          'IMAGE SIZE: $imageSize bytes',
        );

        // Get original file name.
        String fileName =
            image.path
                .split(Platform.pathSeparator)
                .last;

        // If filename somehow becomes empty,
        // use fallback filename.
        if (fileName.trim().isEmpty) {
          fileName =
              'DealerSelfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
        }

        // ========================================================
        // CREATE MULTIPART FILE
        // ========================================================

        final MultipartFile multipartFile =
            await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        );

        // ========================================================
        // IMPORTANT
        //
        // THIS IS YOUR BACKEND IMAGE PARAMETER:
        //
        // selfie_capture_image
        // ========================================================

        formData.files.add(
          MapEntry(
            'selfie_capture_image',
            multipartFile,
          ),
        );

        print(
          ' SELFIE IMAGE ADDED TO MULTIPART',
        );

        print(
          'PARAMETER NAME: selfie_capture_image',
        );

        print(
          'FILE NAME: $fileName',
        );

        print(
          'FILE SIZE: $imageSize bytes',
        );
      } else {
        print(
          ' SELFIE IMAGE FILE DOES NOT EXIST',
        );
      }

      print(
        '========================================',
      );
    } else {
      print(
        ' selfie_capture_image: IMAGE IS NULL',
      );
    }

    // ============================================================
    // PRINT ALL NORMAL MULTIPART FIELDS
    // ============================================================

    print(
      '========== DEALER FOLLOW UP MULTIPART FIELDS ==========',
    );

    for (final field in formData.fields) {
      print(
        '${field.key}: ${field.value}',
      );
    }

    // ============================================================
    // PRINT MULTIPART FILES
    // ============================================================

    print(
      '========== DEALER FOLLOW UP MULTIPART FILES ==========',
    );

    if (formData.files.isEmpty) {
      print(
        ' NO FILES ADDED TO MULTIPART REQUEST',
      );
    } else {
      for (final file in formData.files) {
        print(
          'PARAMETER: ${file.key}',
        );

        print(
          'FILENAME: ${file.value.filename}',
        );

        print(
          'LENGTH: ${file.value.length}',
        );
      }
    }

    print(
      '=======================================================',
    );

    // ============================================================
    // API CALL
    // ============================================================

    final response =
        await dioClient.client.post(
      ApiClient.addDealerFollowUp,
      data: formData,
    );

    // ============================================================
    // DEBUG RESPONSE
    // ============================================================

    print(
      'ADD DEALER FOLLOW UP RESPONSE STATUS: '
      '${response.statusCode}',
    );

    print(
      'ADD DEALER FOLLOW UP RESPONSE TYPE: '
      '${response.data.runtimeType}',
    );

    print(
      'ADD DEALER FOLLOW UP RESPONSE: '
      '${response.data}',
    );

    // ============================================================
    // RESPONSE PARSING
    // ============================================================

    dynamic responseData =
        response.data;

    if (responseData is String) {
      final responseString =
          responseData.trim();

      try {
        responseData =
            jsonDecode(
          responseString,
        );
      } catch (e) {
        print(
          'Normal JSON decode failed: $e',
        );

        // Backend may print warning/error before JSON.
        final int jsonStart =
            responseString.indexOf('{');

        if (jsonStart != -1) {
          final String jsonPart =
              responseString
                  .substring(jsonStart)
                  .trim();

          print(
            'Extracted JSON: $jsonPart',
          );

          responseData =
              jsonDecode(
            jsonPart,
          );
        } else {
          throw Exception(
            'Invalid dealer follow-up API response: '
            '$responseString',
          );
        }
      }
    }

    // ============================================================
    // RETURN RESPONSE
    // ============================================================

    if (responseData
        is Map<String, dynamic>) {
      return responseData;
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(
        responseData,
      );
    }

    throw Exception(
      'Invalid dealer follow-up API response',
    );
  } on DioException catch (e) {
    // ============================================================
    // DIO ERROR
    // ============================================================

    print(
      '========== ADD DEALER FOLLOW UP DIO ERROR ==========',
    );

    print(
      'URL: ${e.requestOptions.uri}',
    );

    print(
      'METHOD: ${e.requestOptions.method}',
    );

    print(
      'STATUS CODE: ${e.response?.statusCode}',
    );

    print(
      'RESPONSE: ${e.response?.data}',
    );

    print(
      'MESSAGE: ${e.message}',
    );

    print(
      '====================================================',
    );

    rethrow;
  } catch (e, stackTrace) {
    // ============================================================
    // OTHER ERROR
    // ============================================================

    print(
      '========== ADD DEALER FOLLOW UP ERROR ==========',
    );

    print(
      'ERROR: $e',
    );

    print(
      'STACK TRACE: $stackTrace',
    );

    print(
      '================================================',
    );

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


    


