import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api_constant/api_client.dart';
import '../../../../core/api_constant/dio_client.dart';

import '../models/growth_dealer_search_model.dart';
import '../models/growth_report_model.dart';

abstract class GrowthReportRemoteDataSource {
  // ============================================================
  // GROWTH REPORT
  // ============================================================

  Future<GrowthReportModel> getGrowthReport({
    required String userId,
    required String years,
    required String dealerId,
    required int startLimit,
  });

  // ============================================================
  // DEALER SEARCH
  // ============================================================

  Future<List<GrowthDealerSearchModel>> searchDealers({
    required String userId,
    required String searchText,
    required int startLimit,
  });
}

// ============================================================
// IMPLEMENTATION
// ============================================================

class GrowthReportRemoteDataSourceImpl implements GrowthReportRemoteDataSource {
  final DioClient dioClient;

  GrowthReportRemoteDataSourceImpl({required this.dioClient});

  // ============================================================
  // GROWTH REPORT
  // ============================================================

  @override
  Future<GrowthReportModel> getGrowthReport({
    required String userId,
    required String years,
    required String dealerId,
    required int startLimit,
  }) async {
    try {
      final String cleanUserId = userId.trim();

      final String cleanYears = years.trim();

      final String cleanDealerId = dealerId.trim();

      final Map<String, dynamic> params = {
        'userId': cleanUserId,
        'years': cleanYears,
        'dealer_id': cleanDealerId,
        'startLimit': startLimit.toString(),
      };

      // ========================================================
      // REQUEST LOG
      // ========================================================

      debugPrint('');
      debugPrint(
        '============================================================',
      );

      debugPrint('GROWTH REPORT API REQUEST');

      debugPrint(
        'URL         : ${ApiClient.baseUrl}${ApiClient.getGrowthReport}',
      );

      debugPrint('userId      : "$cleanUserId"');

      debugPrint('years       : "$cleanYears"');

      debugPrint('dealer_id   : "$cleanDealerId"');

      debugPrint('startLimit  : "$startLimit"');

      debugPrint(
        '============================================================',
      );

      // ========================================================
      // API CALL
      // ========================================================

      final Response<dynamic> response = await dioClient.client.post(
        ApiClient.getGrowthReport,
        data: FormData.fromMap(params),
      );

      // ========================================================
      // RESPONSE LOG
      // ========================================================

      debugPrint('');
      debugPrint(
        '============================================================',
      );

      debugPrint('GROWTH REPORT API RESPONSE');

      debugPrint('STATUS CODE : ${response.statusCode}');

      debugPrint('RESPONSE    : ${response.data}');

      debugPrint(
        '============================================================',
      );

      // ========================================================
      // CONVERT RESPONSE
      // ========================================================

      final Map<String, dynamic> json = _toMap(response.data);

      // ========================================================
      // STATUS
      // ========================================================

      final bool success = _isSuccess(json['status']);

      if (!success) {
        throw Exception(_message(json, fallback: 'Growth report not found'));
      }

      // ========================================================
      // MODEL
      // ========================================================

      return GrowthReportModel.fromJson(json);
    } on DioException catch (e) {
      // ========================================================
      // DIO ERROR
      // ========================================================

      debugPrint('');
      debugPrint(
        '============================================================',
      );

      debugPrint('GROWTH REPORT DIO ERROR');

      debugPrint('TYPE        : ${e.type}');

      debugPrint('STATUS CODE : ${e.response?.statusCode}');

      debugPrint('URL         : ${e.requestOptions.uri}');

      debugPrint('RESPONSE    : ${e.response?.data}');

      debugPrint('MESSAGE     : ${e.message}');

      debugPrint(
        '============================================================',
      );

      throw Exception(
        _dioErrorMessage(e, fallback: 'Unable to load growth report'),
      );
    } catch (e) {
      debugPrint('GROWTH REPORT ERROR => $e');

      rethrow;
    }
  }

  // ============================================================
  // DEALER SEARCH
  // ============================================================

