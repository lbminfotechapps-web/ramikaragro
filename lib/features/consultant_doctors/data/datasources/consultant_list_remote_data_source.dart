
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';

abstract class ConsultantListRemoteDataSource {
  Future<List<Map<String, dynamic>>> getDoctors({
    required String userId,
    String search = '',
    String districtId = '',
    String talukaId = '',
  });
}

class ConsultantListRemoteDataSourceImpl
    implements ConsultantListRemoteDataSource {
  final DioClient dioClient;

  const ConsultantListRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<List<Map<String, dynamic>>> getDoctors({
    required String userId,
    String search = '',
    String districtId = '',
    String talukaId = '',
  }) async {
    if (userId.trim().isEmpty || userId.trim() == '0') {
      throw Exception('Invalid user ID');
    }

    final requestData = <String, dynamic>{
      'user_id': userId,
      'search': search,
      'district_id': districtId,
      'taluka_id': talukaId,
    };

    try {
      debugPrint('========== GET DOCTOR LIST ==========');
      debugPrint('USER ID: $userId');

      final Response<dynamic> response =
          await dioClient.client.post<dynamic>(
        ApiClient.getDoctorList,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          headers: {'Accept': 'application/json'},
        ),
      );

      debugPrint('HTTP CODE: ${response.statusCode}');
      debugPrint(
        'RESPONSE CONTENT TYPE: '
        '${response.headers.value('content-type')}',
      );

      // Handle PHP APIs that return text containing JSON.
      dynamic body = response.data;

      for (int attempt = 0; attempt < 2; attempt++) {
        if (body is! String) break;

        final raw = body.trim();

        if (raw.isEmpty) {
          throw const FormatException(
            'Doctor list API returned an empty response',
          );
        }

        try {
          body = jsonDecode(raw);
        } on FormatException {
          debugPrint(
            'NON-JSON RESPONSE PREVIEW: '
            '${raw.substring(
              0,
              raw.length > 250 ? 250 : raw.length,
            )}',
          );
          throw const FormatException(
            'Server returned invalid JSON. '
            'Check API URL and server response.',
          );
        }
      }

      if (body is! Map) {
        debugPrint('RESPONSE TYPE: ${body.runtimeType}');

        throw FormatException(
          'Expected JSON object but received '
          '${body.runtimeType}',
        );
      }

      final data = Map<String, dynamic>.from(body);

      final status = data['status'];
      final isSuccess =
          status == true ||
          status == 1 ||
          status.toString().toLowerCase() == 'true' ||
          status.toString() == '1';

      if (!isSuccess) {
        throw Exception(
          data['message']?.toString() ??
              'Unable to load doctor list',
        );
      }

      final result = data['result'];

      if (result == null) {
        return <Map<String, dynamic>>[];
      }

      if (result is! List) {
        throw FormatException(
          'Doctor result must be a List; got '
          '${result.runtimeType}',
        );
      }

      final doctors = <Map<String, dynamic>>[];

      for (final item in result) {
        if (item is! Map) {
          throw const FormatException(
            'Invalid doctor record received',
          );
        }

        doctors.add(Map<String, dynamic>.from(item));
      }

      debugPrint('DOCTORS RECEIVED: ${doctors.length}');

      return doctors;
    } on DioException catch (error) {
      debugPrint('DOCTOR LIST DIO ERROR: ${error.message}');
      debugPrint('HTTP STATUS: ${error.response?.statusCode}');

      throw Exception(
        'Doctor list request failed: ${error.message}',
      );
    } catch (error) {
      debugPrint('DOCTOR LIST ERROR: $error');
      rethrow;
    }
  }
}
