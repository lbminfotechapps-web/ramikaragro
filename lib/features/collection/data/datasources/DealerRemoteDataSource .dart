import 'package:dio/dio.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';



class DealerRemoteDataSource {
  final Dio _dio =
      DioClient().client;

  Future<List<Map<String, dynamic>>>
      searchDealers({
    required String userId,
    required String searchText,
  }) async {
    try {
      final response =
          await _dio.post(
        ApiClient
            .getTalukaWiseOutletForOrderNew,
        data: {
          'userId':
              userId,
          'searchText':
              searchText,
        },
      );

      if (response.data == null) {
        return [];
      }

      final data =
          response.data;

      if (data['status'] != true) {
        return [];
      }

      final List result =
          data['result'] ?? [];

      return result
          .map(
            (item) =>
                Map<String, dynamic>.from(
              item,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Unable to fetch dealers: $e',
      );
    }
  }
}