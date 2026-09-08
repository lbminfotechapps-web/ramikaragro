import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';

class EmployeeActivityRemoteDataSource {
  final DioClient dioClient;

  EmployeeActivityRemoteDataSource(this.dioClient);

  Future<Response> getEmployeeActivityDetails({
    required String userId,
    required String searchDate,
    required String logUserId,
  }) async {
    try {
      print('');
      print('==============================================');
      print('       EMPLOYEE ACTIVITY REPORT');
      print('==============================================');

      print(
        'URL        : ${ApiClient.getEmployeeActivityDetails}',
      );
      print('userId     : $userId');
      print('searchDate : $searchDate');
      print('logUserId  : $logUserId');

      print('==============================================');
      print('REQUEST TYPE : POST');
      print('REQUEST BODY : FormData');
      print('==============================================');

      final formData = FormData.fromMap({
        'userId': userId,
        'searchDate': searchDate,
        'logUserId': logUserId,
      });

      print('FORM DATA:');
      for (final field in formData.fields) {
        print('${field.key} : ${field.value}');
      }

      final response = await dioClient.client.post(
        ApiClient.getEmployeeActivityDetails,
        data: formData,
      );

      print('');
      print('==============================================');
      print('EMPLOYEE ACTIVITY API RESPONSE');
      print('==============================================');

      print('STATUS : ${response.statusCode}');
      print('BODY   : ${response.data}');

      print('==============================================');

      return response;
    } on DioException catch (e) {
      print('');
      print('==============================================');
      print('EMPLOYEE ACTIVITY DIO ERROR');
      print('==============================================');

      print('URL      : ${e.requestOptions.uri}');
      print('METHOD   : ${e.requestOptions.method}');
      print('DATA     : ${e.requestOptions.data}');
      print('HEADERS  : ${e.requestOptions.headers}');
      print('Message  : ${e.message}');
      print('Status   : ${e.response?.statusCode}');
      print('Response : ${e.response?.data}');

      print('==============================================');

      throw Exception(
        e.response?.data is String
            ? e.response?.data
            : e.message ?? 'Network error',
      );
    } catch (e) {
      print('');
      print('==============================================');
      print('EMPLOYEE ACTIVITY ERROR');
      print('==============================================');
      print('ERROR : $e');
      print('==============================================');

      throw Exception(
        'Failed to get employee activity: $e',
      );
    }
  }
}