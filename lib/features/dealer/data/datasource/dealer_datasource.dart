import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/auth/data/models/login_model.dart';
import 'package:dio/dio.dart';

class AuthDatasource {
  final DioClient dioClient;

  AuthDatasource(this.dioClient);

  Future<LoginModel> loginUser(String username, String password, String fcmToken) async {
    try {
      print('Login request data:');
      print('username/email: $username');
      print('fcmToken: $fcmToken');
      print('password: $password');

      final response = await dioClient.client.post(
        ApiClient.login,
        data: FormData.fromMap({
          'username': username,
          'password': password,
          'fcmId': fcmToken
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
}
