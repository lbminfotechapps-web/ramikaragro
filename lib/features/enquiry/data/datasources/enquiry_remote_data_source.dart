
import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/enquiry/data/models/submit_enquiry_response_model.dart';
import 'package:dio/dio.dart';

import '../models/state_model.dart';
import '../models/district_model.dart';
import '../models/taluka_model.dart';

abstract class EnquiryRemoteDataSource {
  Future<List<StateModel>> getStates({
    required String userId,
  });

  Future<List<DistrictModel>> getDistricts({
    required String userId,
    required String stateId,
  });

  Future<List<TalukaModel>> getTalukas({
    required String userId,
    required String districtId,
  });

  Future<SubmitEnquiryResponseModel> submitEnquiry({
    required Map<String, String> params,
  });
}

class EnquiryRemoteDataSourceImpl
    implements EnquiryRemoteDataSource {
  final DioClient dioClient;

  EnquiryRemoteDataSourceImpl({
    required this.dioClient,
  });

  // ============================================================
  // STATES
  // ============================================================

  @override
  Future<List<StateModel>> getStates({
    required String userId,
  }) async {
    try {
      print('');
      print('========== GET STATES ==========');
      print('USER ID: $userId');

      final Response response = await dioClient.client.post(
        ApiClient.getState,
        data: FormData.fromMap({
          'user_id': userId,
        }),
      );

      print('STATE RESPONSE: ${response.data}');
      print(
        'STATE RESPONSE TYPE: ${response.data.runtimeType}',
      );

      final List<dynamic> list =
          _extractList(response.data);

      print('STATE LIST LENGTH: ${list.length}');

      final List<StateModel> result = [];

      for (final item in list) {
        if (item is Map) {
          final model = StateModel.fromJson(
            Map<String, dynamic>.from(item),
          );

          print(
            'STATE -> id=${model.id}, name=${model.name}',
          );

          if (model.id.isNotEmpty &&
              model.name.isNotEmpty) {
            result.add(model);
          }
        }
      }

      print('FINAL STATE COUNT: ${result.length}');
      print('================================');

      return result;
    } catch (e, stackTrace) {
      print('GET STATES ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // DISTRICTS
  // ============================================================

  @override
  Future<List<DistrictModel>> getDistricts({
    required String userId,
    required String stateId,
  }) async {
    try {
      print('');
      print('========== GET DISTRICTS ==========');
      print('USER ID : $userId');
      print('STATE ID: $stateId');

      final Response response = await dioClient.client.post(
        ApiClient.getDistrictTaluka,
        data: FormData.fromMap({
          'user_id': userId,
          'state_id': stateId,
        }),
      );

      print('DISTRICT RESPONSE: ${response.data}');
      print(
        'DISTRICT RESPONSE TYPE: '
        '${response.data.runtimeType}',
      );

      final List<dynamic> list =
          _extractList(response.data);

      print('DISTRICT LIST LENGTH: ${list.length}');

      final List<DistrictModel> result = [];

      for (final item in list) {
        if (item is Map) {
          final model = DistrictModel.fromJson(
            Map<String, dynamic>.from(item),
          );

          print(
            'DISTRICT -> id=${model.id}, '
            'name=${model.name}',
          );

          if (model.id.isNotEmpty &&
              model.name.isNotEmpty) {
            result.add(model);
          }
        }
      }

      print(
        'FINAL DISTRICT COUNT: ${result.length}',
      );
      print('====================================');

      return result;
    } catch (e, stackTrace) {
      print('GET DISTRICTS ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // TALUKAS
  // ============================================================

 
@override
Future<List<TalukaModel>> getTalukas({
  required String userId,
  required String districtId,
}) async {
  try {
    print('');
    print('========== GET TALUKAS ==========');
    print('USER ID    : $userId');
    print('DISTRICT ID: $districtId');

    final Response response = await dioClient.client.post(
      ApiClient.getDistrictTaluka,
      data: FormData.fromMap({
        'user_id': userId,
        'dist_id': districtId,
      }),
    );

    print('TALUKA RESPONSE: ${response.data}');
    print(
      'TALUKA RESPONSE TYPE: '
      '${response.data.runtimeType}',
    );

    dynamic responseData = response.data;

    // API is returning JSON as String
    if (responseData is String) {
      responseData = jsonDecode(responseData);
    }

    final List<TalukaModel> result = [];

    if (responseData is List) {
      for (final districtItem in responseData) {
        if (districtItem is! Map) {
          continue;
        }

        final Map<String, dynamic> district =
            Map<String, dynamic>.from(districtItem);

        // Find the selected district
        final String responseDistrictId =
            district['fld_dist_id']?.toString() ?? '';

        print(
          'DISTRICT FROM RESPONSE: $responseDistrictId',
        );

        if (responseDistrictId != districtId) {
          continue;
        }

        // IMPORTANT:
        // Talukas are inside the "taluka" array
        final dynamic talukaData = district['taluka'];

        if (talukaData is! List) {
          print('NO TALUKA LIST FOUND');
          continue;
        }

        print(
          'TALUKA LIST LENGTH: ${talukaData.length}',
        );

        for (final talukaItem in talukaData) {
          if (talukaItem is! Map) {
            continue;
          }

          final model = TalukaModel.fromJson(
            Map<String, dynamic>.from(talukaItem),
          );

          print(
            'TALUKA -> id=${model.talukaId}, '
            'name=${model.name}',
          );

          if (model.talukaId.isNotEmpty &&
              model.name.isNotEmpty) {
            result.add(model);
          }
        }
      }
    }

    print(
      'FINAL TALUKA COUNT: ${result.length}',
    );
    print('=================================');

    return result;
  } catch (e, stackTrace) {
    print('GET TALUKAS ERROR: $e');
    print(stackTrace);
    rethrow;
  }
}




  // ============================================================
  // COMMON RESPONSE PARSER
  // ============================================================

  List<dynamic> _extractList(dynamic responseData) {
    // API returned JSON as String
    if (responseData is String) {
      try {
        final decoded = jsonDecode(responseData);

        // Direct List
        if (decoded is List) {
          return decoded;
        }

        // Map containing result/data/etc.
        if (decoded is Map) {
          return _extractList(decoded);
        }
      } catch (e) {
        print('JSON DECODE ERROR: $e');
      }

      return [];
    }

    // API already returned List
    if (responseData is List) {
      return responseData;
    }

    // API returned Map
    if (responseData is Map) {
      final Map<String, dynamic> map =
          Map<String, dynamic>.from(responseData);

      final possibleKeys = [
        'result',
        'data',
        'states',
        'state',
        'district',
        'districts',
        'taluka',
        'talukas',
      ];

      for (final key in possibleKeys) {
        final value = map[key];

        if (value is List) {
          return value;
        }
      }
    }

    return [];
  }

  // ============================================================
  // SUBMIT ENQUIRY
  // ============================================================

  @override
Future<SubmitEnquiryResponseModel> submitEnquiry({
  required Map<String, String> params,
}) async {
  try {
    print('');
    print('========== SUBMIT ENQUIRY ==========');
    print('PARAMS: $params');

    final Response response = await dioClient.client.post(
      ApiClient.submitEnquiryDetails,

      // IMPORTANT:
      // API expects form-data
      data: FormData.fromMap(params),
    );

    print('SUBMIT RESPONSE: ${response.data}');
    print('SUBMIT RESPONSE TYPE: ${response.data.runtimeType}');

    dynamic responseData = response.data;

    // API may return JSON as String
    if (responseData is String) {
      responseData = jsonDecode(responseData);
    }

    if (responseData is Map) {
      return SubmitEnquiryResponseModel.fromJson(
        Map<String, dynamic>.from(responseData),
      );
    }

    throw Exception(
      'Invalid submit enquiry response: $responseData',
    );
  } catch (e, stackTrace) {
    print('SUBMIT ENQUIRY ERROR: $e');
    print(stackTrace);
    rethrow;
  }
}


}

