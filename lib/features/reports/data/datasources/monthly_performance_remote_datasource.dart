import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:solufine/features/reports/data/modles/application_phase_model.dart';
import 'package:solufine/features/reports/data/modles/area_performance_model.dart';
import 'package:solufine/features/reports/data/modles/expense_performance_model.dart';
import 'package:solufine/features/reports/data/modles/hourly_performance_model.dart';
import 'package:solufine/features/reports/data/modles/top_dealer_performance_model.dart';

import '../../../../core/api_constant/api_client.dart';
import '../../../../core/api_constant/dio_client.dart';

import '../modles/daily_performance_model.dart';
import '../modles/monthly_performance_model.dart';
import '../modles/report_financial_year_model.dart';

// ============================================================
// ABSTRACT DATASOURCE
// ============================================================

abstract class MonthlyPerformanceRemoteDataSource {
  // ==========================================================
  // FINANCIAL YEARS
  // ==========================================================

  Future<List<ReportFinancialYearModel>>
      getReportFinancialYears();

  // ==========================================================
  // MONTHLY PERFORMANCE
  // ==========================================================

  Future<MonthlyPerformanceModel>
      getMonthlyPerformance({
    required String employeeId,
    required String financialYear,
  });

  // ==========================================================
  // DAILY PERFORMANCE
  // ==========================================================

  Future<DailyPerformanceModel>
      getDailyPerformance({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  });


 Future<HourlyPerformanceModel>
      getHourlyPerformance({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  });

  Future<AreaPerformanceModel>
    getAreaPerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
});


Future<TopDealerPerformanceModel>
    getTopDealerPerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
});

Future<ExpensePerformanceModel>
    getExpensePerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
});

Future<ApplicationPhaseModel>
    getApplicationPhase();

}

// ============================================================
// IMPLEMENTATION
// ============================================================

