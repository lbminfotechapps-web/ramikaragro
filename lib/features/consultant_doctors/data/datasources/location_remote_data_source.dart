
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:solufine/core/api_constant/dio_client.dart';

import '../models/location_models.dart';

// ============================================================
// ABSTRACT DATA SOURCE
// ============================================================

abstract class LocationRemoteDataSource {
  Future<List<StateModel>> getStates(String userId);

  Future<List<DistrictModel>> getDistrictsAndTalukas({
    required String userId,
    required String stateId,
  });
}

// ============================================================
// DATA SOURCE IMPLEMENTATION
// ============================================================

class LocationRemoteDataSourceImpl
    implements LocationRemoteDataSource {
  final DioClient dioClient;

  LocationRemoteDataSourceImpl({
    required this.dioClient,
  });

  // ==========================================================
  // API ENDPOINTS
  // ==========================================================

  static const String _baseUrl =
      'https://agroaicrm.com/solufine_agritech/'
      'mobileapi/Mobile_app_for_businessplus_kotlin_new/';

  static const String _stateUrl =
      '${_baseUrl}get_state';

  static const String _districtTalukaUrl =
      '${_baseUrl}get_district_taluka';

  // ==========================================================
  // COMMON POST REQUEST
  // ==========================================================

  Future<List<dynamic>> _postAndReadList({
    required String url,
    required Map<String, String> parameters,
  }) async {
    try {
      debugPrint('======================================');
      debugPrint('LOCATION API URL: $url');
      debugPrint('LOCATION API PARAMS: $parameters');

      final Response<dynamic> response =
          await dioClient.client.post<dynamic>(
        url,
        data: parameters,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint(
        'LOCATION HTTP CODE: ${response.statusCode}',
      );

      final dynamic responseData = response.data;

      dynamic decodedData;

      // Decode response if server sends JSON as String.
      if (responseData is String) {
        final String body = responseData.trim();

        debugPrint(
          'LOCATION RESPONSE: '
          '${body.length > 1500 ? body.substring(0, 1500) : body}',
        );

        if (body.isEmpty) {
          throw const FormatException(
            'Empty response received from location API.',
          );
        }

        try {
          decodedData = jsonDecode(body);
        } on FormatException {
          throw const FormatException(
            'Invalid JSON response from location API. '
            'Check server-side PHP warnings.',
          );
        }
      } else {
        decodedData = responseData;
      }

      // API is expected to return a JSON array.
      if (decodedData is! List) {
        throw const FormatException(
          'Expected a JSON array from location API.',
        );
      }

      debugPrint(
        'LOCATION TOTAL RECORDS: ${decodedData.length}',
      );

      return decodedData;
    } on DioException catch (error) {
      debugPrint('======================================');
      debugPrint('LOCATION API FAILED');
      debugPrint('URL: $url');
      debugPrint('ERROR: ${error.message}');
      debugPrint(
        'HTTP CODE: ${error.response?.statusCode}',
      );
      debugPrint(
        'ERROR RESPONSE: ${error.response?.data}',
      );

      rethrow;
    } catch (error) {
      debugPrint('LOCATION PARSING ERROR: $error');
      rethrow;
    }
  }

  // ==========================================================
  // GET STATES
  // ==========================================================

  @override
  Future<List<StateModel>> getStates(
    String userId,
  ) async {
    final List<dynamic> response = await _postAndReadList(
      url: _stateUrl,
      parameters: {
        'user_id': userId,
      },
    );

    final List<StateModel> states = response
        .whereType<Map>()
        .map(
          (item) => StateModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (item) =>
              item.id.trim().isNotEmpty &&
              item.id != '0' &&
              item.name.trim().isNotEmpty,
        )
        .toList();

    states.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    debugPrint('======================================');
    debugPrint('GET STATES SUCCESS');
    debugPrint('TOTAL STATES: ${states.length}');

    for (final state in states) {
      debugPrint(
        'STATE ID: ${state.id}, NAME: ${state.name}',
      );
    }

    return states;
  }

  // ==========================================================
  // GET DISTRICTS WITH NESTED TALUKAS
  // ==========================================================

  @override
  Future<List<DistrictModel>> getDistrictsAndTalukas({
    required String userId,
    required String stateId,
  }) async {
    final List<dynamic> response = await _postAndReadList(
      url: _districtTalukaUrl,
      parameters: {
        'user_id': userId,
        'state_id': stateId,
      },
    );

    final List<DistrictModel> districts = response
        .whereType<Map>()
        .map(
          (item) => DistrictModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (item) =>
              item.id.trim().isNotEmpty &&
              item.id != '0' &&
              item.name.trim().isNotEmpty,
        )
        .toList();

    districts.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    debugPrint('======================================');
    debugPrint('GET DISTRICT TALUKA SUCCESS');
    debugPrint('TOTAL DISTRICTS: ${districts.length}');

    for (final district in districts) {
      debugPrint(
        'DISTRICT ID: ${district.id}',
      );

      debugPrint(
        'DISTRICT NAME: ${district.name}',
      );

      debugPrint(
        'TOTAL TALUKAS: ${district.talukas.length}',
      );

      for (final taluka in district.talukas) {
        debugPrint(
          'TALUKA ID: ${taluka.id}, '
          'NAME: ${taluka.name}',
        );
      }
    }

    return districts;
  }
}
