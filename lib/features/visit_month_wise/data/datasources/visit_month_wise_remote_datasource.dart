import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:solufine/features/visit_month_wise/data/models/visit_day_wise_model.dart';
import 'package:solufine/features/visit_month_wise/data/models/visit_frequency_model.dart';
import 'package:solufine/features/visit_month_wise/data/models/visit_geo_wise_model.dart';
import 'package:solufine/features/visit_month_wise/data/models/visit_hour_wise_model.dart';
import 'package:solufine/features/visit_month_wise/data/models/visit_top_employee_model.dart';
import 'package:solufine/features/visit_month_wise/data/models/visit_top_list_model.dart';

import '../../../../core/api_constant/api_client.dart';
import '../../../../core/api_constant/dio_client.dart';

import '../models/visit_month_wise_model.dart';
import '../models/visit_report_employee_model.dart';

// ============================================================
// ABSTRACT
// ============================================================

abstract class VisitMonthWiseRemoteDataSource {
  Future<VisitMonthWiseReportModel> getVisitMonthWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  });

  Future<List<VisitReportEmployeeModel>> getAssignedEmployees({
    required String userId,
    required String searchText,
  });

  Future<VisitDayWiseReportModel> getVisitDayWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  });

  Future<VisitHourWiseReportModel> getVisitHourWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  });

Future<VisitFrequencyReportModel>
    getVisitFrequency({
  required String fromDate,
  required String toDate,
  required String employeeId,
});


Future<VisitGeoWiseReportModel> getVisitGeoWise({
  required String fromDate,
  required String toDate,
  required String employeeId,
});

Future<VisitTopListReportModel>
    getVisitTopList({
  required String fromDate,
  required String toDate,
  required String employeeId,
});

Future<VisitTopEmployeeReportModel>
    getVisitTopEmployee({
  required String fromDate,
  required String toDate,
  required String employeeId,
});

}

// ============================================================
// IMPLEMENTATION
// ============================================================

