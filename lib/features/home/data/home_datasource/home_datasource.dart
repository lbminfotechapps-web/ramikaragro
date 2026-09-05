import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/home/data/home_model/menu_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class HomeDatasource {
  final DioClient dioClient;

  HomeDatasource(this.dioClient);

  Future<List<MenuModel>> fetchHomeMenu(int userId, String menuType) async {
    final formData = FormData.fromMap({
      'userId': userId,
      'menu_type': menuType,
    });

    print('userid $userId');
     print('menuid $menuType');

    final response = await dioClient.client.post(
      ApiClient.userMenu,
      data: formData,
    );

    print('Home menu status: ${response.statusCode}');
    print('Home menu response: ${response.data}');

    dynamic data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        throw const FormatException('Invalid JSON response from menu API');
      }
    }

    if (data is! Map) {
      throw const FormatException('Menu API response is not a JSON object');
    }

    final result = data['result'];
    if (result is! List) {
      throw const FormatException('Menu API result is not a List');
    }

    return result
        .whereType<Map>()
        .map((item) => MenuModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  
  
}