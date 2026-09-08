import 'package:dio/dio.dart';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';

class EmployeeOutputRemoteDataSource {
  final DioClient dioClient;

  EmployeeOutputRemoteDataSource(
    this.dioClient,
  );

  // ============================================================
  // EMPLOYEE OUTPUT REPORT
  // ============================================================

  Future<Response> getEmployeeOutputReport({
    required String logUserId,
    required String employeeId,
    required String fromDate,
    required String toDate,
    required String employeeName,
    required String startLimit,
  }) async {
    try {
      final FormData formData =
          FormData.fromMap({
        'user_id': logUserId,
        'userId': employeeId,
        'from_date': fromDate,
        'to_date': toDate,
        'startLimit': startLimit,
        'emp_name': employeeName,
      });

      return await dioClient.client.post(
        ApiClient.getEmployeeOutputReport,
        data: formData,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is String
            ? e.response?.data
            : e.message ?? 'Network error',
      );
    } catch (e) {
      throw Exception(
        'Failed to get employee output report: $e',
      );
    }
  }

  // ============================================================
  // SEARCH EMPLOYEES
  // ============================================================

  Future<Response> searchEmployees({
    required String logUserId,
    required String search,
  }) async {
    try {
      final FormData formData =
          FormData.fromMap({
        'logUserId': logUserId,
        'search': search,
      });

      return await dioClient.client.post(
        ApiClient.getEmployees,
        data: formData,
      );
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