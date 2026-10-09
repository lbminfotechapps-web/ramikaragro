import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/ai/data/model/ai_chat_response_model.dart';

class AiDatasource {
  final DioClient dioClient;

  AiDatasource(this.dioClient);



  Future<AiChatResponseModel> askAiQuery(
    String logUserId,
    String question,
    String format,
    String usePrevious,
  ) async {
    try {
      debugPrint('========== AI REQUEST ==========');
      debugPrint('User ID: $logUserId');
      debugPrint('Question: $question');
      debugPrint('Format: $format');
      debugPrint('Use Previous: $usePrevious');

      final response = await dioClient.client.post(
        ApiClient.askAiQuery,
        data: FormData.fromMap({
          'logUserId': logUserId,
          'question': question,
          'format': format,
          'usePrevious': usePrevious,
        }),
      );

      debugPrint('AI Response: ${response.data}');

      // Handle both JSON objects and JSON strings.
      final dynamic responseData = response.data;

      final Map<String, dynamic> jsonData;

      if (responseData is Map) {
        jsonData = Map<String, dynamic>.from(responseData);
      } else if (responseData is String) {
        jsonData = Map<String, dynamic>.from(jsonDecode(responseData) as Map);
      } else {
        throw const FormatException('Invalid AI API response format');
      }

      return AiChatResponseModel.fromJson(jsonData);
    } on DioException catch (e) {
      debugPrint('AI Dio Error: ${e.message}');
      debugPrint('AI Error Response: ${e.response?.data}');
      debugPrint('AI Status Code: ${e.response?.statusCode}');

      throw Exception('Failed to get AI response: ${e.message}');
    } catch (e) {
      debugPrint('AI Error: $e');

      throw Exception('Failed to get AI response: $e');
    }
  }
}
