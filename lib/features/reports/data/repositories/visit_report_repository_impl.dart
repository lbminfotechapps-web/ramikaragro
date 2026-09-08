import 'dart:convert';

import 'package:demo/features/reports/data/modles/visit_report_model.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/visit_report.dart';
import '../../domain/repositories/visit_report_repository.dart';
import '../datasources/visit_report_remote_data_source.dart';

class VisitReportRepositoryImpl
    implements VisitReportRepository {
  final VisitReportRemoteDataSource remoteDataSource;

  VisitReportRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<List<VisitReport>> getVisitReportDetails({
    required String logUserId,
    required String userId,
    required String fromDate,
    required String toDate,
  }) async {
    final Response response =
        await remoteDataSource.getVisitReportDetails(
      logUserId: logUserId,
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
    );

    print('');
    print('==============================================');
    print('REPOSITORY → VISIT REPORT');
    print('==============================================');

    print(
      'Response Type : ${response.data.runtimeType}',
    );

    dynamic data = response.data;

    // ----------------------------------------------------------
    // API may return JSON as String
    // ----------------------------------------------------------

    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (e) {
        throw Exception(
          'Failed to decode server response: $e',
        );
      }
    }

    // ----------------------------------------------------------
    // Validate response
    // ----------------------------------------------------------

    if (data is! Map) {
      throw Exception(
        'Invalid server response: ${data.runtimeType}',
      );
    }

    final Map<String, dynamic> responseData =
        Map<String, dynamic>.from(data);

    final bool status =
        responseData['status'] == true;

    final String message =
        responseData['message']?.toString() ?? '';

    print('Status  : $status');
    print('Message : $message');

    print('==============================================');

    // ----------------------------------------------------------
    // No records
    // ----------------------------------------------------------

    if (!status) {
      print('NO VISIT REPORT FOUND');

      return [];
    }

    // ----------------------------------------------------------
    // Result
    // ----------------------------------------------------------

    final result = responseData['result'];

    if (result == null) {
      return [];
    }

    if (result is! List) {
      throw Exception(
        'Invalid result format: ${result.runtimeType}',
      );
    }

    if (result.isEmpty) {
      return [];
    }

    // ----------------------------------------------------------
    // Convert JSON → Model
    // ----------------------------------------------------------

    final List<VisitReport> reports = [];

    for (final item in result) {
      if (item is Map) {
        reports.add(
          VisitReportModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }

    print('');
    print('==============================================');
    print('VISIT REPORT RESULT');
    print('==============================================');

    print('Total Records : ${reports.length}');

    print('==============================================');

    return reports;
  }
}