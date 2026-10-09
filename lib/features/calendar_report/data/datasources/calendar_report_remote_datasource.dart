import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/api_constant/api_client.dart';
import '../../../../core/api_constant/dio_client.dart';

import '../models/calendar_day_model.dart';

// ============================================================
// ABSTRACT
// ============================================================

abstract class CalendarReportRemoteDataSource {
  Future<List<CalendarDayModel>>
      getCalendarReport({
    required String userId,
    required String month,
  });
}

// ============================================================
// IMPLEMENTATION
// ============================================================

class CalendarReportRemoteDataSourceImpl
    implements CalendarReportRemoteDataSource {
  final DioClient dioClient;

  CalendarReportRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<List<CalendarDayModel>>
      getCalendarReport({
    required String userId,
    required String month,
  }) async {
    try {
      final Response<dynamic> response =
          await dioClient.client.post(
        ApiClient.getFollowupCalendar,

        data: FormData.fromMap({
          'user_id': userId,
          'month': month,
        }),
      );

      dynamic responseData =
          response.data;

      // ========================================================
      // STRING RESPONSE
      //
      // Your PHP API currently prints an HTML warning BEFORE JSON.
      // So plain jsonDecode(responseData) can fail.
      // ========================================================

      if (responseData is String) {
        responseData =
            _decodeResponseString(
          responseData,
        );
      }

      // ========================================================
      // VALID RESPONSE
      // ========================================================

      if (responseData is! Map) {
        throw Exception(
          'Invalid calendar response',
        );
      }

      final Map<String, dynamic> json =
          Map<String, dynamic>.from(
        responseData,
      );

      final bool success =
          json['status'] == true ||
              json['status']
                      ?.toString()
                      .toLowerCase() ==
                  'true';

      // ========================================================
      // FAILURE / EMPTY
      // ========================================================

      if (!success) {
        final String message =
            json['message']
                    ?.toString() ??
                'Unable to load calendar';

        final String normalized =
            message
                .trim()
                .toLowerCase();

        if (normalized.contains(
              'no record',
            ) ||
            normalized.contains(
              'no data',
            ) ||
            normalized.contains(
              'record not found',
            )) {
          return [];
        }

        throw Exception(
          message,
        );
      }

      // ========================================================
      // RESULT
      // ========================================================

      final dynamic rawResult =
          json['result'];

      if (rawResult is! List) {
        return [];
      }

      return rawResult
          .whereType<Map>()
          .map(
            (e) =>
                CalendarDayModel.fromJson(
              Map<String, dynamic>.from(
                e,
              ),
            ),
          )
          .toList();
    } on DioException catch (e) {
      String message =
          'Unable to load calendar';

      final dynamic errorData =
          e.response?.data;

      if (errorData is Map) {
        message =
            errorData['message']
                    ?.toString() ??
                message;
      }

      throw Exception(
        message,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // PHP WARNING + JSON HANDLER
  // ============================================================

  dynamic _decodeResponseString(
    String value,
  ) {
    final String trimmed =
        value.trim();

    // Normal valid JSON response
    try {
      return jsonDecode(
        trimmed,
      );
    } catch (_) {}

    // ==========================================================
    // Your API currently returns:
    //
    // <div> PHP warning ... </div>
    // {"status":true,"result":[...]}
    //
    // Extract JSON only.
    // ==========================================================

    final int firstBrace =
        trimmed.indexOf(
      '{',
    );

    final int lastBrace =
        trimmed.lastIndexOf(
      '}',
    );

    if (firstBrace >= 0 &&
        lastBrace > firstBrace) {
      final String jsonPart =
          trimmed.substring(
        firstBrace,
        lastBrace + 1,
      );

      try {
        return jsonDecode(
          jsonPart,
        );
      } catch (_) {}
    }

    throw Exception(
      'Invalid calendar response from server',
    );
  }
}