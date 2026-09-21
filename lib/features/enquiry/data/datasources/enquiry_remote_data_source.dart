import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:flutter/material.dart';

import '../models/district_model.dart';
import '../models/state_model.dart';
import '../models/taluka_model.dart';
import '../models/submit_enquiry_response_model.dart';

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

class EnquiryRemoteDataSourceImpl implements EnquiryRemoteDataSource {
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
    final response = await dioClient.client.post(
      ApiClient.getState,
      data: {
        'user_id': userId,
      },
    );

    debugPrint('');
    debugPrint('========== GET STATE RESPONSE ==========');
    debugPrint('USER ID: $userId');
    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('TYPE: ${response.data.runtimeType}');
    debugPrint('DATA: ${response.data}');
    debugPrint('========================================');

    final data = response.data;

    if (data is! List) {
      debugPrint('STATE ERROR: Response is not List');
      return [];
    }

    final List<StateModel> states = [];

    for (final item in data) {
      debugPrint('STATE ITEM: $item');
      debugPrint('STATE ITEM TYPE: ${item.runtimeType}');

      if (item is Map) {
        try {
          final map = Map<String, dynamic>.from(item);

          final model = StateModel.fromJson(map);

          debugPrint(
            'STATE PARSED: id=${model.id}, name=${model.name}',
          );

          states.add(model);
        } catch (e) {
          debugPrint('STATE MODEL ERROR: $e');
        }
      }
    }

    debugPrint('FINAL STATE COUNT: ${states.length}');
    debugPrint('FINAL STATES: $states');

    return states;
  }

  // ============================================================
  // DISTRICTS
  // ============================================================

  @override
  Future<List<DistrictModel>> getDistricts({
    required String userId,
    required String stateId,
  }) async {
    final response = await dioClient.client.post(
      ApiClient.getDistrictTaluka,
      data: {
        'user_id': userId,
        'state_id': stateId,
      },
    );

    debugPrint('');
    debugPrint('========== GET DISTRICT RESPONSE ==========');
    debugPrint('USER ID: $userId');
    debugPrint('STATE ID: $stateId');
    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('TYPE: ${response.data.runtimeType}');
    debugPrint('DATA: ${response.data}');
    debugPrint('===========================================');

    final data = response.data;

    if (data is! List) {
      debugPrint('DISTRICT ERROR: Response is not List');
      return [];
    }

    final List<DistrictModel> districts = [];

    for (final item in data) {
      debugPrint('DISTRICT ITEM: $item');

      if (item is Map) {
        try {
          final map = Map<String, dynamic>.from(item);

          final model = DistrictModel.fromJson(map);

          debugPrint(
            'DISTRICT PARSED: id=${model.id}, name=${model.name}',
          );

          districts.add(model);
        } catch (e) {
          debugPrint('DISTRICT MODEL ERROR: $e');
        }
      }
    }

    debugPrint('FINAL DISTRICT COUNT: ${districts.length}');
    debugPrint('FINAL DISTRICTS: $districts');

    return districts;
  }

  // ============================================================
  // TALUKAS
  // ============================================================

  @override
  Future<List<TalukaModel>> getTalukas({
    required String userId,
    required String districtId,
  }) async {
    final response = await dioClient.client.post(
      ApiClient.getDistrictTaluka,
      data: {
        'user_id': userId,
        'dist_id': districtId,
      },
    );

    debugPrint('');
    debugPrint('========== GET TALUKA RESPONSE ==========');
    debugPrint('USER ID: $userId');
    debugPrint('DISTRICT ID: $districtId');
    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('TYPE: ${response.data.runtimeType}');
    debugPrint('DATA: ${response.data}');
    debugPrint('==========================================');

    final data = response.data;

    if (data is! List) {
      debugPrint('TALUKA ERROR: Response is not List');
      return [];
    }

    final List<TalukaModel> talukas = [];

    for (final item in data) {
      debugPrint('TALUKA ITEM: $item');

      if (item is! Map) {
        continue;
      }

      final map = Map<String, dynamic>.from(item);

      // --------------------------------------------------------
      // CASE 1: API returns nested taluka list
      // --------------------------------------------------------

      final nestedTaluka = map['taluka'];

      if (nestedTaluka is List) {
        debugPrint(
          'NESTED TALUKA COUNT: ${nestedTaluka.length}',
        );

        for (final talukaItem in nestedTaluka) {
          if (talukaItem is Map) {
            try {
              final talukaMap =
                  Map<String, dynamic>.from(talukaItem);

              final model =
                  TalukaModel.fromJson(talukaMap);

              debugPrint(
                'TALUKA PARSED: '
                'id=${model.talukaId}, '
                'name=${model.name}',
              );

              talukas.add(model);
            } catch (e) {
              debugPrint(
                'TALUKA MODEL ERROR: $e',
              );
            }
          }
        }

        continue;
      }

      // --------------------------------------------------------
      // CASE 2: API directly returns taluka objects
      // --------------------------------------------------------

      try {
        final model = TalukaModel.fromJson(map);

        debugPrint(
          'DIRECT TALUKA PARSED: '
          'id=${model.talukaId}, '
          'name=${model.name}',
        );

        if (model.talukaId.isNotEmpty) {
          talukas.add(model);
        }
      } catch (e) {
        debugPrint(
          'DIRECT TALUKA MODEL ERROR: $e',
        );
      }
    }

    debugPrint('FINAL TALUKA COUNT: ${talukas.length}');
    debugPrint('FINAL TALUKAS: $talukas');

    return talukas;
  }

  // ============================================================
  // SUBMIT ENQUIRY
  // ============================================================

  @override
  Future<SubmitEnquiryResponseModel> submitEnquiry({
    required Map<String, String> params,
  }) async {
    final response = await dioClient.client.post(
      ApiClient.submitEnquiryDetails,
      data: params,
    );

    debugPrint('SUBMIT RESPONSE: ${response.data}');

    final data = response.data;

    if (data is Map) {
      return SubmitEnquiryResponseModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(
      'Invalid submit enquiry response',
    );
  }
}