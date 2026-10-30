import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';

import '../../domain/entities/dealer_activity.dart';
import '../models/dealer_activity_model.dart';

abstract class DealerActivityRemoteDataSource {
  Future<String> submitActivity(DealerActivity activity);
}

class DealerActivityRemoteDataSourceImpl
    implements DealerActivityRemoteDataSource {
  final Dio dio;

  DealerActivityRemoteDataSourceImpl(DioClient dioClient)
    : dio = dioClient.client;

  /// Some servers send JSON with a text content type, so Dio leaves it a String.
  static String parseResponse(dynamic data) {
    dynamic decoded = data;
    if (decoded is String) {
      final text = decoded.trim().replaceFirst(RegExp(r'^\uFEFF'), '');
      try {
        decoded = jsonDecode(text);
      } on FormatException {
        throw const FormatException(
          'Server returned invalid JSON. Please try again.',
        );
      }
    }
    if (decoded is! Map) {
      throw const FormatException(
        'Invalid server response. Expected a JSON object.',
      );
    }
    final status = decoded['status']?.toString().trim().toLowerCase();
    final success = status == 'true' || status == '1';
    final message = decoded['message']?.toString().trim() ?? '';
    if (!success) {
      throw Exception(
        message.isNotEmpty ? message : 'Unable to submit dealer activity.',
      );
    }
    return message.isNotEmpty
        ? message
        : 'Dealer activity submitted successfully.';
  }
  // ---------------------------------------------------
  // IMAGE FILE NAME
  // Same convention as your Java implementation
  // ---------------------------------------------------

  String _createFileName(String prefix, String filePath) {
    final date = DateFormat('ddMMyyyy').format(DateTime.now());

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final extension = filePath.contains('.')
        ? filePath.substring(filePath.lastIndexOf('.')).toLowerCase()
        : '.jpg';

    return '${prefix}${date}_$timestamp$extension';
  }

  Future<MultipartFile> _createImagePart({
    required String path,
    required String prefix,
  }) async {
    final file = File(path);

    if (!await file.exists()) {
      throw Exception('Image file does not exist: $path');
    }

    final fileName = _createFileName(prefix, path);

    return MultipartFile.fromFile(file.path, filename: fileName);
  }

  // ---------------------------------------------------
  // SUBMIT DEALER / DISTRIBUTOR
  // ---------------------------------------------------

  @override
  Future<String> submitActivity(DealerActivity activity) async {
    final fields = DealerActivityModel(activity).toFields();

    final dealerProofImage = await _createImagePart(
      path: activity.dealerImagePath,
      prefix: 'DealerDistributorProofImage',
    );

    final shopBoardImage = await _createImagePart(
      path: activity.shopBoardImagePath,
      prefix: 'AttachmentShopBoardImage',
    );

    final formData = FormData.fromMap({
      ...fields,

      // Exact keys from Retrofit:
      'uploadImage2': dealerProofImage,
      'uploadImage3': shopBoardImage,
    });

    debugPrint('========== SUBMIT DEALER DISTRIBUTOR ==========');

    for (final entry in fields.entries) {
      debugPrint('${entry.key}: ${entry.value}');
    }

    for (final file in formData.files) {
      debugPrint('${file.key}: ${file.value.filename}');
    }

    try {
      final response = await dio.post(
        ApiClient.submitDealerDistributor,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return parseResponse(response.data);
    } on DioException catch (e) {
      debugPrint('Dealer activity error: ${e.message}');

      final responseData = e.response?.data;

      if (responseData is Map && responseData['message'] != null) {
        throw Exception(responseData['message'].toString());
      }

      throw Exception('Network error. Please check your connection.');
    }
  }
}