class MonthlyPerformanceRemoteDataSourceImpl
    implements MonthlyPerformanceRemoteDataSource {
  final DioClient dioClient;

  MonthlyPerformanceRemoteDataSourceImpl({
    required this.dioClient,
  });

  // ============================================================
  // FINANCIAL YEARS
  // ============================================================

  @override
  Future<List<ReportFinancialYearModel>>
      getReportFinancialYears() async {
    try {
      debugPrint(
        '=========================================',
      );

      debugPrint(
        'GET REPORT FINANCIAL YEARS',
      );

      debugPrint(
        '=========================================',
      );

      final Response response =
          await dioClient.client.get(
        ApiClient.getReportFinancialYears,
      );

      debugPrint(
        'FY RESPONSE => ${response.data}',
      );

      final Map<String, dynamic> json =
          _convertToMap(
        response.data,
      );

      final bool success =
          _isSuccess(
        json['status'],
      );

      if (!success) {
        throw Exception(
          json['message']
                  ?.toString() ??
              'Unable to load financial years',
        );
      }

      final dynamic rawResult =
          json['result'];

      if (rawResult is! List) {
        return [];
      }

      final List<ReportFinancialYearModel>
          result =
          rawResult
              .whereType<Map>()
              .map(
                (
                  item,
                ) =>
                    ReportFinancialYearModel
                        .fromJson(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ),
              )
              .where(
                (
                  item,
                ) =>
                    item.id.isNotEmpty &&
                    item.fromDate.isNotEmpty &&
                    item.toDate.isNotEmpty &&
                    item.label.isNotEmpty,
              )
              .toList();

      debugPrint(
        'FY COUNT => ${result.length}',
      );

      return result;
    } on DioException catch (e) {
      debugPrint(
        'FY DIO ERROR => ${e.message}',
      );

      debugPrint(
        'FY ERROR STATUS => ${e.response?.statusCode}',
      );

      debugPrint(
        'FY ERROR RESPONSE => ${e.response?.data}',
      );

      throw Exception(
        _extractDioMessage(
          e,
          defaultMessage:
              'Unable to load financial years',
        ),
      );
    } catch (e) {
      debugPrint(
        'FY ERROR => $e',
      );

      throw Exception(
        _cleanException(
          e,
        ),
      );
    }
  }

  // ============================================================
  // MONTHLY PERFORMANCE
  //
  // API:
  // getReportStatMonthlyDetails
  //
  // PARAMS:
  // empId
  // year
  // ============================================================

  @override
  Future<MonthlyPerformanceModel>
      getMonthlyPerformance({
    required String employeeId,
    required String financialYear,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'empId':
            employeeId,

        'year':
            financialYear,
      };

      debugPrint(
        '=========================================',
      );

      debugPrint(
        'MONTHLY PERFORMANCE API',
      );

      debugPrint(
        'empId => $employeeId',
      );

      debugPrint(
        'year => $financialYear',
      );

      debugPrint(
        '=========================================',
      );

      final Response response =
          await dioClient.client.post(
        ApiClient.getMonthlyPerformance,

        data:
            FormData.fromMap(
          data,
        ),
      );

      debugPrint(
        'MONTHLY STATUS CODE => ${response.statusCode}',
      );

      debugPrint(
        'MONTHLY RESPONSE => ${response.data}',
      );

      final Map<String, dynamic> json =
          _convertToMap(
        response.data,
      );

      final bool success =
          _isSuccess(
        json['status'],
      );

      if (!success) {
        throw Exception(
          json['message']
                  ?.toString() ??
              'Unable to load monthly report',
        );
      }

      return MonthlyPerformanceModel
          .fromJson(
        json,
      );
    } on DioException catch (e) {
      debugPrint(
        'MONTHLY DIO ERROR => ${e.message}',
      );

      debugPrint(
        'MONTHLY ERROR STATUS => ${e.response?.statusCode}',
      );

      debugPrint(
        'MONTHLY ERROR RESPONSE => ${e.response?.data}',
      );

      throw Exception(
        _extractDioMessage(
          e,
          defaultMessage:
              'Unable to load monthly report',
        ),
      );
    } catch (e) {
      debugPrint(
        'MONTHLY ERROR => $e',
      );

      throw Exception(
        _cleanException(
          e,
        ),
      );
    }
  }

  // ============================================================
  // DAILY PERFORMANCE
  //
  // API:
  // getStatDailyDetails
  //
  // PARAMS:
  // empId
  // year
  // selected_months
  //
  // EXAMPLE:
  // empId = 4
  // year = 2026
  // selected_months = 2026-08,2026-09,2026-10
  // ============================================================

  @override
  Future<DailyPerformanceModel>
      getDailyPerformance({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'empId':
            employeeId,

        'year':
            financialYear,

        'selected_months':
            selectedMonths,
      };

      debugPrint(
        '=========================================',
      );

      debugPrint(
        'DAILY PERFORMANCE API',
      );

      debugPrint(
        'empId => $employeeId',
      );

      debugPrint(
        'year => $financialYear',
      );

      debugPrint(
        'selected_months => $selectedMonths',
      );

      debugPrint(
        '=========================================',
      );

      final Response response =
          await dioClient.client.post(
        ApiClient.getDailyPerformance,

        data:
            FormData.fromMap(
          data,
        ),
      );

      debugPrint(
        'DAILY STATUS CODE => ${response.statusCode}',
      );

      debugPrint(
        'DAILY RESPONSE => ${response.data}',
      );

      final Map<String, dynamic> json =
          _convertToMap(
        response.data,
      );

      final bool success =
          _isSuccess(
        json['status'],
      );

      if (!success) {
        throw Exception(
          json['message']
                  ?.toString() ??
              'Unable to load daily report',
        );
      }

      return DailyPerformanceModel
          .fromJson(
        json,
      );
    } on DioException catch (e) {
      debugPrint(
        'DAILY DIO ERROR => ${e.message}',
      );

      debugPrint(
        'DAILY ERROR STATUS => ${e.response?.statusCode}',
      );

      debugPrint(
        'DAILY ERROR RESPONSE => ${e.response?.data}',
      );

      throw Exception(
        _extractDioMessage(
          e,
          defaultMessage:
              'Unable to load daily report',
        ),
      );
    } catch (e) {
      debugPrint(
        'DAILY ERROR => $e',
      );

      throw Exception(
        _cleanException(
          e,
        ),
      );
    }
  }

  // ============================================================
// HOURLY PERFORMANCE
// ============================================================

