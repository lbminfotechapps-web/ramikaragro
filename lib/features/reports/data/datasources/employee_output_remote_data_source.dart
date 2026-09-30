import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';

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
