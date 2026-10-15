
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';

import '../models/add_doctor_response_model.dart';

abstract class ConsultantRemoteDataSource {
  Future<AddDoctorResponseModel> addDoctor({
    required String empId,
    required String doctorName,
    required String ownerName,
    required String mobileNo,
    required String address,
    required String state,
    required String district,
    required String taluka,
    required String remark,
  });
}

class ConsultantRemoteDataSourceImpl
    implements ConsultantRemoteDataSource {
  final DioClient dioClient;

  ConsultantRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<AddDoctorResponseModel> addDoctor({
    required String empId,
    required String doctorName,
    required String ownerName,
    required String mobileNo,
    required String address,
    required String state,
    required String district,
    required String taluka,
    required String remark,
  }) async {
    final Map<String, String> params = {
      'empId': empId,
      'doctorName': doctorName,
      'ownerName': ownerName,
      'mobileNo': mobileNo,
      'address': address,
      'state': state,
      'district': district,
      'taluka': taluka,
      'remark': remark,
    };

    try {
      debugPrint('ADD DOCTOR REQUEST START');

      final response = await dioClient.client.post<dynamic>(
        ApiClient.addDoctor,
        data: params,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('ADD DOCTOR HTTP: ${response.statusCode}');
      debugPrint('ADD DOCTOR RESPONSE: ${response.data}');

      dynamic json = response.data;

      if (json is String) {
        json = jsonDecode(json);
      }

      if (json is! Map) {
        throw FormatException(
          'Invalid Add Doctor API response.',
        );
      }

      final result = AddDoctorResponseModel.fromJson(
        Map<String, dynamic>.from(json),
      );

      if (!result.isSuccess) {
        throw Exception(
          result.message.isNotEmpty
              ? result.message
              : 'Unable to add doctor.',
        );
      }

      // A successful response should contain the server ID.
      if (result.doctorId.isEmpty ||
          result.doctorId == '0') {
        throw Exception(
          'Server returned success without a valid doctor ID. '
          'Verify the record before submitting again.',
        );
      }

      debugPrint(
        'DOCTOR ADDED - ID: ${result.doctorId}',
      );

      return result;
    } on DioException catch (error) {
      debugPrint('ADD DOCTOR ERROR: ${error.message}');

      final responseData = error.response?.data;
      String? responseMessage;

      try {
        final decoded = responseData is String
            ? jsonDecode(responseData)
            : responseData;

        if (decoded is Map) {
          responseMessage = decoded['message']?.toString();
        }
      } catch (_) {
        // The server may return an HTML error instead of JSON.
      }

      final message = responseMessage != null &&
              responseMessage.trim().isNotEmpty
          ? responseMessage
          : 'Doctor submission could not be confirmed. '
              'Check server records before retrying.';

      throw Exception(message);
    } on FormatException {
      throw Exception(
        'Invalid response from Add Doctor API.',
      );
    }
  }
}