@override
Future<HourlyPerformanceModel>
    getHourlyPerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
}) async {
  try {
    final Map<String, dynamic> data = {
      'empId':
          employeeId,

      'year':
          financialYear,

      'selected_months':
          selectedMonths,
    };

    debugPrint(
      '=========================================',
    );

    debugPrint(
      'HOURLY PERFORMANCE API',
    );

    debugPrint(
      'empId => $employeeId',
    );

    debugPrint(
      'year => $financialYear',
    );

    debugPrint(
      'selected_months => $selectedMonths',
    );

    debugPrint(
      '=========================================',
    );

    final Response response =
        await dioClient.client.post(
      ApiClient.getHourlyPerformance,

      data:
          FormData.fromMap(
        data,
      ),
    );

    debugPrint(
      'HOURLY RESPONSE => ${response.data}',
    );

    final Map<String, dynamic> json =
        _convertToMap(
      response.data,
    );

    final bool success =
        json['status'] == true ||
            json['status']
                    ?.toString()
                    .toLowerCase() ==
                'true';

    if (!success) {
      throw Exception(
        json['message']
                ?.toString() ??
            'Unable to load hourly report',
      );
    }

    return HourlyPerformanceModel
        .fromJson(
      json,
    );
  } on DioException catch (e) {
    debugPrint(
      'HOURLY DIO ERROR => ${e.response?.data}',
    );

    throw Exception(
      'Unable to load hourly report',
    );
  } catch (e) {
    debugPrint(
      'HOURLY ERROR => $e',
    );

    rethrow;
  }
}


@override
Future<AreaPerformanceModel>
    getAreaPerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
}) async {
  try {
    final Map<String, dynamic> data = {
      'empId': employeeId,
      'year': financialYear,
      'selected_months': selectedMonths,
    };

    debugPrint(
      '=========================================',
    );
    debugPrint(
      'AREA PERFORMANCE API',
    );
    debugPrint(
      'empId => $employeeId',
    );
    debugPrint(
      'year => $financialYear',
    );
    debugPrint(
      'selected_months => $selectedMonths',
    );
    debugPrint(
      '=========================================',
    );

    final Response response =
        await dioClient.client.post(
      ApiClient.getAreaPerformance,
      data: FormData.fromMap(data),
    );

    debugPrint(
      'AREA RESPONSE => ${response.data}',
    );

    final Map<String, dynamic> json =
        _convertToMap(response.data);

    final bool status =
        json['status'] == true ||
            json['status']
                    ?.toString()
                    .toLowerCase() ==
                'true';

    if (!status) {
      throw Exception(
        json['message']?.toString() ??
            'Unable to load area report',
      );
    }

    return AreaPerformanceModel.fromJson(
      json,
    );
  } on DioException catch (e) {
    debugPrint(
      'AREA API ERROR => ${e.response?.data}',
    );

    throw Exception(
      'Unable to load area report',
    );
  } catch (e) {
    debugPrint(
      'AREA ERROR => $e',
    );

    rethrow;
  }
}


@override
Future<TopDealerPerformanceModel>
    getTopDealerPerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
}) async {
  try {
    final Map<String, dynamic> data = {
      'empId': employeeId,
      'year': financialYear,
      'selected_months': selectedMonths,
    };

    debugPrint(
      '=========================================',
    );
    debugPrint('TOP DEALERS API');
    debugPrint('empId => $employeeId');
    debugPrint('year => $financialYear');
    debugPrint('selected_months => $selectedMonths');
    debugPrint(
      '=========================================',
    );

    final Response response =
        await dioClient.client.post(
      ApiClient.getTopDealers,
      data: FormData.fromMap(data),
    );

    debugPrint(
      'TOP DEALERS RESPONSE => ${response.data}',
    );

    final Map<String, dynamic> json =
        _convertToMap(response.data);

    final bool success =
        json['status'] == true ||
            json['status']
                    ?.toString()
                    .toLowerCase() ==
                'true';

    if (!success) {
      throw Exception(
        json['message']?.toString() ??
            'Unable to load top dealers report',
      );
    }

    return TopDealerPerformanceModel.fromJson(json);
  } on DioException catch (e) {
    debugPrint(
      'TOP DEALERS API ERROR => ${e.response?.data}',
    );
    throw Exception(
      'Unable to load top dealers report',
    );
  } catch (e) {
    debugPrint('TOP DEALERS ERROR => $e');
    rethrow;
  }
}


