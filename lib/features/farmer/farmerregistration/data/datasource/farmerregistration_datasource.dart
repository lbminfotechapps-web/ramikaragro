import 'dart:convert';
import 'dart:io';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/baseresponse_model.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/district_model.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/farmer_details_model.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/state_model.dart';
import 'package:dio/dio.dart';

class FarmerregistrationDatasource {
  final DioClient dioClient;

  FarmerregistrationDatasource({required this.dioClient});

  Future<BaseResponseModel> farmerRegistration({
    required Map<String, dynamic> data,
  }) async {
    final response = await dioClient.client.post(
      '/farmer-registration',
      data: data,
    );

    return BaseResponseModel.fromJson(response.data);
  }

  Future<List<StateModel>> getStates(String userId) async {
    final formData = FormData.fromMap({'user_id': userId});

    final response = await dioClient.client.post(
      ApiClient.getState,
      data: formData,
    );

    print('API RESPONSE TYPE: ${response.data.runtimeType}');
    print('API RESPONSE: ${response.data}');

    // API response is a JSON String
    final List<dynamic> result = jsonDecode(response.data.toString());

    print('STATE LIST LENGTH: ${result.length}');

    final List<StateModel> states = result
        .map((json) => StateModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    for (final state in states) {
      print('STATE -> ID: ${state.stateId} | NAME: ${state.stateName}');
    }

    return states;
  }

  Future<List<DistrictModel>> getDistrict(String userId, String stateId) async {
    try {
      final formData = FormData.fromMap({
        "user_id": userId,
        "state_id": stateId,
      });

      final response = await dioClient.client.post(
        ApiClient.getDistrictTaluka,
        data: formData,
      );

      print('API RESPONSE TYPE: ${response.data.runtimeType}');
      print('API RESPONSE: ${response.data}');

      dynamic responseData = response.data;

      // If API returns JSON as String
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      // API response should be List
      if (responseData is! List) {
        throw Exception('Invalid district API response');
      }

      final List<DistrictModel> districts = responseData
          .map(
            (json) => DistrictModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();

      print('DISTRICT COUNT: ${districts.length}');

      for (final district in districts) {
        print('DISTRICT: ${district.fldDistId} - ${district.fldDistName}');

        print('TALUKA COUNT: ${district.taluka.length}');

        for (final taluka in district.taluka) {
          print('TALUKA: ${taluka.fldTalukaId} - ${taluka.fldName}');
        }
      }

      return districts;
    } catch (e) {
      print('GET DISTRICT ERROR: $e');
      rethrow;
    }
  }

  Future<FarmerDetailsModel> getFarmerDropData() async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getCropAndIrigationDetails,
      );

      print('FARMER DATA RESPONSE TYPE: ${response.data.runtimeType}');
      print('FARMER DATA RESPONSE: ${response.data}');

      dynamic responseData = response.data;

      // If Dio returns String, decode it first
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      // Validate response
      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid farmer data API response');
      }

      final farmerDetails = FarmerDetailsModel.fromJson(responseData);

      print('CROP COUNT: ${farmerDetails.cropDetailsData.length}');

      print(
        'IRRIGATION COUNT: '
        '${farmerDetails.irrigationDetailsData.length}',
      );

      print(
        'PRODUCT COUNT: '
        '${farmerDetails.productDetailsData.length}',
      );

      return farmerDetails;
    } catch (e) {
      print('GET FARMER DATA ERROR: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> saveFarmerDetails(
    Map<String, dynamic> data,
  ) async {
    try {
      final formMap = Map<String, dynamic>.from(data);

      if (formMap['image'] is File) {
        final file = formMap['image'] as File;

        formMap['image'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formMap);

      final response = await dioClient.client.post(
        ApiClient.addFarmerDetails,
        data: formData,
      );

      print('SAVE FARMER RESPONSE TYPE: ${response.data.runtimeType}');
      print('SAVE FARMER RESPONSE: ${response.data}');

      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      if (responseData is Map<String, dynamic>) {
        return responseData;
      }

      if (responseData is Map) {
        return Map<String, dynamic>.from(responseData);
      }

      throw Exception('Invalid save farmer API response');
    } catch (e) {
      print('SAVE FARMER ERROR: $e');
      rethrow;
    }
  }
}
