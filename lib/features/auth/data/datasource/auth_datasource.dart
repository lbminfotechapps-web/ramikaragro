import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/auth/data/models/login_model.dart';
import 'package:dio/dio.dart';

class AuthDatasource {
  final DioClient dioClient;

  AuthDatasource(this.dioClient);

  Future<LoginModel> loginUser(
    String username,
    String password,
    String fcmToken,
    String mobileInfo,
    String macAddress,
  ) async {
    try {
      print('Login request data:');
      print('username/email: $username');
      print('fcmToken: $fcmToken');
      print('password: $password');
      print('mobileInfo: $mobileInfo');
      print('macAddress: $macAddress');

      final response = await dioClient.client.post(
        ApiClient.login,
        data: FormData.fromMap({
          'username': username,
          'password': password,
          'fcmId': fcmToken,
          'mobileInfo': mobileInfo,
          'macAddress': macAddress,
        }),
      );

      print('Login response: ${response.data}');
      print('Response type: ${response.data.runtimeType}');
      final Map<String, dynamic> jsonData = jsonDecode(
        response.data.toString(),
      );
      return LoginModel.fromJson(jsonData);
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status: ${e.response?.statusCode}');

      throw Exception('Failed to login: ${e.message}');
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String empId,
  ) async {
    try {
      debugPrint('Change password request');

      final response = await dioClient.client.post(
        ApiClient.changePassword,
        data: FormData.fromMap({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'empId': empId,
        }),
      );

      debugPrint('Change password response: ${response.data}');

      debugPrint('Status code: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.message}');

      debugPrint('Response: ${e.response?.data}');

      debugPrint('Status: ${e.response?.statusCode}');

      throw Exception('Failed to change password: ${e.message}');
    } catch (e) {
      debugPrint('Change password error: $e');

      throw Exception('Failed to change password: $e');
    }
  }
}
