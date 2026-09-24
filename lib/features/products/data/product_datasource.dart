import 'package:flutter/material.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/products/data/model/fertilizer_category_model.dart';
import 'package:dio/dio.dart';
import 'package:solufine/features/products/data/model/product_name_model.dart';
import 'dart:convert';

import 'package:solufine/features/products/domain/entity/product_name.dart';

class ProductDatasource {
  final DioClient dioClient;

  ProductDatasource(this.dioClient);

  Future<List<FertilizerCategoryModel>> getProductList(
    String searchText,
  ) async {
    try {
      final formData = FormData.fromMap({'searchText': searchText});

      final response = await dioClient.client.post(
        ApiClient.getCategoryproductDetails,
        data: formData,
      );

      print('Product API Status Code: ${response.statusCode}');
      print('Product API Response: ${response.data}');

      dynamic responseData = response.data;

      // Sometimes Dio returns JSON as String
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid product API response');
      }

      final bool status = responseData['status'] == true;

      if (!status) {
        throw Exception(
          responseData['message']?.toString() ?? 'Failed to fetch product list',
        );
      }

      final result = responseData['result'];

      if (result is! List) {
        return [];
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map((json) => FertilizerCategoryModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      print('Product API Dio Error: ${e.message}');
      print('Product API Error Response: ${e.response?.data}');

      throw Exception(
        e.response?.data?['message']?.toString() ??
            e.message ??
            'Something went wrong while fetching products',
      );
    } catch (e) {
      print('Product API Error: $e');
      rethrow;
    }
  }

Future<ProductResponseModel> getProductNameList(
  String searchText,
) async {
  try {
    final formData = FormData.fromMap({
      'searchText': searchText,
    });

    final response = await dioClient.client.post(
      ApiClient.getProductName,
      data: formData,
    );

    debugPrint(
      'Product Search Status Code: ${response.statusCode}',
    );

    debugPrint(
      'Product Search Response: ${response.data}',
    );

    dynamic responseData = response.data;

    // Dio may sometimes return JSON String
    if (responseData is String) {
      responseData = jsonDecode(responseData);
    }

    if (responseData is! Map) {
      throw Exception(
        'Invalid product API response',
      );
    }

    final Map<String, dynamic> json =
        Map<String, dynamic>.from(
      responseData,
    );

    return ProductResponseModel.fromJson(json);
  } on DioException catch (e) {
    debugPrint(
      'Product Search Dio Error: ${e.message}',
    );

    debugPrint(
      'Product Search Error Response: '
      '${e.response?.data}',
    );

    throw Exception(
      e.response?.data is Map
          ? e.response?.data['message']?.toString() ??
              'Something went wrong while searching products'
          : e.message ??
              'Something went wrong while searching products',
    );
  } catch (e) {
    debugPrint(
      'Product Search Error: $e',
    );

    rethrow;
  }
}
}