  @override
  Future<List<GrowthDealerSearchModel>> searchDealers({
    required String userId,
    required String searchText,
    required int startLimit,
  }) async {
    try {
      // ========================================================
      // CLEAN PARAMETERS
      // ========================================================

      final String cleanUserId = userId.trim();

      final String cleanSearchText = searchText.trim();

      // ========================================================
      // REQUEST PARAMETERS
      // ========================================================

      final Map<String, dynamic> params = {
        // IMPORTANT:
        //
        // getGrowthReport uses:
        //
        // userId
        //
        // getNearByOutlets uses:
        //
        // user_id

        'user_id': cleanUserId,
        'latitude': '',
        'longitude': '',
        'type': 'Dealer',

        'startLimit': startLimit.toString(),

        'searchText': cleanSearchText,

        // ======================================================
        // IF YOUR BACKEND REQUIRES THESE, UNCOMMENT:
        // ======================================================
        //
        // Your older Android implementation was sending:
        //
        // talukaId
        // latitude
        // longitude
        //
        // 'talukaId': '',
        // 'latitude': '',
        // 'longitude': '',
      };

      // ========================================================
      // REQUEST LOG
      // ========================================================

      debugPrint('');
      debugPrint(
        '============================================================',
      );

      debugPrint('DEALER SEARCH API REQUEST');

      debugPrint(
        'URL         : ${ApiClient.baseUrl}${ApiClient.getNearByOutlets}',
      );

      debugPrint('user_id     : "$cleanUserId"');

      debugPrint('startLimit  : "$startLimit"');

      debugPrint('searchText  : "$cleanSearchText"');

      debugPrint(
        '============================================================',
      );

      // ========================================================
      // API CALL
      // ========================================================

      final Response<dynamic> response = await dioClient.client.post(
        ApiClient.getNearByOutlets,
        data: params,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );

      // ========================================================
      // RESPONSE LOG
      // ========================================================

      debugPrint('');
      debugPrint(
        '============================================================',
      );

      debugPrint('DEALER SEARCH API RESPONSE');

      debugPrint('STATUS CODE : ${response.statusCode}');

      debugPrint('RESPONSE    : ${response.data}');

      debugPrint(
        '============================================================',
      );

      // ========================================================
      // CONVERT
      // ========================================================

      final Map<String, dynamic> json = _toMap(response.data);

      // ========================================================
      // STATUS
      // ========================================================

      final bool success = _isSuccess(json['status']);

      if (!success) {
        throw Exception(_message(json, fallback: 'Unable to search dealers'));
      }

      // ========================================================
      // RESULT
      // ========================================================

      final dynamic rawResult = json['result'];

      if (rawResult is! List) {
        throw const FormatException('Dealer API result is not a list');
      }

      // ========================================================
      // PARSE
      // ========================================================

      final List<GrowthDealerSearchModel> dealers = rawResult
          .whereType<Map>()
          .map(
            (item) => GrowthDealerSearchModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((dealer) => dealer.dealerId.trim().isNotEmpty)
          .toList();

      // ========================================================
      // RESULT LOG
      // ========================================================

      debugPrint('DEALER RESULT COUNT => ${dealers.length}');

      for (final dealer in dealers) {
        debugPrint(
          'DEALER => '
          '${dealer.dealerId} | '
          '${dealer.dealerName}',
        );
      }

      return dealers;
    } on DioException catch (e) {
      // ========================================================
      // DIO ERROR
      // ========================================================

      debugPrint('');
      debugPrint(
        '============================================================',
      );

      debugPrint('DEALER SEARCH DIO ERROR');

      debugPrint('TYPE        : ${e.type}');

      debugPrint('STATUS CODE : ${e.response?.statusCode}');

      debugPrint('URL         : ${e.requestOptions.uri}');

      debugPrint('RESPONSE    : ${e.response?.data}');

      debugPrint('MESSAGE     : ${e.message}');

      debugPrint(
        '============================================================',
      );

      throw Exception(
        _dioErrorMessage(e, fallback: 'Unable to search dealers'),
      );
    } catch (e) {
      debugPrint('DEALER SEARCH ERROR => $e');

      rethrow;
    }
  }

  // ============================================================
  // SUCCESS CHECK
  // ============================================================

  bool _isSuccess(dynamic value) {
    // true
    if (value == true) {
      return true;
    }

    // 1
    if (value == 1) {
      return true;
    }

    final String text = value?.toString().trim().toLowerCase() ?? '';

    return text == 'true' || text == '1' || text == 'success';
  }

  // ============================================================
  // GET MESSAGE
  // ============================================================

  String _message(Map<String, dynamic> json, {required String fallback}) {
    final String message = json['message']?.toString().trim() ?? '';

    return message.isEmpty ? fallback : message;
  }

  // ============================================================
  // DIO ERROR MESSAGE
  // ============================================================

  String _dioErrorMessage(DioException e, {required String fallback}) {
    final dynamic responseData = e.response?.data;

    // ==========================================================
    // SERVER JSON MESSAGE
    // ==========================================================

    if (responseData is Map) {
      final dynamic message = responseData['message'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }
    }

    // ==========================================================
    // CONNECTION TIMEOUT
    // ==========================================================

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please try again.';
    }

    // ==========================================================
    // RECEIVE TIMEOUT
    // ==========================================================

    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server response timeout. Please try again.';
    }

    // ==========================================================
    // SEND TIMEOUT
    // ==========================================================

    if (e.type == DioExceptionType.sendTimeout) {
      return 'Request timeout. Please try again.';
    }

    // ==========================================================
    // NO CONNECTION
    // ==========================================================

    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect to server. Check internet connection.';
    }

    // ==========================================================
    // DIO MESSAGE
    // ==========================================================

    final String dioMessage = e.message?.trim() ?? '';

    if (dioMessage.isNotEmpty) {
      return dioMessage;
    }

    return fallback;
  }

  // ============================================================
  // RESPONSE MAP
  // ============================================================

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is String) {
      data = jsonDecode(data.trim());
    }

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Invalid server response');
  }
}
