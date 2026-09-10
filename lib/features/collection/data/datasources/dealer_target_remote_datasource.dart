import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/error/exceptions.dart';
import 'package:demo/features/collection/data/models/collection_target_model.dart';
import 'package:demo/features/collection/data/models/target_date_model.dart';

import 'package:dio/dio.dart';

abstract class DealerTargetRemoteDataSource {
  Future<List<TargetDateModel>> getTargetDates();

  Future<CollectionTargetModel?> getCollectionWiseTarget({
    required String userId,
    required String targetId,
  });
}

class DealerTargetRemoteDataSourceImpl
    implements DealerTargetRemoteDataSource {
  final DioClient dioClient;

  DealerTargetRemoteDataSourceImpl({
    required this.dioClient,
  });

  // =========================================================
  // GET TARGET DATES
  // =========================================================

  @override
  Future<List<TargetDateModel>> getTargetDates() async {
    try {
      print('========================================');
      print('GET TARGET DATES API');
      print('========================================');

      final response = await dioClient.client.post(
        ApiClient.getTargetDates,
        data: {},
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) =>
              status != null && status < 600,
        ),
      );

      print(
        'TARGET DATES API STATUS: ${response.statusCode}',
      );

      print(
        'TARGET DATES API RESPONSE: ${response.data}',
      );

      // -------------------------------------------------------
      // HTTP STATUS
      // -------------------------------------------------------

      if (response.statusCode != 200) {
        throw ServerException(
          'Server error: ${response.statusCode}',
        );
      }

      // -------------------------------------------------------
      // DECODE RESPONSE
      // -------------------------------------------------------

      final dynamic responseData =
          _decodeResponse(response.data);

      if (responseData is! Map) {
        throw ServerException(
          'Invalid target dates response',
        );
      }

      final json =
          Map<String, dynamic>.from(responseData);

      // -------------------------------------------------------
      // API STATUS
      // -------------------------------------------------------

      final bool status =
          json['status'] == true ||
          json['status']
                  ?.toString()
                  .toLowerCase() ==
              'true';

      print(
        'TARGET DATES PARSED STATUS: $status',
      );

      if (!status) {
        throw ServerException(
          json['message']?.toString() ??
              'No target dates found',
        );
      }

      // -------------------------------------------------------
      // RESULT
      // -------------------------------------------------------

      final result = json['result'];

      if (result is! List) {
        print(
          'TARGET DATES: RESULT IS NOT LIST',
        );

        return [];
      }

      final dates = result
          .whereType<Map>()
          .map(
            (item) => TargetDateModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      print(
        'TARGET DATES COUNT: ${dates.length}',
      );

      return dates;
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print(
        'TARGET DATES DIO ERROR: ${e.message}',
      );

      print(
        'TARGET DATES DIO RESPONSE: '
        '${e.response?.data}',
      );

      throw NetworkException(
        e.message ?? 'Network error occurred',
      );
    } catch (e) {
      print(
        'TARGET DATES EXCEPTION: $e',
      );

      throw NetworkException(
        e.toString(),
      );
    }
  }

  // =========================================================
  // GET COLLECTION WISE TARGET
  // =========================================================

  @override
  Future<CollectionTargetModel?>
      getCollectionWiseTarget({
    required String userId,
    required String targetId,
  }) async {
    try {
      print('');
      print('========================================');
      print('COLLECTION TARGET API');
      print('========================================');
      print('USER ID: $userId');
      print('TARGET ID: $targetId');
      print('========================================');

      // -------------------------------------------------------
      // REQUEST BODY
      //
      // IMPORTANT:
      // Convert both values to String because the backend
      // expects userId and targetId as request parameters.
      // -------------------------------------------------------

      final Map<String, dynamic> requestData = {
        'userId': userId.toString(),
        'targetId': targetId.toString(),
      };

      print(
        'COLLECTION TARGET REQUEST BODY: '
        '$requestData',
      );

  

      final response = await dioClient.client.post(
        ApiClient.getCollectionWiseTarget,

      
        data: FormData.fromMap({
        'userId': userId.toString(),
        'targetId': targetId.toString(),
      }),


        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.plain,
          validateStatus: (status) =>
              status != null && status < 600,
        ),
      );

      // -------------------------------------------------------
      // RESPONSE LOG
      // -------------------------------------------------------

      print('========================================');

      print(
        'COLLECTION TARGET STATUS: '
        '${response.statusCode}',
      );

      print(
        'COLLECTION TARGET RESPONSE: '
        '${response.data}',
      );

      print('========================================');

      // -------------------------------------------------------
      // HTTP STATUS
      // -------------------------------------------------------

      if (response.statusCode != 200) {
        throw ServerException(
          'Server error: ${response.statusCode}',
        );
      }

      // -------------------------------------------------------
      // DECODE RESPONSE
      // -------------------------------------------------------

      final dynamic responseData =
          _decodeResponse(response.data);

      if (responseData is! Map) {
        throw ServerException(
          'Invalid collection target response',
        );
      }

      final json =
          Map<String, dynamic>.from(responseData);

      // -------------------------------------------------------
      // API STATUS
      // -------------------------------------------------------

      final bool status =
          json['status'] == true ||
          json['status']
                  ?.toString()
                  .toLowerCase() ==
              'true';

      print(
        'COLLECTION TARGET PARSED STATUS: $status',
      );

      // -------------------------------------------------------
      // API FAILURE
      // -------------------------------------------------------

      if (!status) {
        final String message =
            json['message']?.toString() ??
                'No record found';

        print(
          'COLLECTION TARGET API MESSAGE: '
          '$message',
        );

        /*
         * Backend can return:
         *
         * {
         *   "status": false,
         *   "message": "userId And targetId Required",
         *   "result": [...]
         * }
         *
         * OR:
         *
         * {
         *   "status": false,
         *   "message": "No record found",
         *   "result": [...]
         * }
         *
         * For status=false we return null.
         */

        return null;
      }

      // -------------------------------------------------------
      // RESULT
      // -------------------------------------------------------

      final result = json['result'];

      if (result is! List) {
        print(
          'COLLECTION TARGET: RESULT IS NOT LIST',
        );

        return null;
      }

      if (result.isEmpty) {
        print(
          'COLLECTION TARGET: RESULT IS EMPTY',
        );

        return null;
      }

      // -------------------------------------------------------
      // FIRST RECORD
      // -------------------------------------------------------

      final first = result.first;

      if (first is! Map) {
        print(
          'COLLECTION TARGET: FIRST RESULT IS NOT MAP',
        );

        return null;
      }

      // -------------------------------------------------------
      // MODEL
      // -------------------------------------------------------

      final model =
          CollectionTargetModel.fromJson(
        Map<String, dynamic>.from(first),
      );

      print('');
      print('========================================');
      print('COLLECTION TARGET SUCCESS');
      print('========================================');
      print(
        'TOTAL TARGET: ${model.totalTarget}',
      );
      print(
        'TOTAL ACHIEVED: ${model.totalAchieved}',
      );
      print(
        'TOTAL PENDING: ${model.totalPending}',
      );
      print(
        'PERCENTAGE: ${model.percentage}',
      );
      print('========================================');

      return model;
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print('');
      print('========================================');
      print('COLLECTION TARGET DIO ERROR');
      print('========================================');
      print('MESSAGE: ${e.message}');
      print('TYPE: ${e.type}');
      print('STATUS: ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');
      print('========================================');

      throw NetworkException(
        e.message ?? 'Network error occurred',
      );
    } catch (e) {
      print('');
      print('========================================');
      print('COLLECTION TARGET EXCEPTION');
      print('========================================');
      print('ERROR: $e');
      print('========================================');

      throw NetworkException(
        e.toString(),
      );
    }
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
    // Empty response
    // -------------------------------------------------------

    if (raw.isEmpty) {
      throw ServerException(
        'Empty server response',
      );
    }

    // -------------------------------------------------------
    // Normal JSON
    // -------------------------------------------------------

    try {
      return jsonDecode(raw);
    } catch (_) {
      // -----------------------------------------------------
      // Sometimes API response contains extra text before
      // the JSON object.
      // -----------------------------------------------------

      final int jsonStart =
          raw.indexOf('{');

      if (jsonStart != -1) {
        try {
          return jsonDecode(
            raw.substring(jsonStart),
          );
        } catch (_) {
          // Continue below.
        }
      }

      // -----------------------------------------------------
      // Try JSON array
      // -----------------------------------------------------

      final int arrayStart =
          raw.indexOf('[');

      if (arrayStart != -1) {
        try {
          return jsonDecode(
            raw.substring(arrayStart),
          );
        } catch (_) {
          // Continue below.
        }
      }

      throw ServerException(
        'Invalid server response',
      );
    }
  }
}
