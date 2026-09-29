import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/features/selfcollectionassign/data/model/collection_type_model.dart';

abstract class CollectionTypeRemoteDataSource {
  Future<CollectionTypeResponseModel> getCollectionType();
}

class CollectionTypeRemoteDataSourceImpl
    implements CollectionTypeRemoteDataSource {
  final Dio dio;

  CollectionTypeRemoteDataSourceImpl({required this.dio});

  @override
  Future<CollectionTypeResponseModel> getCollectionType() async {
    try {
      final response = await dio.post(
        ApiClient.get_collection_type,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        if (data is! Map) {
          throw const FormatException(
            'Expected a collection type response JSON object',
          );
        }
        return CollectionTypeResponseModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception('Failed to fetch collection type');
    } on DioException catch (e) {
      dynamic data = e.response?.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } on FormatException {
          // Non-JSON error bodies should fall back to Dio's error message.
        }
      }
      throw Exception(
        (data is Map ? data['message']?.toString() : null) ??
            e.message ??
            'Something went wrong',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
