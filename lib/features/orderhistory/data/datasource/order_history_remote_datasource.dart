import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/features/orderhistory/data/model/order_history_model.dart';
import 'package:dio/dio.dart';

abstract class OrderHistoryRemoteDataSource {
  Future<List<OrderHistoryModel>> getOrderHistory({
    required int userId,
    required String searchText,
    required String status,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required int pageSize,
  });

  Future<String> updateOrderStatus({
    required int userId,
    required String orderId,
    required String orderStatus,
    required String remark,
  });
}

class OrderHistoryRemoteDataSourceImpl implements OrderHistoryRemoteDataSource {
  final Dio dio;

  OrderHistoryRemoteDataSourceImpl(this.dio);

  @override
  Future<List<OrderHistoryModel>> getOrderHistory({
    required int userId,
    required String searchText,
    required String status,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required int pageSize,
  }) async {
    final response = await dio.post(
      ApiClient.getOrderHistory,
      data: FormData.fromMap({
        'empId': userId.toString(),
        'searchText': searchText,
        'status': status,
        'fromDate': fromDate,
        'toDate': toDate,
        'startLimit': startLimit.toString(),
        'pageSize': pageSize.toString(),
      }),
      options: Options(responseType: ResponseType.plain),
    );

    final rawResponse = response.data.toString().trim();

    if (rawResponse.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(rawResponse);

    dynamic listData;

    if (decoded is List) {
      listData = decoded;
    } else if (decoded is Map<String, dynamic>) {
      listData =
          decoded['result'] ??
          decoded['data'] ??
          decoded['order_list'] ??
          decoded['orders'];
    }

    if (listData is! List) {
      return [];
    }

    return listData
        .whereType<Map>()
        .map(
          (item) => OrderHistoryModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<String> updateOrderStatus({
    required int userId,
    required String orderId,
    required String orderStatus,
    required String remark,
  }) async {
    final response = await dio.post(
      ApiClient.updateOrderStatus,
      data: FormData.fromMap({
        'empId': userId.toString(),
        'orderId': orderId,
        'orderStatus': orderStatus,
        'remark': remark,
      }),
      options: Options(responseType: ResponseType.plain),
    );

    final rawResponse = response.data.toString().trim();

    if (rawResponse.isEmpty) {
      return 'Something went wrong';
    }

    final decoded = jsonDecode(rawResponse);

    if (decoded is Map<String, dynamic>) {
      return decoded['message']?.toString() ??
          decoded['msg']?.toString() ??
          'Order status updated successfully';
    }

    return 'Order status updated successfully';
  }
}
