import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:solufine/features/reports/data/modles/employee_out_repo_detail_model.dart';

class EmployeeOutputRemoteDataSource {
  final DioClient dioClient;

  EmployeeOutputRemoteDataSource(this.dioClient);

  // ============================================================
  // EMPLOYEE OUTPUT REPORT
  // ============================================================

  Future<Response> getEmployeeOutputReport({
    required String userId,
    required String employeeId,
    required String fromDate,
    required String toDate,
    required String employeeName,
    required String startLimit,
  }) async {
    try {
      final formData = FormData.fromMap({
        'user_id': userId,
        'userId': employeeId,
        'from_date': fromDate,
        'to_date': toDate,
        'startLimit': startLimit,
        'emp_name': employeeName,
      });

      final response = await dioClient.client.post(
        ApiClient.getEmployeeOutputReport,
        data: formData,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is String
            ? e.response?.data
            : e.message ?? 'Network error',
      );
    } catch (e) {
      throw Exception('Failed to get employee output report: $e');
    }
  }

  Future<EmployeeOutRepoDetailsModel> getEmployeeOutputReportDetails({
    required String empId,
    required String fromdate,
    required String toDate,
  }) async {
    try {
      // ==============================
      // REQUEST PARAMETERS
      // ==============================
      final formData = FormData.fromMap({
        'empId': empId,
        'fromdate': fromdate,
        'toDate': toDate,
      });

      debugPrint('========== EMPLOYEE OUTPUT API REQUEST ==========');
      debugPrint('API Endpoint: ${ApiClient.getEmpOutputDetail}');
      debugPrint('Employee ID: $empId');
      debugPrint('From Date: $fromdate');
      debugPrint('To Date: $toDate');
      debugPrint('Request Parameters:');
      debugPrint(formData.fields.toString());

      // ==============================
      // API CALL
      // ==============================
      final response = await dioClient.client.post(
        ApiClient.getEmpOutputDetail,
        data: formData,
      );

      // ==============================
      // RESPONSE LOGGING
      // ==============================
      debugPrint('========== EMPLOYEE OUTPUT API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Type: ${response.data.runtimeType}');
      debugPrint('Response URL: ${response.realUri}');

      debugPrint('Response Data: ${response.data}', wrapWidth: 1024);

      // ==============================
      // HANDLE RESPONSE
      // ==============================
      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      if (responseData is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid employee output API response format',
        );
      }

      // ==============================
      // JSON TO MODEL
      // ==============================
      final model = EmployeeOutRepoDetailsModel.fromJson(responseData);

      // ==============================
      // MODEL DEBUG PRINT
      // ==============================
      debugPrint('========== EMPLOYEE OUTPUT PARSED DATA ==========');
      debugPrint('Status: ${model.status}');
      debugPrint('Message: ${model.message}');
      debugPrint('Total Records: ${model.result.length}');

      for (int i = 0; i < model.result.length; i++) {
        final item = model.result[i];

        debugPrint('---------- Record ${i + 1} ----------');
        debugPrint('Date: ${item.date}');
        debugPrint('Total Expense: ${item.totalExpense}');
        debugPrint('Total Kilometer: ${item.totalKilometer}');
        debugPrint('Present Status: ${item.presentStatus}');
      }

      debugPrint('========== EMPLOYEE OUTPUT API COMPLETED ==========');

      return model;
    } on DioException catch (e, stackTrace) {
      debugPrint('========== EMPLOYEE OUTPUT DIO ERROR ==========');
      debugPrint('Error Type: ${e.type}');
      debugPrint('Error Message: ${e.message}');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Error Response: ${e.response?.data}');
      debugPrint('Request URL: ${e.requestOptions.uri}');
      debugPrint('StackTrace: $stackTrace');

      throw Exception(
        e.response?.data is String
            ? e.response?.data
            : e.message ?? 'Network error',
      );
    } catch (e, stackTrace) {
      debugPrint('========== EMPLOYEE OUTPUT GENERAL ERROR ==========');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      throw Exception('Failed to get employee output report: $e');
    }
  }

  Future<Response> searchEmployees({
    required String logUserId,
    required String search,
  }) async {
    try {
      final FormData formData = FormData.fromMap({
        'user_id': logUserId,
        'searchtext': search,
      });

      final Response response = await dioClient.client.post(
        ApiClient.getEmployees,
        data: formData,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is String
            ? e.response?.data
            : e.message ?? 'Network error',
      );
    } catch (e) {
      throw Exception('Failed to search employees: $e');
    }
  }
}
