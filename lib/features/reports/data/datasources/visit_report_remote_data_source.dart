import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';

class VisitReportRemoteDataSource {
  final DioClient dioClient;

  VisitReportRemoteDataSource(this.dioClient);

  Future<Response> getVisitReportDetails({
    required String logUserId,
    required String userId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      print('');
      print('==============================================');
      print('          VISIT REPORT API');
      print('==============================================');

      print('URL        : ${ApiClient.getVisitReportDetails}');
      print('logUserId  : $logUserId');
      print('userId     : $userId');
      print('fromDate   : $fromDate');
      print('toDate     : $toDate');

      print('==============================================');
      print('REQUEST TYPE : POST');
      print('REQUEST BODY : FormData');
      print('==============================================');

      final formData = FormData.fromMap({
        'logUserId': logUserId,
        'userId': userId,
        'fromDate': fromDate,
        'toDate': toDate,
      });

      print('FORM DATA:');

      for (final field in formData.fields) {
        print('${field.key} : ${field.value}');
      }

      final response = await dioClient.client.post(
        ApiClient.getVisitReportDetails,
        data: formData,
      );

      print('');
      print('==============================================');
      print('VISIT REPORT API RESPONSE');
      print('==============================================');

      print('STATUS : ${response.statusCode}');
      print('BODY   : ${response.data}');

      print('==============================================');

      return response;
    } on DioException catch (e) {
      print('');
      print('==============================================');
      print('VISIT REPORT DIO ERROR');
      print('==============================================');

      print('URL      : ${e.requestOptions.uri}');
      print('METHOD   : ${e.requestOptions.method}');
      print('DATA     : ${e.requestOptions.data}');
      print('STATUS   : ${e.response?.statusCode}');
      print('MESSAGE  : ${e.message}');
      print('RESPONSE : ${e.response?.data}');

      print('==============================================');

      throw Exception(
        e.response?.data is String
            ? e.response?.data
            : e.message ?? 'Network error',
      );
    } catch (e) {
      print('');
      print('==============================================');
      print('VISIT REPORT ERROR');
      print('==============================================');

      print('ERROR : $e');

      print('==============================================');

      throw Exception(
        'Failed to get visit report: $e',
      );
    }
  }
}