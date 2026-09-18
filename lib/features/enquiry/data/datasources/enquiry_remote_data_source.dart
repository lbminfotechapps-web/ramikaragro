import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';

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

class EnquiryRemoteDataSourceImpl
    implements EnquiryRemoteDataSource {
  final DioClient dioClient;

  EnquiryRemoteDataSourceImpl({
    required this.dioClient,
  });

  // ============================================================
  // GET STATES
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

    final dynamic data = response.data;

    final List<dynamic> result;

    if (data is List) {
      result = data;
    } else if (data is Map<String, dynamic>) {
      result = data['result'] is List
          ? data['result'] as List<dynamic>
          : [];
    } else {
      result = [];
    }

    return result
        .whereType<Map<String, dynamic>>()
        .map(StateModel.fromJson)
        .toList();
  }

  // ============================================================
  // GET DISTRICTS
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

    final dynamic data = response.data;

    final List<dynamic> result;

    if (data is List) {
      result = data;
    } else if (data is Map<String, dynamic>) {
      result = data['result'] is List
          ? data['result'] as List<dynamic>
          : [];
    } else {
      result = [];
    }

    return result
        .whereType<Map<String, dynamic>>()
        .map(DistrictModel.fromJson)
        .toList();
  }

  // ============================================================
  // GET TALUKAS
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

    final dynamic data = response.data;

    final List<dynamic> result;

    if (data is List) {
      result = data;
    } else if (data is Map<String, dynamic>) {
      result = data['result'] is List
          ? data['result'] as List<dynamic>
          : [];
    } else {
      result = [];
    }

    final List<TalukaModel> talukas = [];

    for (final item in result) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final String returnedDistrictId =
          item['fld_dist_id']?.toString() ?? '';

      // Only process selected district.
      if (returnedDistrictId != districtId) {
        continue;
      }

      final dynamic talukaData = item['taluka'];

      if (talukaData is! List) {
        continue;
      }

      for (final taluka in talukaData) {
        if (taluka is Map<String, dynamic>) {
          talukas.add(
            TalukaModel.fromJson(taluka),
          );
        }
      }
    }

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

    final dynamic data = response.data;

    if (data is Map<String, dynamic>) {
      return SubmitEnquiryResponseModel.fromJson(data);
    }

    throw Exception(
      'Invalid submit enquiry response',
    );
  }
}