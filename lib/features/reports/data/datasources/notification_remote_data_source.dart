
import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/features/reports/data/modles/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotificationList({
    required int userId,
    required bool isLogin,
    required String userType,
    required int startLimit,
  });
}

class NotificationRemoteDataSourceImpl
    implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl();

  @override
  Future<List<NotificationModel>> getNotificationList({
    required int userId,
    required bool isLogin,
    required String userType,
    required int startLimit,
  }) async {
    final url = Uri.parse(
      '${ApiClient.baseUrl}${ApiClient.getNotificationList}',
    );

    final requestBody = {
      'userId': userId.toString(),
      'isLogin': isLogin ? 'true' : 'false',
      'userType': userType,
      'startLimit': startLimit.toString(),
    };

    debugPrint('========================================');
    debugPrint('NOTIFICATION API REQUEST');
    debugPrint('URL       : $url');
    debugPrint('METHOD    : POST');
    debugPrint('USER ID   : $userId');
    debugPrint('IS LOGIN  : $isLogin');
    debugPrint('USER TYPE : $userType');
    debugPrint('LIMIT     : $startLimit');
    debugPrint('BODY      : $requestBody');
    debugPrint('========================================');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      debugPrint('========================================');
      debugPrint('NOTIFICATION API RESPONSE');
      debugPrint('STATUS CODE : ${response.statusCode}');
      debugPrint('BODY        : ${response.body}');
      debugPrint('CONTENT TYPE: ${response.headers['content-type']}');
      debugPrint('========================================');

      if (response.statusCode != 200) {
        throw Exception(
          'Notification API failed: ${response.statusCode}',
        );
      }

      if (response.body.trim().isEmpty) {
        return [];
      }

      final dynamic responseData = jsonDecode(response.body);

      if (responseData is! List) {
        throw Exception(
          'Invalid notification response format: '
          '${responseData.runtimeType}',
        );
      }

      final List<NotificationModel> notifications =
          responseData.map<NotificationModel>((item) {
        if (item is! Map) {
          throw Exception(
            'Invalid notification item format: '
            '${item.runtimeType}',
          );
        }

        return NotificationModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();

      debugPrint(
        'Notification count: ${notifications.length}',
      );

      return notifications;
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('NOTIFICATION API ERROR');
      debugPrint('ERROR       : $e');
      debugPrint('STACK TRACE : $stackTrace');
      debugPrint('========================================');

      rethrow;
    }
  }
}

