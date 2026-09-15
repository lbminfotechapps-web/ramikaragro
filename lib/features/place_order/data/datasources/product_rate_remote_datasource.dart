import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';

import '../models/product_rate_model.dart';

class ProductRateRemoteDataSource {
  final DioClient dioClient;

  ProductRateRemoteDataSource({
    required this.dioClient,
  });

  Future<List<ProductRateModel>> getProductDetailRates({
    required String productId,
    required String dealerId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'productId': productId,
        'dealerId': dealerId,
      });

      final response = await dioClient.client.post(
        ApiClient.getProductDetailRatesKvat,
        data: formData,
        options: Options(
          responseType: ResponseType.plain,
        ),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw Exception(
          'Unable to fetch product rates',
        );
      }

      final String rawResponse =
          response.data.toString().trim();

      if (rawResponse.isEmpty) {
        return [];
      }

      final dynamic decoded =
          jsonDecode(rawResponse);

      if (decoded is! Map<String, dynamic>) {
        return [];
      }

      final bool status =
          decoded['status'] == true;

      if (!status) {
        return [];
      }

      final dynamic result =
          decoded['result'];

      if (result is! List) {
        return [];
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map(ProductRateModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to fetch product rates',
      );
    } catch (e) {
      throw Exception(
        e.toString(),
      );
    }
  }
}