class VisitMonthWiseRemoteDataSourceImpl
    implements VisitMonthWiseRemoteDataSource {
  final DioClient dioClient;

  VisitMonthWiseRemoteDataSourceImpl({required this.dioClient});

  // ============================================================
  // MONTH WISE VISIT
  // ============================================================

  @override
  Future<VisitMonthWiseReportModel> getVisitMonthWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) async {
    try {
      final Response<dynamic> response = await dioClient.client.post(
        ApiClient.getVisitMonthWise,

        data: FormData.fromMap({
          'from_date': fromDate,

          'to_date': toDate,

          'emp_id': employeeId,
        }),
      );

      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      if (responseData is! Map) {
        throw Exception('Invalid month wise visit response');
      }

      final Map<String, dynamic> json = Map<String, dynamic>.from(responseData);

      final bool status =
          json['status'] == true ||
          json['status']?.toString().toLowerCase() == 'true';

      if (!status) {
        if (_isNoVisitRecords(json)) {
          return VisitMonthWiseReportModel.fromJson({
            'from_date': fromDate,
            'to_date': toDate,
            'result': <dynamic>[],
            'total': <String, dynamic>{},
          });
        }

        throw Exception(
          json['message']?.toString() ?? 'Unable to load month wise visits',
        );
      }

      return VisitMonthWiseReportModel.fromJson(json);
    } on DioException catch (e) {
      throw Exception(
        _dioError(e, fallback: 'Unable to load month wise visits'),
      );
    }
  }

  // ============================================================
  // ASSIGNED EMPLOYEES
  // ============================================================

  @override
  Future<List<VisitReportEmployeeModel>> getAssignedEmployees({
    required String userId,
    required String searchText,
  }) async {
    try {
      final Response<dynamic> response = await dioClient.client.post(
        ApiClient.getEmployees,

        data: FormData.fromMap({'user_id': userId, 'searchtext': searchText}),
      );

      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      if (responseData is! Map) {
        throw Exception('Invalid employee response');
      }

      final Map<String, dynamic> json = Map<String, dynamic>.from(responseData);

      final bool status =
          json['status'] == true ||
          json['status']?.toString().toLowerCase() == 'true';

      if (!status) {
        throw Exception(
          json['messsage']?.toString() ??
              json['message']?.toString() ??
              'Unable to load employees',
        );
      }

      final dynamic rawResult = json['result'];

      if (rawResult is! List) {
        return [];
      }

      return rawResult
          .whereType<Map>()
          .map(
            (e) =>
                VisitReportEmployeeModel.fromJson(Map<String, dynamic>.from(e)),
          )
          // Remove:
          // fld_id = 0
          // Select Employee
          .where(
            (employee) =>
                employee.id.trim().isNotEmpty &&
                employee.id != '0' &&
                employee.name.trim().isNotEmpty,
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_dioError(e, fallback: 'Unable to load employees'));
    }
  }

  // ============================================================
  // DAY WISE VISIT
  // ============================================================

  @override
  Future<VisitDayWiseReportModel> getVisitDayWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) async {
    try {
      final Response<dynamic> response = await dioClient.client.post(
        ApiClient.getVisitDayWise,

        data: FormData.fromMap({
          'from_date': fromDate,

          'to_date': toDate,

          'emp_id': employeeId,
        }),
      );

      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      if (responseData is! Map) {
        throw Exception('Invalid day wise visit response');
      }

      final Map<String, dynamic> json = Map<String, dynamic>.from(responseData);

      final bool status =
          json['status'] == true ||
          json['status']?.toString().toLowerCase() == 'true';

      if (!status) {
        if (_isNoVisitRecords(json)) {
          return VisitDayWiseReportModel.fromJson({
            'from_date': fromDate,
            'to_date': toDate,
            'result': <dynamic>[],
            'total': <String, dynamic>{},
          });
        }

        throw Exception(
          json['message']?.toString() ?? 'Unable to load day wise visits',
        );
      }

      return VisitDayWiseReportModel.fromJson(json);
    } on DioException catch (e) {
      throw Exception(_dioError(e, fallback: 'Unable to load day wise visits'));
    }
  }

  // ============================================================
  // Hours WISE VISIT
  // ============================================================
  @override
  Future<VisitHourWiseReportModel> getVisitHourWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) async {
    try {
      final Response<dynamic> response = await dioClient.client.post(
        ApiClient.getVisitHourWise,
        data: FormData.fromMap({
          'from_date': fromDate,
          'to_date': toDate,
          'emp_id': employeeId,
        }),
      );

      // ============================================================
      // RESPONSE PARSE
      // ============================================================

      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      if (responseData is! Map) {
        throw Exception('Invalid hour wise visit response');
      }

      final Map<String, dynamic> json = Map<String, dynamic>.from(responseData);

      // ============================================================
      // STATUS CHECK
      // ============================================================

      final bool success =
          json['status'] == true ||
          json['status']?.toString().toLowerCase() == 'true';

      if (!success) {
        if (_isNoVisitRecords(json)) {
          return VisitHourWiseReportModel.fromJson({
            'from_date': fromDate,
            'to_date': toDate,
            'result': <dynamic>[],
            'total': <String, dynamic>{},
          });
        }

        throw Exception(
          json['message']?.toString() ?? 'Unable to load hour wise report',
        );
      }

      // ============================================================
      // MODEL
      // ============================================================

      return VisitHourWiseReportModel.fromJson(json);
    } on DioException catch (e) {
      String message = 'Unable to load hour wise report';

      final dynamic errorData = e.response?.data;

      if (errorData is Map) {
        message = errorData['message']?.toString() ?? message;
      }

      throw Exception(message);
    } catch (e) {
      rethrow;
    }
  }


  // ============================================================
// VISIT FREQUENCY
// ============================================================

