import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';

class DealerRemoteDataSource {
  final DioClient dioClient;

  DealerRemoteDataSource(
    this.dioClient,
  );

  Future<Response> getNotVisitedDealers({
    required int days,
    required int startLimit,
  }) async {
    try {
      print('');
      print('========================================');
      print('API REQUEST');
      print('========================================');
      print('days       : $days');
      print('startLimit : $startLimit');
      print('========================================');

      final response =
          await dioClient.client.get(
        ApiClient.getLastThirtyNotVisited,
        queryParameters: {
          'days': days,
          'startLimit': startLimit,
        },
      );

      print('');
      print('========================================');
      print('API RESPONSE');
      print('========================================');
      print(
        'URL : ${response.requestOptions.uri}',
      );
      print(
        'Status : ${response.statusCode}',
      );
      print(
        'Type : ${response.data.runtimeType}',
      );
      print(
        'Data : ${response.data}',
      );
      print('========================================');

      return response;
    } on DioException catch (e) {
      print('');
      print('========================================');
      print('DIO ERROR');
      print('========================================');
      print('Message : ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status  : ${e.response?.statusCode}');
      print('========================================');

      throw Exception(
        'Failed to get not visited dealers: ${e.message}',
      );
    } catch (e) {
      print('Unexpected error: $e');

      throw Exception(
        'Failed to get not visited dealers: $e',
      );
    }
  }
}