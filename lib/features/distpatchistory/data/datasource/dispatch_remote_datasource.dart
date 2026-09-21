import 'dart:convert';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/features/distpatchistory/data/models/dispatch_list_model.dart';
import 'package:dio/dio.dart';

class DispatchRemoteDataSource {
  final Dio dio;

  DispatchRemoteDataSource(this.dio);

  Future<List<DispatchListModel>> getDispatchList({
    required int userId,
    required String searchText,
    required String status,
    required String fromDate,
    required String toDate,
    required int startLimit,
  }) async {
    try {
      final response = await dio.post(
        ApiClient.getDispatchList,
        data: FormData.fromMap({
          'userId': userId.toString(),
          'searchText': searchText,
          'status': status,
          'fromDate': fromDate,
          'toDate': toDate,
          'startLimit': startLimit.toString(),
        }),
        options: Options(responseType: ResponseType.plain),
      );

      print('DISPATCH FINAL URL: ${response.requestOptions.uri}');
      print('DISPATCH STATUS: ${response.statusCode}');
      print('DISPATCH RESPONSE: ${response.data}');

      final rawResponse = response.data.toString().trim();

      if (rawResponse.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(rawResponse);

      dynamic result;

      if (decoded is List) {
        result = decoded;
      } else if (decoded is Map<String, dynamic>) {
        result =
            decoded['result'] ??
            decoded['data'] ??
            decoded['dispatchList'] ??
            decoded['dispatch_list'];
      }

      if (result is! List) {
        return [];
      }

      return result
          .whereType<Map>()
          .map(
            (item) =>
                DispatchListModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (error) {
      print('DISPATCH DIO ERROR: ${error.type}');
      print('DISPATCH URL: ${error.requestOptions.uri}');
      print('DISPATCH STATUS: ${error.response?.statusCode}');
      print('DISPATCH RESPONSE: ${error.response?.data}');

      final message = error.response?.data is String
          ? error.response!.data as String
          : error.message ?? 'Network error';
      throw Exception('Failed to load dispatch list: $message');
    } on FormatException catch (error) {
      throw Exception('Invalid dispatch response: ${error.message}');
    } catch (error) {
      throw Exception('Failed to load dispatch list: $error');
    }
  }
}
