import 'dart:convert';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/features/salesreturnhistory/data/model/dealer_name_model.dart';
import 'package:solufine/features/salesreturnhistory/data/model/sales_return_history_model.dart';
import 'package:dio/dio.dart';

class SalesReturnHistoryRemoteDatasource {
  final Dio dio;

  SalesReturnHistoryRemoteDatasource({required this.dio});

  @override
  Future<List<SalesReturnHistoryModel>> getSalesReturnHistory({
    required Map<String, dynamic> params,
  }) async {
    final response = await dio.post(
      ApiClient.salesReturnHistory,
      data: FormData.fromMap(params),
      options: Options(responseType: ResponseType.plain),
    );

    final String responseString = response.data.toString().trim();

    final Map<String, dynamic> json = jsonDecode(responseString);

    if (json['status'] != true) {
      throw Exception(
        json['message']?.toString() ?? 'Unable to get sales return history',
      );
    }

    final List result = json['result'] ?? [];

    return result
        .map(
          (item) =>
              SalesReturnHistoryModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<List<DealerNameModel>> searchDealer({
    required Map<String, dynamic> params,
  }) async {
    final response = await dio.post(
      ApiClient.getDealerName,
      data: FormData.fromMap(params),
      options: Options(responseType: ResponseType.plain),
    );

    final String responseString = response.data.toString().trim();

    final Map<String, dynamic> json = jsonDecode(responseString);

    if (json['status'] != true) {
      throw Exception(json['message']?.toString() ?? 'Dealer not found');
    }

    final List result = json['result'] ?? [];

    return result
        .map(
          (item) => DealerNameModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
