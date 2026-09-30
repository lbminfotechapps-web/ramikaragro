import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/core/error/exceptions.dart';
import 'package:solufine/features/assign_target_point_wise/data/models/target_group_model.dart';
import 'package:solufine/features/sales_targrt_achievement/data/models/sales_target_model.dart';
import 'package:solufine/features/sales_targrt_achievement/data/models/target_date_model.dart';
import 'package:dio/dio.dart';

abstract class SalesTargetRemoteDataSource {
  Future<List<SalesTargetDateModel>> getTargetDates();

  Future<SalesTargetModel?> getSalesWiseTarget({
    required String userId,
    required String targetId,
  });

  Future<List<TargetGroupModel>> getGroupWiseAchivPoint({
    required String userId,
    required String targetId,
  });
}

class SalesTargetRemoteDataSourceImpl implements SalesTargetRemoteDataSource {
  final DioClient dioClient;

  SalesTargetRemoteDataSourceImpl({required this.dioClient});

  // =========================================================
  // GET TARGET DATES
  // =========================================================

  @override
  Future<List<SalesTargetDateModel>> getTargetDates() async {
    try {
      print('========================================');
      print('GET SALES TARGET DATES API');
      print('========================================');

      final response = await dioClient.client.post(
        ApiClient.getSalesTargetDates,
        data: {},
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      print('TARGET DATES STATUS: ${response.statusCode}');

      print('TARGET DATES RESPONSE: ${response.data}');

      // -------------------------------------------------------
      // HTTP STATUS
      // -------------------------------------------------------

      if (response.statusCode != 200) {
        throw ServerException('Server error: ${response.statusCode}');
      }

      // -------------------------------------------------------
      // DECODE RESPONSE
      // -------------------------------------------------------

      final dynamic responseData = _decodeResponse(response.data);

      if (responseData is! Map) {
        throw ServerException('Invalid target dates response');
      }

      final Map<String, dynamic> json = Map<String, dynamic>.from(responseData);

      // -------------------------------------------------------
      // API STATUS
      // -------------------------------------------------------

      final bool status = _parseStatus(json['status']);

      print('TARGET DATES PARSED STATUS: $status');

      if (!status) {
        throw ServerException(
          json['message']?.toString() ?? 'No target dates found',
        );
      }

      // -------------------------------------------------------
      // RESULT
      // -------------------------------------------------------

      final dynamic result = json['result'];

      if (result is! List) {
        print('TARGET DATES RESULT IS NOT LIST');

        return [];
      }

      final List<SalesTargetDateModel> dates = result
          .whereType<Map>()
          .map(
            (item) =>
                SalesTargetDateModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      print('TARGET DATES COUNT: ${dates.length}');

      return dates;
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print('========================================');
      print('TARGET DATES DIO ERROR');
      print('MESSAGE: ${e.message}');
      print('STATUS: ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');
      print('========================================');

      throw NetworkException(e.message ?? 'Network error occurred');
    } catch (e) {
      print('TARGET DATES EXCEPTION: $e');

      throw NetworkException(e.toString());
    }
  }

  // =========================================================
  // GET SALES WISE TARGET
  // =========================================================

  @override
  Future<SalesTargetModel?> getSalesWiseTarget({
    required String userId,
    required String targetId,
  }) async {
    try {
      print('========================================');
      print('SALES WISE TARGET API');
      print('========================================');

      print('USER ID: $userId');
      print('TARGET ID: $targetId');

      // -------------------------------------------------------
      // REQUEST DATA
      // -------------------------------------------------------

      final Map<String, dynamic> requestData = {
        'userId': userId.toString(),
        'targetId': targetId.toString(),
      };

      print('SALES TARGET REQUEST: $requestData');

      // -------------------------------------------------------
      // API CALL
      // -------------------------------------------------------

      final response = await dioClient.client.post(
        //  ApiClient.getSalesWiseTarget,
        ApiClient.getSalesWiseGroupTarget,

        // If your PHP API expects form-data
        data: FormData.fromMap(requestData),

        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      // -------------------------------------------------------
      // RESPONSE LOG
      // -------------------------------------------------------

      print('========================================');

      print(
        'SALES TARGET STATUS: '
        '${response.statusCode}',
      );

      print(
        'SALES TARGET RESPONSE: '
        '${response.data}',
      );

      print('========================================');

      // -------------------------------------------------------
      // HTTP STATUS
      // -------------------------------------------------------

      if (response.statusCode != 200) {
        throw ServerException('Server error: ${response.statusCode}');
      }

      // -------------------------------------------------------
      // DECODE
      // -------------------------------------------------------

      final dynamic responseData = _decodeResponse(response.data);

      if (responseData is! Map) {
        throw ServerException('Invalid sales target response');
      }

      final Map<String, dynamic> json = Map<String, dynamic>.from(responseData);

      // -------------------------------------------------------
      // API STATUS
      // -------------------------------------------------------

      final bool status = _parseStatus(json['status']);

      print('SALES TARGET PARSED STATUS: $status');

      // -------------------------------------------------------
      // API FAILURE
      // -------------------------------------------------------

      if (!status) {
        final String message =
            json['message']?.toString() ?? 'No sales target found';

        print('SALES TARGET API MESSAGE: $message');

        return null;
      }

      // -------------------------------------------------------
      // RESULT
      // -------------------------------------------------------

      final dynamic result = json['result'];

      if (result is! List) {
        print('SALES TARGET RESULT IS NOT LIST');

        return null;
      }

      if (result.isEmpty) {
        print('SALES TARGET RESULT IS EMPTY');

        return null;
      }

      // -------------------------------------------------------
      // FIRST RECORD
      // -------------------------------------------------------

      final dynamic first = result.first;

      if (first is! Map) {
        print('SALES TARGET FIRST RESULT IS NOT MAP');

        return null;
      }

      // -------------------------------------------------------
      // MODEL
      // -------------------------------------------------------

      final SalesTargetModel model = SalesTargetModel.fromJson(
        Map<String, dynamic>.from(first),
      );

      // -------------------------------------------------------
      // SUCCESS LOG
      // -------------------------------------------------------

      print('========================================');
      print('SALES TARGET SUCCESS');
      print('========================================');

      print('TOTAL TARGET: ${model.totalTarget}');

      print('TOTAL ACHIEVED: ${model.totalAchieved}');

      print('TOTAL PENDING: ${model.totalPending}');

      print('PERCENTAGE: ${model.percentage}');

      print('========================================');

      return model;
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print('========================================');
      print('SALES TARGET DIO ERROR');
      print('========================================');

      print('MESSAGE: ${e.message}');

      print('TYPE: ${e.type}');

      print('STATUS: ${e.response?.statusCode}');

      print('RESPONSE: ${e.response?.data}');

      print('========================================');

      throw NetworkException(e.message ?? 'Network error occurred');
    } catch (e) {
      print('========================================');
      print('SALES TARGET EXCEPTION');
      print('========================================');

      print('ERROR: $e');

      print('========================================');

      throw NetworkException(e.toString());
    }
  }

  Future<List<TargetGroupModel>> getGroupWiseAchivPoint({
    required String userId,
    required String targetId,
  }) async {
    try {
      // ========================================================
      // REQUEST DATA
      // ========================================================

      final Map<String, dynamic> requestData = {
        'userId': userId,
        'targetId': targetId,
      };

      debugPrint('========================================');
      debugPrint('GROUP WISE ACHIEVEMENT POINTS API');

      debugPrint(
        'URL = '
        '${ApiClient.baseUrl}'
        '${ApiClient.getGroupWiseAchievementPoint}',
      );

      debugPrint('USER ID = $userId');
      debugPrint('TARGET ID = $targetId');
      debugPrint('REQUEST = $requestData');
      debugPrint('========================================');

      // ========================================================
      // FORM DATA
      // ========================================================

      final FormData formData = FormData.fromMap(requestData);

      // ========================================================
      // POST API
      // ========================================================

      final Response response = await dioClient.client.post(
        ApiClient.getGroupWiseAchievementPoint,
        data: formData,
      );

      debugPrint('========================================');
      debugPrint('GROUP WISE ACHIEVEMENT POINTS RESPONSE');
      debugPrint('RESPONSE = ${response.data}');
      debugPrint('RESPONSE TYPE = ${response.data.runtimeType}');
      debugPrint('========================================');

      // ========================================================
      // CONVERT RESPONSE
      // ========================================================

      final Map<String, dynamic> data = _convertResponseToMap(response.data);

      // ========================================================
      // STATUS
      // ========================================================

      final bool status =
          data['status'] == true ||
          data['status']?.toString() == 'true' ||
          data['status']?.toString() == '1';

      final String message = data['message']?.toString() ?? '';

      debugPrint('STATUS = $status');
      debugPrint('MESSAGE = $message');

      // ========================================================
      // SUCCESS
      // ========================================================

      if (status) {
        final dynamic result = data['result'];

        debugPrint('RESULT = $result');
        debugPrint('RESULT TYPE = ${result.runtimeType}');

        if (result == null) {
          return [];
        }

        if (result is List) {
          final List<TargetGroupModel> groupList = result
              .map(
                (item) =>
                    TargetGroupModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();

          debugPrint('GROUP LIST COUNT = ${groupList.length}');

          return groupList;
        }

        throw Exception('Invalid group wise achievement response format');
      }

      // ========================================================
      // FAILURE
      // ========================================================

      throw Exception(
        message.isEmpty ? 'Unable to get group wise target' : message,
      );
    } on DioException catch (e) {
      debugPrint('========================================');
      debugPrint('DIO ERROR');
      debugPrint('STATUS CODE = ${e.response?.statusCode}');
      debugPrint('RESPONSE = ${e.response?.data}');
      debugPrint('MESSAGE = ${e.message}');
      debugPrint('========================================');

      throw Exception(_extractError(e.response?.data));
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('GET GROUP WISE ACHIEVEMENT POINT ERROR = $e');
      debugPrint('$stackTrace');
      debugPrint('========================================');

      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Map<String, dynamic> _convertResponseToMap(dynamic responseData) {
    if (responseData == null) {
      throw Exception('Empty API response');
    }

    // ==========================================================
    // STRING RESPONSE
    // ==========================================================

    if (responseData is String) {
      final String value = responseData.trim();

      if (value.isEmpty) {
        throw Exception('Empty API response');
      }

      try {
        final dynamic decoded = jsonDecode(value);

        if (decoded is! Map) {
          throw Exception('Invalid API response format');
        }

        return Map<String, dynamic>.from(decoded);
      } catch (e) {
        if (e is Exception) {
          rethrow;
        }

        throw Exception('Invalid API response');
      }
    }

    // ==========================================================
    // MAP RESPONSE
    // ==========================================================

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    throw Exception(
      'Invalid response type: '
      '${responseData.runtimeType}',
    );
  }

  String _extractError(dynamic data) {
    if (data == null) {
      return 'Something went wrong';
    }

    // ==========================================================
    // MAP
    // ==========================================================

    if (data is Map) {
      return data['message']?.toString() ?? 'Something went wrong';
    }

    // ==========================================================
    // STRING
    // ==========================================================

    if (data is String && data.trim().isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(data);

        if (decoded is Map) {
          return decoded['message']?.toString() ?? 'Something went wrong';
        }
      } catch (_) {
        return data;
      }
    }

    return 'Something went wrong';
  }

  bool _parseStatus(dynamic value) {
    if (value == true) {
      return true;
    }

    if (value is num) {
      return value == 1;
    }

    final String text = value?.toString().toLowerCase().trim() ?? '';

    return text == 'true' || text == '1' || text == 'success';
  }

  // =========================================================
  // DECODE RESPONSE
  // =========================================================

  dynamic _decodeResponse(dynamic data) {
    // -------------------------------------------------------
    // Already decoded
    // -------------------------------------------------------

    if (data is! String) {
      return data;
    }

    final String raw = data.trim();

    // -------------------------------------------------------
    // Empty
    // -------------------------------------------------------

    if (raw.isEmpty) {
      throw ServerException('Empty server response');
    }

    // -------------------------------------------------------
    // Normal JSON
    // -------------------------------------------------------

    try {
      return jsonDecode(raw);
    } catch (_) {
      // Continue
    }

    // -------------------------------------------------------
    // Find JSON object
    // -------------------------------------------------------

    final int jsonStart = raw.indexOf('{');

    if (jsonStart != -1) {
      try {
        return jsonDecode(raw.substring(jsonStart));
      } catch (_) {
        // Continue
      }
    }

    // -------------------------------------------------------
    // Find JSON array
    // -------------------------------------------------------

    final int arrayStart = raw.indexOf('[');

    if (arrayStart != -1) {
      try {
        return jsonDecode(raw.substring(arrayStart));
      } catch (_) {
        // Continue
      }
    }

    throw ServerException('Invalid server response');
  }
}
