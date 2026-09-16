import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/home/data/home_model/homevisit_model.dart';
import 'package:demo/features/home/data/home_model/inpunchpending_model.dart';
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

  Future<Map<String, dynamic>> fetchVisitCountGraph(
    int userId,
    String searchFromDate,
    String searchToDate,
  ) async {
    final formData = FormData.fromMap({
      'userId': userId,
      'searchfromDate': searchFromDate,
      'searchtoDate': searchToDate,
    });
    print('userId $userId');
    print('searchfromDate $searchFromDate');
    print('searchtoDate $searchToDate');

    final response = await dioClient.client.post(
      ApiClient.visitCountgraph,
      data: formData,
    );

    print('Home graph status: ${response.statusCode}');
    print('Home graph response: ${response.data}');

    dynamic data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        throw const FormatException('Invalid JSON response from menu API');
      }
    }

    if (data is! Map) {
      throw const FormatException(
        'Visit count API response is not a JSON object',
      );
    }

    final responseData = Map<String, dynamic>.from(data);
    if (!responseData.containsKey('status') ||
        !responseData.containsKey('message') ||
        !responseData.containsKey('tot_dealer_cnt') ||
        !responseData.containsKey('tot_farmer_cnt')) {
      throw const FormatException(
        'Visit count API response has an invalid format',
      );
    }

    return responseData;
  }

  Future<HomeVisitModel> getHomeVisitCount({required String userId}) async {
    final formdata = FormData.fromMap({"userId": userId});
    final response = await dioClient.client.post(
      ApiClient.getEmployeeVisitCount,
      data: formdata,
    );

    print('home visit data %%%%%%%%$response');

    final responseString = response.data.toString().trim();

    final Map<String, dynamic> jsonData = jsonDecode(responseString);

    return HomeVisitModel.fromJson(jsonData);
  }

  Future<List<InpunchPendingModel>> getInpunchPending(String userId) async {
    try {
      print('========================================');
      print('GET INPUNCH PENDING API');
      print('user_id: $userId');
      print('========================================');

      final response = await dioClient.client.post(
        ApiClient.getInpunchPending,
        data: FormData.fromMap({'user_id': userId}),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RAW RESPONSE TYPE: ${response.data.runtimeType}');
      print('RAW RESPONSE: ${response.data}');

      dynamic data = response.data;

      // PHP API may return JSON as String
      if (data is String) {
        print('Response is String. Decoding JSON...');

        data = jsonDecode(data.trim());

        print('DECODED DATA: $data');
      }

      if (data is! Map) {
        throw Exception('Invalid response format: ${data.runtimeType}');
      }

      print('STATUS: ${data['status']}');
      print('MESSAGE: ${data['message']}');

      final status = data['status'];

      if (status != true) {
        throw Exception(
          data['message']?.toString() ?? 'Failed to get inpunch pending data',
        );
      }

      final result = data['result'];

      print('RESULT TYPE: ${result.runtimeType}');
      print('RESULT LENGTH: ${result is List ? result.length : 'Not List'}');
      print('RESULT: $result');

      if (result == null) {
        print('RESULT IS NULL');
        return [];
      }

      if (result is! List) {
        throw Exception('Invalid result format: ${result.runtimeType}');
      }

      final pendingList = result.whereType<Map>().map((item) {
        print('----------------------------------------');
        print('ITEM: $item');

        final json = Map<String, dynamic>.from(item);

        print('NAME: ${json['fld_adm_name']}');
        print('MOBILE: ${json['fld_mobile_no']}');

        final model = InpunchPendingModel.fromJson(json);

        print('MODEL NAME: ${model.fldAdmName}');
        print('MODEL MOBILE: ${model.fldMobileNo}');

        return model;
      }).toList();

      print('========================================');
      print('TOTAL PENDING: ${pendingList.length}');
      print('========================================');

      return pendingList;
    } on DioException catch (e) {
      print('DIO ERROR: ${e.message}');
      print('DIO RESPONSE: ${e.response?.data}');
      print('DIO STATUS: ${e.response?.statusCode}');

      throw Exception(e.message ?? 'Network error');
    } catch (e, stackTrace) {
      print('ERROR: $e');
      print('STACK TRACE: $stackTrace');

      rethrow;
    }
  }
}
