import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/api_constant/api_client.dart';
import '../../../../core/api_constant/dio_client.dart';

import '../models/crop_model.dart';
import '../models/schedule_farmer_model.dart';

abstract class FarmerScheduleRemoteDataSource {
  Future<List<CropModel>> searchCrop({
    required String searchKey,
  });

  Future<List<ScheduleFarmerModel>> searchFarmer({
    required String searchKey,
  });
}

class FarmerScheduleRemoteDataSourceImpl
    implements FarmerScheduleRemoteDataSource {
  final DioClient dioClient;

  FarmerScheduleRemoteDataSourceImpl({
    required this.dioClient,
  });

  // ============================================================
  // RESPONSE TO MAP
  // ============================================================

  Map<String, dynamic>? _toMap(
    dynamic responseData,
  ) {
    try {
      if (responseData == null) {
        return null;
      }

      if (responseData is Map<String, dynamic>) {
        return responseData;
      }

      if (responseData is Map) {
        return Map<String, dynamic>.from(
          responseData,
        );
      }

      if (responseData is String) {
        final String text =
            responseData.trim();

        if (text.isEmpty) {
          return null;
        }

        final dynamic decoded =
            jsonDecode(text);

        if (decoded is Map) {
          return Map<String, dynamic>.from(
            decoded,
          );
        }
      }

      return null;
    } catch (e) {
      print(
        'JSON PARSE ERROR : $e',
      );

      return null;
    }
  }

  bool _isSuccess(
    dynamic status,
  ) {
    return status == true ||
        status == 1 ||
        status.toString() == '1' ||
        status
                .toString()
                .toLowerCase() ==
            'true';
  }

  // ============================================================
  // CROP SEARCH
  // ============================================================

  @override
  Future<List<CropModel>> searchCrop({
    required String searchKey,
  }) async {
    try {
      final String search =
          searchKey.trim();

      print(
        '======================================',
      );
      print(
        'CROP SEARCH',
      );
      print(
        'search_key : $search',
      );
      print(
        '======================================',
      );

      final Response<dynamic> response =
          await dioClient.client.request(
        ApiClient.getCropList,
        data: {
          'search_key': search,
        },
        options: Options(
          method: 'GET',
          contentType:
              Headers.jsonContentType,
        ),
      );

      print(
        'CROP RESPONSE TYPE : '
        '${response.data.runtimeType}',
      );

      print(
        'CROP RESPONSE : '
        '${response.data}',
      );

      final Map<String, dynamic>? data =
          _toMap(
        response.data,
      );

      if (data == null) {
        return [];
      }

      final dynamic status =
          data['status'];

      if (!_isSuccess(status)) {
        return [];
      }

      final dynamic result =
          data['result'];

      if (result is! List) {
        return [];
      }

      final List<CropModel> crops =
          result
              .whereType<Map>()
              .map(
                (
                  item,
                ) =>
                    CropModel.fromJson(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ),
              )
              .where(
                (
                  item,
                ) =>
                    item.cropName
                        .trim()
                        .isNotEmpty,
              )
              .toList();

      print(
        'PARSED CROP COUNT : '
        '${crops.length}',
      );

      return crops;
    } on DioException catch (e) {
      print(
        'CROP API ERROR : '
        '${e.response?.data}',
      );

      throw Exception(
        _dioMessage(
          e,
          'Unable to load crop list.',
        ),
      );
    } catch (e) {
      print(
        'CROP ERROR : $e',
      );

      throw Exception(
        'Unable to load crop list.',
      );
    }
  }

  // ============================================================
  // FARMER SEARCH
  //
  // POST getFarmerList
  // farmerName = lbm
  // ============================================================

  @override
  Future<List<ScheduleFarmerModel>>
      searchFarmer({
    required String searchKey,
  }) async {
    try {
      final String search =
          searchKey.trim();

      print(
        '======================================',
      );
      print(
        'FARMER SEARCH',
      );
      print(
        'farmerName : $search',
      );
      print(
        '======================================',
      );

      final Response<dynamic> response =
          await dioClient.client.post(
        ApiClient.getScheduleFarmerList,
        data: {
          'farmerName': search,
        },
        options: Options(
          contentType:
              Headers
                  .formUrlEncodedContentType,
        ),
      );

      print(
        'FARMER RESPONSE TYPE : '
        '${response.data.runtimeType}',
      );

      print(
        'FARMER RESPONSE : '
        '${response.data}',
      );

      final Map<String, dynamic>? data =
          _toMap(
        response.data,
      );

      if (data == null) {
        print(
          'FARMER RESPONSE PARSE FAILED',
        );

        return [];
      }

      final dynamic status =
          data['status'];

      if (!_isSuccess(status)) {
        print(
          'FARMER STATUS FALSE',
        );

        return [];
      }

      final dynamic result =
          data['result'];

      if (result is! List) {
        print(
          'FARMER RESULT NOT LIST',
        );

        return [];
      }

      print(
        'RAW FARMER COUNT : '
        '${result.length}',
      );

      final List<ScheduleFarmerModel>
          farmers = result
          .whereType<Map>()
          .map(
            (
              item,
            ) =>
                ScheduleFarmerModel.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .where(
            (
              farmer,
            ) =>
                farmer.farmerName
                    .trim()
                    .isNotEmpty,
          )
          .toList();

      print(
        '======================================',
      );

      print(
        'PARSED FARMER COUNT : '
        '${farmers.length}',
      );

      for (final farmer in farmers) {
        print(
          'FARMER => '
          '${farmer.farmerId} | '
          '${farmer.farmerName} | '
          '${farmer.talukaName}',
        );
      }

      print(
        '======================================',
      );

      return farmers;
    } on DioException catch (e) {
      print(
        '======================================',
      );
      print(
        'FARMER API ERROR',
      );
      print(
        'STATUS CODE : '
        '${e.response?.statusCode}',
      );
      print(
        'RESPONSE : '
        '${e.response?.data}',
      );
      print(
        'MESSAGE : '
        '${e.message}',
      );
      print(
        '======================================',
      );

      throw Exception(
        _dioMessage(
          e,
          'Unable to load farmer list.',
        ),
      );
    } catch (e) {
      print(
        'FARMER ERROR : $e',
      );

      throw Exception(
        'Unable to load farmer list.',
      );
    }
  }

  // ============================================================
  // DIO ERROR
  // ============================================================

  String _dioMessage(
    DioException e,
    String defaultMessage,
  ) {
    dynamic data =
        e.response?.data;

    if (data is String) {
      try {
        data =
            jsonDecode(
          data,
        );
      } catch (_) {}
    }

    if (data is Map) {
      final String message =
          data['message']
                  ?.toString()
                  .trim() ??
              '';

      if (message.isNotEmpty) {
        return message;
      }
    }

    if (e.type ==
        DioExceptionType.connectionError) {
      return 'Please check internet connection.';
    }

    if (e.type ==
        DioExceptionType.connectionTimeout) {
      return 'Connection timeout.';
    }

    if (e.type ==
        DioExceptionType.receiveTimeout) {
      return 'Server response timeout.';
    }

    return defaultMessage;
  }
}