@override
Future<ExpensePerformanceModel>
    getExpensePerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
}) async {
  try {
    final Map<String, dynamic> data = {
      'empId': employeeId,
      'year': financialYear,
      'selected_months':
          selectedMonths,
    };

    debugPrint(
      'EXPENSE REQUEST => $data',
    );

    final Response response =
        await dioClient.client.post(
      ApiClient.getExpensePerformance,
      data:
          FormData.fromMap(
        data,
      ),
    );

    debugPrint(
      'EXPENSE RESPONSE => ${response.data}',
    );

    final Map<String, dynamic> json =
        _convertToMap(
      response.data,
    );

    final bool status =
        json['status'] == true ||
            json['status']
                    ?.toString()
                    .toLowerCase() ==
                'true';

    if (!status) {
      throw Exception(
        json['message']
                ?.toString() ??
            'Unable to load expense report',
      );
    }

    return ExpensePerformanceModel
        .fromJson(
      json,
    );
  } on DioException catch (e) {
    debugPrint(
      'EXPENSE API ERROR => ${e.response?.data}',
    );

    throw Exception(
      'Unable to load expense report',
    );
  } catch (e) {
    debugPrint(
      'EXPENSE ERROR => $e',
    );

    rethrow;
  }
}


@override
Future<ApplicationPhaseModel>
    getApplicationPhase() async {
  try {
    final Response<dynamic> response =
        await dioClient.client.get(
      ApiClient.getApplicationPhase,
    );

    dynamic data =
        response.data;

    if (data is String) {
      data =
          jsonDecode(data);
    }

    if (data is! Map) {
      throw Exception(
        'Invalid application phase response',
      );
    }

    final Map<String, dynamic> json =
        Map<String, dynamic>.from(
      data,
    );

    final bool status =
        json['status'] == true ||
            json['status']
                    ?.toString()
                    .toLowerCase() ==
                'true';

    if (!status) {
      throw Exception(
        json['message']?.toString() ??
            'Unable to get application phase',
      );
    }

    return ApplicationPhaseModel.fromJson(
      json,
    );
  } on DioException catch (e) {
    throw Exception(
      e.response?.data is Map
          ? e.response?.data['message']
                  ?.toString() ??
              'Unable to get application phase'
          : 'Unable to get application phase',
    );
  }
}




  // ============================================================
  // SUCCESS CHECK
  // ============================================================

  bool _isSuccess(
    dynamic value,
  ) {
    if (value == true) {
      return true;
    }

    final String text =
        value
            ?.toString()
            .trim()
            .toLowerCase() ??
        '';

    return text == 'true' ||
        text == '1';
  }

  // ============================================================
  // RESPONSE CONVERTER
  //
  // Supports:
  //
  // Map
  // String JSON
  // ============================================================

  Map<String, dynamic> _convertToMap(
    dynamic data,
  ) {
    // ==========================================================
    // ALREADY MAP
    // ==========================================================

    if (data is Map) {
      return Map<String, dynamic>.from(
        data,
      );
    }

    // ==========================================================
    // STRING JSON
    // ==========================================================

    if (data is String) {
      final String text =
          data.trim();

      if (text.isEmpty) {
        throw Exception(
          'Empty API response',
        );
      }

      final dynamic decoded =
          jsonDecode(
        text,
      );

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }
    }

    throw Exception(
      'Invalid API response type: '
      '${data.runtimeType}',
    );
  }

  // ============================================================
  // DIO ERROR MESSAGE
  // ============================================================

  String _extractDioMessage(
    DioException e, {
    required String defaultMessage,
  }) {
    final dynamic responseData =
        e.response?.data;

    try {
      if (responseData is Map) {
        final Map<String, dynamic> json =
            Map<String, dynamic>.from(
          responseData,
        );

        final String? message =
            json['message']
                ?.toString()
                .trim();

        if (message != null &&
            message.isNotEmpty) {
          return message;
        }
      }

      if (responseData is String &&
          responseData.trim().isNotEmpty) {
        final dynamic decoded =
            jsonDecode(
          responseData,
        );

        if (decoded is Map) {
          final String? message =
              decoded['message']
                  ?.toString()
                  .trim();

          if (message != null &&
              message.isNotEmpty) {
            return message;
          }
        }
      }
    } catch (_) {
      // Ignore parsing error.
    }

    if (e.type ==
        DioExceptionType.connectionTimeout) {
      return 'Connection timeout';
    }

    if (e.type ==
        DioExceptionType.receiveTimeout) {
      return 'Server response timeout';
    }

    if (e.type ==
        DioExceptionType.connectionError) {
      return 'Unable to connect to server';
    }

    return defaultMessage;
  }

  // ============================================================
  // CLEAN EXCEPTION
  // ============================================================

  String _cleanException(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }
}