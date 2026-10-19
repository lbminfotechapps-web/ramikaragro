import 'package:dio/dio.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';

import '../models/plant_product_model.dart';

abstract class PlantProductRemoteDataSource {
  Future<List<PlantProductModel>>
      getRecommendedProducts({
    required String searchText,
  });
}

class PlantProductRemoteDataSourceImpl
    implements PlantProductRemoteDataSource {
  final DioClient dioClient;

  PlantProductRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<List<PlantProductModel>>
      getRecommendedProducts({
    required String searchText,
  }) async {
    try {
      if (searchText.trim().isEmpty) {
        return [];
      }

      // ========================================================
      // PARAMS
      //
      // SAME AS JAVA:
      //
      // params.put(
      //   "productMicronutrient",
      //   resultText
      // );
      // ========================================================

      final Map<String, String> params = {
        'productMicronutrient':
            searchText.trim(),
      };

      print('======================================');
      print('GET MICRONUTRIENT PRODUCTS');
      print(
        'URL: ${ApiClient.baseUrl}'
        '${ApiClient.getPlantRecommendedProducts}',
      );
      print(
        'PARAMS: $params',
      );
      print('======================================');

      final Response<dynamic> response =
          await dioClient.client.post(
        ApiClient
            .getPlantRecommendedProducts,

        // IMPORTANT:
        // @FormUrlEncoded + @FieldMap equivalent.
        data:
            params,

        options:
            Options(
          contentType:
              Headers
                  .formUrlEncodedContentType,
        ),
      );

      print(
        'PRODUCT STATUS: ${response.statusCode}',
      );

      print(
        'PRODUCT RESPONSE: ${response.data}',
      );

      final dynamic data =
          response.data;

      if (data == null) {
        return [];
      }

      if (data is! Map) {
        throw Exception(
          'Invalid product response.',
        );
      }

      // ========================================================
      // RESULT
      // ========================================================

      final dynamic result =
          data['result'];

      if (result == null) {
        return [];
      }

      if (result is! List) {
        throw Exception(
          'Invalid recommended products response.',
        );
      }

      final List<PlantProductModel> products =
          result
              .where(
                (item) =>
                    item is Map,
              )
              .map(
                (item) =>
                    PlantProductModel.fromJson(
                  Map<String, dynamic>.from(
                    item as Map,
                  ),
                ),
              )
              .toList();

      print(
        'PRODUCT COUNT: ${products.length}',
      );

      return products;
    } on DioException catch (e) {
      print('======================================');
      print('MICRONUTRIENT PRODUCT API ERROR');
      print(
        'STATUS: ${e.response?.statusCode}',
      );
      print(
        'MESSAGE: ${e.message}',
      );
      print(
        'RESPONSE: ${e.response?.data}',
      );
      print('======================================');

      throw Exception(
        _getErrorMessage(e),
      );
    }
  }

  String _getErrorMessage(
    DioException e,
  ) {
    final dynamic data =
        e.response?.data;

    if (data is Map) {
      final String message =
          data['message']
                  ?.toString()
                  .trim() ??
              '';

      if (message.isNotEmpty) {
        return message;
      }
    }

    if (e.type ==
        DioExceptionType.connectionTimeout) {
      return 'Product API connection timeout.';
    }

    if (e.type ==
        DioExceptionType.receiveTimeout) {
      return 'Product API response timeout.';
    }

    if (e.type ==
        DioExceptionType.connectionError) {
      return 'Please check internet connection.';
    }

    return e.message ??
        'Unable to load recommended products.';
  }
}