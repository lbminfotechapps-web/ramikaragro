import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/home/data/home_model/social_media_model.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';

abstract class SocialMediaRemoteDataSource {
  Future<List<SocialMediaModel>> getSocialMedia({
    required String userId,
  });
}

class SocialMediaRemoteDataSourceImpl
    implements SocialMediaRemoteDataSource {
  final DioClient dioClient;

  SocialMediaRemoteDataSourceImpl({
    required this.dioClient,
  });

  dynamic _parseResponse(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    }

    return data;
  }

  @override
  Future<List<SocialMediaModel>> getSocialMedia({
    required String userId,
  }) async {
    try {
      final requestData = {
        'userId': userId,
      };

      final response = await dioClient.client.post(
        ApiClient.getSocialMedia,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,

          // Useful while debugging API errors.
          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );

      print('=================================');
      print('SOCIAL MEDIA API');
      print('URL = ${response.requestOptions.uri}');
      print('REQUEST = $requestData');
      print('STATUS CODE = ${response.statusCode}');
      print('RESPONSE = ${response.data}');
      print('=================================');

      if (response.statusCode != 200) {
        throw ServerException(
          'Server error: ${response.statusCode}',
        );
      }

      final data = _parseResponse(response.data);

      if (data is! Map) {
        throw ServerException(
          'Invalid server response',
        );
      }

      final status = data['status'] == true;

      if (!status) {
        throw ServerException(
          data['message']?.toString() ??
              'No social media records found',
        );
      }

      final result = data['result'];

      if (result == null) {
        return [];
      }

      if (result is! List) {
        throw ServerException(
          'Social media result is not a list',
        );
      }

      final List<SocialMediaModel> socialMedia = [];

      for (final item in result) {
        if (item is Map) {
          socialMedia.add(
            SocialMediaModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }

      print(
        'TOTAL SOCIAL MEDIA = ${socialMedia.length}',
      );

      return socialMedia;
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print('SOCIAL MEDIA DIO ERROR = ${e.message}');

      throw NetworkException(
        e.message ?? 'Network error occurred',
      );
    } catch (e) {
      print('SOCIAL MEDIA ERROR = $e');

      throw NetworkException(
        e.toString(),
      );
    }
  }
}