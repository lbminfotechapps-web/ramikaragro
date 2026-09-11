import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:http/http.dart';

import '../models/my_expense_model.dart';

abstract class MyExpenseRemoteDataSource {
  Future<List<MyExpenseModel>> getMyExpenses({
    required int userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
  });
}

class MyExpenseRemoteDataSourceImpl
    implements MyExpenseRemoteDataSource {
  final DioClient dioClient;

  MyExpenseRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<List<MyExpenseModel>> getMyExpenses({
    required int userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
  }) async {
   final response = await dioClient.client.post(
  ApiClient.getMyExpensesList,
 data: Dio.FormData.fromMap({
    'userId': userId.toString(),
    'fromDate': fromDate,
    'toDate': toDate,
    'startLimit': startLimit.toString(),
  }),
);
    

    print(
      'My Expense API Response: ${response.data}',
    );

    dynamic responseData = response.data;

    if (responseData is String) {
      responseData = jsonDecode(responseData);
    }

    if (responseData is! Map<String, dynamic>) {
      throw Exception(
        'Invalid expense response',
      );
    }

    final status = responseData['status'];

    if (status != true) {
      throw Exception(
        responseData['message']?.toString() ??
            'Unable to get expenses',
      );
    }

    final result = responseData['result'];

    if (result is! List) {
      return [];
    }

    return result
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => MyExpenseModel.fromJson(item),
        )
        .toList();
  }
}