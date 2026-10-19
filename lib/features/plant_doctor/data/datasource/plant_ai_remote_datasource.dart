import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/plant_analysis_type.dart';
import '../models/plant_analysis_model.dart';

abstract class PlantAiRemoteDataSource {
  Future<PlantAnalysisModel> analyzePlant({
    required String imagePath,
    required PlantAnalysisType type,
  });
}

class PlantAiRemoteDataSourceImpl
    implements PlantAiRemoteDataSource {
  final Dio dio;

  PlantAiRemoteDataSourceImpl({
    required this.dio,
  });

  // ============================================================
  // SAME AS JAVA API_KEY
  // ============================================================

  static const String _apiKey =
      'AIzaSyCIvxzxeSByWOxL4Ao9FgDCg8lcynFimbg';

  // ============================================================
  // SAME AS JAVA API_URL
  // ============================================================

  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/'
      'v1beta/models/gemini-2.0-flash:generateContent';

  @override
  Future<PlantAnalysisModel> analyzePlant({
    required String imagePath,
    required PlantAnalysisType type,
  }) async {
    try {
      if (_apiKey.trim().isEmpty ||
          _apiKey == 'YOUR_GEMINI_API_KEY') {
        throw Exception(
          'Please configure Gemini API key.',
        );
      }

      final File imageFile =
          File(imagePath);

      if (!await imageFile.exists()) {
        throw Exception(
          'Selected image not found.',
        );
      }

      // Read image
      final List<int> imageBytes =
          await imageFile.readAsBytes();

      // Same as Java Base64.encodeToString(...)
      final String base64Image =
          base64Encode(
        imageBytes,
      );

      // ========================================================
      // JAVA:
      // sendImageAndQuestion()
      // ========================================================

      final String marathiResult =
          await _sendGeminiRequest(
        base64Image:
            base64Image,
        prompt:
            type.marathiPrompt,
      );

      // ========================================================
      // JAVA:
      // sendImageAndQuestionEnglish()
      // ========================================================

      final String englishResult =
          await _sendGeminiRequest(
        base64Image:
            base64Image,
        prompt:
            type.englishPrompt,
      );

      return PlantAnalysisModel(
        marathiResult:
            marathiResult,
        englishResult:
            englishResult,
      );
    } on DioException catch (e) {
      throw Exception(
        _getDioMessage(e),
      );
    }
  }

  // ============================================================
  // GEMINI REQUEST
  // ============================================================

  Future<String> _sendGeminiRequest({
    required String base64Image,
    required String prompt,
  }) async {
    // Same JSON structure as Java
    final Map<String, dynamic> body = {
      'contents': [
        {
          'parts': [
            {
              'inlineData': {
                'mimeType':
                    'image/jpeg',
                'data':
                    base64Image,
              },
            },
            {
              'text':
                  prompt,
            },
          ],
        },
      ],
    };

    final Response<dynamic> response =
        await dio.post(
      _apiUrl,
      data:
          body,
      options:
          Options(
        headers: {
          // Same as Java:
          // .addHeader("x-goog-api-key", API_KEY)
          'x-goog-api-key':
              _apiKey,

          'Content-Type':
              'application/json',

          'Accept':
              'application/json',
        },
      ),
    );

    final dynamic data =
        response.data;

    if (data is! Map) {
      throw Exception(
        'Invalid Gemini response.',
      );
    }

    final dynamic candidates =
        data['candidates'];

    if (candidates is! List ||
        candidates.isEmpty) {
      throw Exception(
        'No Gemini response found.',
      );
    }

    final dynamic firstCandidate =
        candidates.first;

    if (firstCandidate is! Map) {
      throw Exception(
        'Invalid Gemini candidate.',
      );
    }

    final dynamic content =
        firstCandidate['content'];

    if (content is! Map) {
      throw Exception(
        'Gemini content not found.',
      );
    }

    final dynamic parts =
        content['parts'];

    if (parts is! List ||
        parts.isEmpty) {
      throw Exception(
        'Gemini result is empty.',
      );
    }

    final dynamic firstPart =
        parts.first;

    if (firstPart is! Map) {
      throw Exception(
        'Invalid Gemini result.',
      );
    }

    final String text =
        firstPart['text']
                ?.toString()
                .trim() ??
            '';

    if (text.isEmpty) {
      throw Exception(
        'Gemini returned empty response.',
      );
    }

    return text;
  }

  String _getDioMessage(
    DioException e,
  ) {
    final dynamic data =
        e.response?.data;

    if (data is Map) {
      final dynamic error =
          data['error'];

      if (error is Map) {
        final String message =
            error['message']
                    ?.toString()
                    .trim() ??
                '';

        if (message.isNotEmpty) {
          return message;
        }
      }
    }

    if (e.type ==
        DioExceptionType.connectionError) {
      return 'Please check internet connection.';
    }

    if (e.type ==
        DioExceptionType.connectionTimeout) {
      return 'Gemini connection timeout.';
    }

    if (e.type ==
        DioExceptionType.receiveTimeout) {
      return 'Gemini response timeout.';
    }

    if (e.type ==
        DioExceptionType.sendTimeout) {
      return 'Image upload timeout.';
    }

    return e.message ??
        'Unable to analyze plant.';
  }
}