import 'package:dio/dio.dart';

import 'api_client.dart';

class DioClient {
  DioClient._internal();

  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;

  final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: ApiClient.baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Accept': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              print('API ${options.method}: ${options.uri}');
              handler.next(options);
            },
            onError: (error, handler) {
              print(
                'API ERROR ${error.response?.statusCode}: ${error.requestOptions.uri}',
              );
              print('API ERROR RESPONSE: ${error.response?.data}');
              handler.next(error);
            },
          ),
        );

  Dio get client => _dio;
}
