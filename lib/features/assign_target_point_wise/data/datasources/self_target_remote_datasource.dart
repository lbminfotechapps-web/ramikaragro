import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api_constant/api_client.dart';
import '../../../../core/api_constant/dio_client.dart';

import '../models/target_group_model.dart';

// ============================================================
// ABSTRACT DATA SOURCE
// ============================================================

abstract class SelfTargetRemoteDataSource {
  // ============================================================
  // GET PRODUCT GROUPS
  // ============================================================

  Future<List<TargetGroupModel>>
      getSelfTarget();

  // ============================================================
  // SUBMIT SELF TARGET
  // ============================================================

  Future<String> submitSelfTarget({
    required String userId,
    required String month,
    //required String groupId,
    required String points,
  });
}

// ============================================================
// IMPLEMENTATION
// ============================================================

class SelfTargetRemoteDataSourceImpl
    implements SelfTargetRemoteDataSource {
  final DioClient dioClient;

  SelfTargetRemoteDataSourceImpl({
    required this.dioClient,
  });

  // ============================================================
  // GET PRODUCT GROUPS
  // ============================================================

  @override
  Future<List<TargetGroupModel>>
      getSelfTarget() async {
    try {
      debugPrint(
        '========================================',
      );

      debugPrint(
        'GET PRODUCT GROUP API',
      );

      debugPrint(
        '${ApiClient.baseUrl}'
        '${ApiClient.getProductGroup}',
      );

      debugPrint(
        '========================================',
      );

      final Response response =
          await dioClient.client.get(
        ApiClient.getProductGroup,
      );

      debugPrint(
        'PRODUCT GROUP RESPONSE:',
      );

      debugPrint(
        '${response.data}',
      );

      debugPrint(
        'RESPONSE TYPE = '
        '${response.data.runtimeType}',
      );

      if (response.data == null) {
        throw Exception(
          'Empty response',
        );
      }

      // ========================================================
      // CONVERT RESPONSE
      // ========================================================

      final Map<String, dynamic> data =
          _convertResponseToMap(
        response.data,
      );

      // ========================================================
      // STATUS
      // ========================================================

      final bool status =
          data['status'] == true;

      final String message =
          data['message']
                  ?.toString() ??
              '';

      if (!status) {
        throw Exception(
          message.isEmpty
              ? 'Unable to load product groups'
              : message,
        );
      }

      // ========================================================
      // RESULT
      // ========================================================

      final dynamic rawResult =
          data['result'];

      if (rawResult == null) {
        return [];
      }

      if (rawResult is! List) {
        throw Exception(
          'Invalid product group result',
        );
      }

      final List<TargetGroupModel> groups =
          rawResult.map(
        (item) {
          if (item is! Map) {
            throw Exception(
              'Invalid product group item',
            );
          }

          return TargetGroupModel.fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          );
        },
      ).toList();

      // ========================================================
      // DEBUG
      // ========================================================

      debugPrint(
        'TOTAL GROUPS = ${groups.length}',
      );

      for (final group in groups) {
        debugPrint(
          'GROUP => '
          'TYPE: ${group.groupType} | '
        //  'ID: ${group.productGroupId} | '
          'POINTS: ${group.groupPoints}',
        );
      }

      debugPrint(
        '========================================',
      );

      return groups;
    } on DioException catch (e) {
      debugPrint(
        'GET PRODUCT GROUP DIO ERROR',
      );

      debugPrint(
        'STATUS CODE = '
        '${e.response?.statusCode}',
      );

      debugPrint(
        'RESPONSE = '
        '${e.response?.data}',
      );

      throw Exception(
        _extractError(
          e.response?.data,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'GET PRODUCT GROUP ERROR = $e',
      );

      debugPrint(
        '$stackTrace',
      );

      throw Exception(
        e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  // ============================================================
  // SUBMIT SELF TARGET
  // ============================================================

  @override
  Future<String> submitSelfTarget({
    required String userId,
    required String month,
   // required String groupId,
    required String points,
  }) async {
    try {
      // ========================================================
      // REQUEST DATA
      // ========================================================

      final Map<String, dynamic> requestData = {
        'user_id': userId,
        'month': month,
       // 'group_id': groupId,
        'points': points,
      };

      debugPrint(
        '========================================',
      );

      debugPrint(
        'SELF TARGET SUBMIT API',
      );

      debugPrint(
        'URL = '
        '${ApiClient.baseUrl}'
        '${ApiClient.add_group_sales_target}',
      );

      debugPrint(
        'USER ID = $userId',
      );

      debugPrint(
        'MONTH = $month',
      );

   

      debugPrint(
        'POINTS = $points',
      );

      debugPrint(
        'REQUEST = $requestData',
      );

      debugPrint(
        '========================================',
      );

      // ========================================================
      // FORM DATA
      // ========================================================

      final FormData formData =
          FormData.fromMap(
        requestData,
      );

      // ========================================================
      // POST API
      // ========================================================

      final Response response =
          await dioClient.client.post(
        ApiClient.add_group_sales_target,

        data:
            formData,
      );

      debugPrint(
        '========================================',
      );

      debugPrint(
        'SELF TARGET RESPONSE',
      );

      debugPrint(
        '${response.data}',
      );

      debugPrint(
        'RESPONSE TYPE = '
        '${response.data.runtimeType}',
      );

      debugPrint(
        '========================================',
      );

      // ========================================================
      // CONVERT RESPONSE
      // ========================================================

      final Map<String, dynamic> data =
          _convertResponseToMap(
        response.data,
      );

      // ========================================================
      // STATUS
      // ========================================================

      final bool status =
          data['status'] == true;

      final String message =
          data['message']
                  ?.toString() ??
              '';

      debugPrint(
        'STATUS = $status',
      );

      debugPrint(
        'MESSAGE = $message',
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (status) {
        return message.isEmpty
            ? 'Target submitted successfully'
            : message;
      }

      // ========================================================
      // FAILURE
      // ========================================================

      throw Exception(
        message.isEmpty
            ? 'Unable to submit target'
            : message,
      );
    } on DioException catch (e) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        'SELF TARGET DIO ERROR',
      );

      debugPrint(
        'STATUS CODE = '
        '${e.response?.statusCode}',
      );

      debugPrint(
        'RESPONSE = '
        '${e.response?.data}',
      );

      debugPrint(
        'MESSAGE = '
        '${e.message}',
      );

      debugPrint(
        '========================================',
      );

      throw Exception(
        _extractError(
          e.response?.data,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        'SELF TARGET SUBMIT ERROR = $e',
      );

      debugPrint(
        '$stackTrace',
      );

      debugPrint(
        '========================================',
      );

      throw Exception(
        e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  // ============================================================
  // CONVERT RESPONSE TO MAP
  // ============================================================

  Map<String, dynamic> _convertResponseToMap(
    dynamic responseData,
  ) {
    if (responseData == null) {
      throw Exception(
        'Empty API response',
      );
    }

    // ==========================================================
    // STRING RESPONSE
    // ==========================================================

    if (responseData is String) {
      final String value =
          responseData.trim();

      if (value.isEmpty) {
        throw Exception(
          'Empty API response',
        );
      }

      try {
        final dynamic decoded =
            jsonDecode(
          value,
        );

        if (decoded is! Map) {
          throw Exception(
            'Invalid API response format',
          );
        }

        return Map<String, dynamic>.from(
          decoded,
        );
      } catch (e) {
        if (e is Exception) {
          rethrow;
        }

        throw Exception(
          'Invalid API response',
        );
      }
    }

    // ==========================================================
    // MAP RESPONSE
    // ==========================================================

    if (responseData is Map) {
      return Map<String, dynamic>.from(
        responseData,
      );
    }

    throw Exception(
      'Invalid response type: '
      '${responseData.runtimeType}',
    );
  }

  // ============================================================
  // EXTRACT ERROR
  // ============================================================

  String _extractError(
    dynamic data,
  ) {
    if (data == null) {
      return 'Something went wrong';
    }

    // ==========================================================
    // MAP
    // ==========================================================

    if (data is Map) {
      return data['message']
              ?.toString() ??
          'Something went wrong';
    }

    // ==========================================================
    // STRING
    // ==========================================================

    if (data is String &&
        data.trim().isNotEmpty) {
      try {
        final dynamic decoded =
            jsonDecode(
          data,
        );

        if (decoded is Map) {
          return decoded['message']
                  ?.toString() ??
              'Something went wrong';
        }
      } catch (_) {
        return data;
      }
    }

    return 'Something went wrong';
  }
}