@override
Future<VisitFrequencyReportModel>
    getVisitFrequency({
  required String fromDate,
  required String toDate,
  required String employeeId,
}) async {
  try {
    final Response<dynamic> response =
        await dioClient.client.post(
      ApiClient.getVisitFrequency,

      data:
          FormData.fromMap(
        {
          'from_date':
              fromDate,

          'to_date':
              toDate,

          'emp_id':
              employeeId,
        },
      ),
    );

    // =========================================================
    // RESPONSE PARSE
    // =========================================================

    dynamic responseData =
        response.data;

    if (responseData is String) {
      responseData =
          jsonDecode(
        responseData,
      );
    }

    if (responseData is! Map) {
      throw Exception(
        'Invalid visit frequency response',
      );
    }

    final Map<String, dynamic>
        json =
        Map<String, dynamic>.from(
      responseData,
    );

    // =========================================================
    // STATUS
    // =========================================================

    final bool status =
        json['status'] == true ||
            json['status']
                    ?.toString()
                    .toLowerCase() ==
                'true';

    // =========================================================
    // NO DATA SHOULD NOT BE ERROR
    // =========================================================

    if (!status) {
      final String message =
          json['message']
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              '';

      if (message.contains(
            'no record',
          ) ||
          message.contains(
            'no data',
          ) ||
          message.contains(
            'record not found',
          )) {
        return VisitFrequencyReportModel
            .fromJson(
          json,
        );
      }

      throw Exception(
        json['message']
                ?.toString() ??
            'Unable to load visit frequency',
      );
    }

    return VisitFrequencyReportModel
        .fromJson(
      json,
    );
  } on DioException catch (e) {
    String message =
        'Unable to load visit frequency';

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
// State / District/ Taluka
// ============================================================

@override
Future<VisitGeoWiseReportModel> getVisitGeoWise({
  required String fromDate,
  required String toDate,
  required String employeeId,
}) async {
  try {
    final Response<dynamic> response =
        await dioClient.client.post(
      ApiClient.getVisitGeoWise,
      data: FormData.fromMap({
        'from_date': fromDate,
        'to_date': toDate,
        'emp_id': employeeId,
      }),
    );

    // ============================================================
    // RESPONSE PARSE
    // ============================================================

    dynamic responseData = response.data;

    // Sometimes Dio may return response as String
    if (responseData is String) {
      responseData = jsonDecode(
        responseData,
      );
    }

    // Response must be a Map
    if (responseData is! Map) {
      throw Exception(
        'Invalid geo wise visit response',
      );
    }

    final Map<String, dynamic> json =
        Map<String, dynamic>.from(
      responseData,
    );

    // ============================================================
    // STATUS
    // ============================================================

    final bool success =
        json['status'] == true ||
            json['status']
                    ?.toString()
                    .toLowerCase() ==
                'true';

    // ============================================================
    // STATUS FALSE
    // ============================================================

    if (!success) {
      final String message =
          json['message']
                  ?.toString() ??
              'Unable to load geo wise report';

      // ----------------------------------------------------------
      // If API returns "NO RECORD FOUND",
      // return empty model instead of failure.
      // ----------------------------------------------------------

      final String normalizedMessage =
          message
              .trim()
              .toLowerCase();

      if (normalizedMessage.contains(
            'no record',
          ) ||
          normalizedMessage.contains(
            'no data',
          ) ||
          normalizedMessage.contains(
            'record not found',
          )) {
        return VisitGeoWiseReportModel
            .fromJson(
          json,
        );
      }

      throw Exception(
        message,
      );
    }

    // ============================================================
    // SUCCESS MODEL
    // ============================================================

    return VisitGeoWiseReportModel
        .fromJson(
      json,
    );
  } on DioException catch (e) {
    // ============================================================
    // DIO ERROR MESSAGE
    // ============================================================

    String message =
        'Unable to load geo wise report';

    final dynamic errorData =
        e.response?.data;

    // Response error is already Map
    if (errorData is Map) {
      message =
          errorData['message']
                  ?.toString() ??
              message;
    }

    // Response error may be String JSON
    else if (errorData is String) {
      try {
        final dynamic decoded =
            jsonDecode(
          errorData,
        );

        if (decoded is Map) {
          message =
              decoded['message']
                      ?.toString() ??
                  message;
        }
      } catch (_) {
        // Keep fallback message
      }
    }

    throw Exception(
      message,
    );
  } catch (e) {
    rethrow;
  }
}

// ============================================================
// TOP DEALER / FARMER LIST
// ============================================================

@override
Future<VisitTopListReportModel>
    getVisitTopList({
  required String fromDate,
  required String toDate,
  required String employeeId,
}) async {
  try {
    final Response<dynamic> response =
        await dioClient.client.post(
      ApiClient.getVisitTopList,

      data:
          FormData.fromMap(
        {
          'from_date':
              fromDate,

          'to_date':
              toDate,

          'emp_id':
              employeeId,
        },
      ),
    );

    // ==========================================================
    // RESPONSE
    // ==========================================================

    dynamic responseData =
        response.data;

    if (responseData is String) {
      responseData =
          jsonDecode(
        responseData,
      );
    }

    if (responseData is! Map) {
      throw Exception(
        'Invalid visit top list response',
      );
    }

    final Map<String, dynamic>
        json =
        Map<String, dynamic>.from(
      responseData,
    );

    // ==========================================================
    // STATUS
    // ==========================================================

    final bool success =
        json['status'] == true ||
            json['status']
                    ?.toString()
                    .toLowerCase() ==
                'true';

    if (!success) {
      final String message =
          json['message']
                  ?.toString() ??
              'Unable to load top visit list';

      final String lowerMessage =
          message
              .trim()
              .toLowerCase();

      // NO RECORD = VALID EMPTY RESPONSE
      if (lowerMessage.contains(
            'no record',
          ) ||
          lowerMessage.contains(
            'no data',
          ) ||
          lowerMessage.contains(
            'record not found',
          )) {
        return VisitTopListReportModel
            .fromJson(
          json,
        );
      }

      throw Exception(
        message,
      );
    }

    return VisitTopListReportModel
        .fromJson(
      json,
    );
  } on DioException catch (e) {
    String message =
        'Unable to load top visit list';

    final dynamic errorData =
        e.response?.data;

    if (errorData is Map) {
      message =
          errorData['message']
                  ?.toString() ??
              message;
    } else if (errorData
        is String) {
      try {
        final dynamic decoded =
            jsonDecode(
          errorData,
        );

        if (decoded is Map) {
          message =
              decoded['message']
                      ?.toString() ??
                  message;
        }
      } catch (_) {}
    }

    throw Exception(
      message,
    );
  } catch (e) {
    rethrow;
  }
}


// ============================================================
// TOP EMPLOYEE
// ============================================================

@override
Future<VisitTopEmployeeReportModel>
    getVisitTopEmployee({
  required String fromDate,
  required String toDate,
  required String employeeId,
}) async {
  try {
    final Response<dynamic> response =
        await dioClient.client.post(
      ApiClient.getVisitTopEmployee,

      data: FormData.fromMap({
        'from_date': fromDate,
        'to_date': toDate,
        'emp_id': employeeId,
      }),
    );

    dynamic responseData =
        response.data;

    // ==========================================================
    // STRING RESPONSE
    // ==========================================================

    if (responseData is String) {
      responseData =
          jsonDecode(
        responseData,
      );
    }

    // ==========================================================
    // VALIDATE RESPONSE
    // ==========================================================

    if (responseData is! Map) {
      throw Exception(
        'Invalid top employee response',
      );
    }

    final Map<String, dynamic> json =
        Map<String, dynamic>.from(
      responseData,
    );

    // ==========================================================
    // STATUS
    // ==========================================================

    final bool success =
        json['status'] == true ||
            json['status']
                    ?.toString()
                    .toLowerCase() ==
                'true';

    if (!success) {
      final String message =
          json['message']
                  ?.toString() ??
              'Unable to load top employee report';

      final String normalized =
          message
              .trim()
              .toLowerCase();

      // NO RECORD IS NOT AN ERROR
      if (normalized.contains(
            'no record',
          ) ||
          normalized.contains(
            'no data',
          ) ||
          normalized.contains(
            'record not found',
          )) {
        return VisitTopEmployeeReportModel
            .fromJson(
          json,
        );
      }

      throw Exception(
        message,
      );
    }

    return VisitTopEmployeeReportModel
        .fromJson(
      json,
    );
  } on DioException catch (e) {
    String message =
        'Unable to load top employee report';

    final dynamic errorData =
        e.response?.data;

    if (errorData is Map) {
      message =
          errorData['message']
                  ?.toString() ??
              message;
    } else if (errorData
        is String) {
      try {
        final dynamic decoded =
            jsonDecode(
          errorData,
        );

        if (decoded is Map) {
          message =
              decoded['message']
                      ?.toString() ??
                  message;
        }
      } catch (_) {}
    }

    throw Exception(
      message,
    );
  } catch (e) {
    rethrow;
  }
}

  // ============================================================
  // ERROR
  // ============================================================

  String _dioError(DioException error, {required String fallback}) {
    final dynamic data = error.response?.data;

    if (data is Map) {
      return data['message']?.toString() ??
          data['messsage']?.toString() ??
          fallback;
    }

    return fallback;
  }
}

// Only explicit no-record responses are empty reports; other failures stay errors.
bool _isNoVisitRecords(Map<String, dynamic> json) {
  final result = json['result'];
  if (result is List && result.isNotEmpty) return false;
  final message = json['message']?.toString().toLowerCase() ?? '';
  return RegExp(
    r'(?:no|not)\s+(?:data|records?)\s+found|(?:data|records?)\s+not\s+found',
  ).hasMatch(message);
}
