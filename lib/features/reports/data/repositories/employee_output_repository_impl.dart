import 'dart:convert';

import 'package:dio/dio.dart';

import '../../domain/entities/assign_employee.dart';
import '../../domain/entities/employee_output_report.dart';
import '../../domain/repositories/employee_output_repository.dart';

import '../datasources/employee_output_remote_data_source.dart';
import '../modles/assign_employee_model.dart';
import '../modles/employee_output_report_model.dart';

class EmployeeOutputRepositoryImpl
    implements EmployeeOutputRepository {
  final EmployeeOutputRemoteDataSource remoteDataSource;

  EmployeeOutputRepositoryImpl(this.remoteDataSource);

  // ============================================================
  // GET EMPLOYEE OUTPUT REPORT
  // ============================================================

  @override
  Future<List<EmployeeOutputReport>> getEmployeeOutputReport({
    required String userId,
    required String employeeId,
    required String fromDate,
    required String toDate,
    required String employeeName,
    required String startLimit,
  }) async {
    try {
      print('========================================');
      print('REPOSITORY → EMPLOYEE OUTPUT REPORT');
      print('========================================');
      print('userId       : $userId');
      print('employeeId   : $employeeId');
      print('fromDate     : $fromDate');
      print('toDate       : $toDate');
      print('employeeName : $employeeName');
      print('startLimit   : $startLimit');

      final Response response =
          await remoteDataSource.getEmployeeOutputReport(
        userId: userId,
        employeeId: employeeId,
        fromDate: fromDate,
        toDate: toDate,
        employeeName: employeeName,
        startLimit: startLimit,
      );

      print('RESPONSE STATUS CODE : ${response.statusCode}');
      print('RESPONSE DATA        : ${response.data}');

      dynamic data = response.data;

      // ----------------------------------------------------------
      // API can return JSON as String
      // ----------------------------------------------------------

      if (data is String) {
        data = jsonDecode(data);
      }

      // ----------------------------------------------------------
      // Validate response
      // ----------------------------------------------------------

      if (data is! Map) {
        throw Exception(
          'Invalid employee output response format',
        );
      }

      final Map<String, dynamic> responseData =
          Map<String, dynamic>.from(data);

      print('API STATUS  : ${responseData['status']}');
      print('API MESSAGE : ${responseData['message']}');

      // ----------------------------------------------------------
      // API status false
      // ----------------------------------------------------------

      if (responseData['status'] != true) {
        print('No employee output data found');
        return [];
      }

      // ----------------------------------------------------------
      // Get result
      // ----------------------------------------------------------

      final dynamic result = responseData['result'];

      if (result == null) {
        print('Result is null');
        return [];
      }

      if (result is! List) {
        throw Exception(
          'Invalid employee output result format',
        );
      }

      print('RESULT COUNT : ${result.length}');

      // ----------------------------------------------------------
      // JSON → Model → Entity
      // ----------------------------------------------------------

      final reports = result
          .whereType<Map>()
          .map(
            (item) => EmployeeOutputReportModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      print('REPORT COUNT : ${reports.length}');
      print('========================================');

      return reports;
    } on DioException catch (e) {
      print('========================================');
      print('DIO ERROR - EMPLOYEE OUTPUT');
      print('========================================');
      print('Message : ${e.message}');
      print('Response: ${e.response?.data}');
      print('========================================');

      throw Exception(
        e.response?.data is String
            ? e.response?.data
            : e.message ?? 'Network error',
      );
    } catch (e) {
      print('========================================');
      print('REPOSITORY ERROR');
      print('========================================');
      print(e);
      print('========================================');

      throw Exception(
        'Failed to get employee output report: $e',
      );
    }
  }

  // ============================================================
  // SEARCH EMPLOYEES
  // ============================================================

  @override
  Future<List<AssignEmployee>> searchEmployees({
    required String logUserId,
    required String search,
  }) async {
    try {
      final Response response =
          await remoteDataSource.searchEmployees(
        logUserId: logUserId,
        search: search,
      );

      dynamic data = response.data;

      // API can return JSON as String
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is! Map) {
        throw Exception(
          'Invalid employee search response format',
        );
      }

      final Map<String, dynamic> responseData =
          Map<String, dynamic>.from(data);

      // status false = no employees found
      if (responseData['status'] != true) {
        return [];
      }

      final dynamic result = responseData['result'];

      if (result == null) {
        return [];
      }

      if (result is! List) {
        throw Exception(
          'Invalid employee search result format',
        );
      }

      return result
          .whereType<Map>()
          .map(
            (item) => AssignEmployeeModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is String
            ? e.response?.data
            : e.message ?? 'Network error',
      );
    } catch (e) {
      throw Exception(
        'Failed to search employees: $e',
      );
    }
  }
}