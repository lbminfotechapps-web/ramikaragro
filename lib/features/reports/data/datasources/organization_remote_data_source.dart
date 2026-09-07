import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/features/reports/data/modles/organization_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class OrganizationRemoteDataSource {
  Future<OrganizationModel> getOrganizationDetails();
}

class OrganizationRemoteDataSourceImpl
    implements OrganizationRemoteDataSource {
  final Dio dio;

  OrganizationRemoteDataSourceImpl({
    required this.dio,
  });

  @override
  Future<OrganizationModel> getOrganizationDetails() async {
    final url =
        '${ApiClient.baseUrl}'
        '${ApiClient.organizationDetails}';

    debugPrint('======================================');
    debugPrint('ORGANIZATION API');
    debugPrint('URL: $url');
    debugPrint('======================================');

    try {
      final response = await dio.get(url);

      debugPrint(
        'STATUS CODE: ${response.statusCode}',
      );

      debugPrint(
        'RESPONSE TYPE: ${response.data.runtimeType}',
      );

      debugPrint(
        'RESPONSE DATA: ${response.data}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'API failed: ${response.statusCode}',
        );
      }

      // Get response
      dynamic responseData = response.data;

      // If API response is String, convert JSON String to Map
      if (responseData is String) {
        debugPrint(
          'Response is String. Decoding JSON...',
        );

        responseData = jsonDecode(responseData);
      }

      // Validate response
      if (responseData is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format: '
          '${responseData.runtimeType}',
        );
      }

      final Map<String, dynamic> data =
          responseData;

      debugPrint(
        'Organization Name: '
        '${data['organizationName']}',
      );

      debugPrint(
        'About Us length: '
        '${data['organizationAboutUs']?.toString().length}',
      );

      return OrganizationModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('======================================');
      debugPrint('DIO ERROR');
      debugPrint('TYPE: ${e.type}');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('ERROR: ${e.error}');
      debugPrint(
        'STATUS: ${e.response?.statusCode}',
      );
      debugPrint(
        'RESPONSE: ${e.response?.data}',
      );
      debugPrint('======================================');

      throw Exception(
        e.message ?? 'Network error',
      );
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('GENERAL ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('======================================');

      rethrow;
    }
  }
}