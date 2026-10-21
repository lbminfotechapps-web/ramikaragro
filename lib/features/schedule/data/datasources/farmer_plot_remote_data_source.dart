
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api_constant/api_client.dart';
import '../../../../core/api_constant/dio_client.dart';

import '../models/farmer_plot_model.dart';

abstract class FarmerPlotRemoteDataSource {
  Future<List<FarmerPlotModel>> getFarmerPlots({
    required String empId,
    required String farmerId,
    String plotName = '',
    String cropId = '',
  });
}

class FarmerPlotRemoteDataSourceImpl
    implements FarmerPlotRemoteDataSource {
  final DioClient dioClient;

  const FarmerPlotRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<List<FarmerPlotModel>> getFarmerPlots({
    required String empId,
    required String farmerId,
    String plotName = '',
    String cropId = '',
  }) async {
    try {
      final params = <String, dynamic>{
        'empId': empId,
        'farmerId': farmerId,
        'plotName': plotName,
        'cropId': cropId,
      };

      debugPrint('GET FARMER PLOTS REQUEST: $params');

      final response =
          await dioClient.client.post<dynamic>(
        ApiClient.getFarmerPlots,
        data: params,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
        ),
      );

      dynamic body = response.data;

      if (body is String) {
        body = jsonDecode(body.trim());
      }

      if (body is! Map) {
        throw const FormatException(
          'Invalid getFarmerPlots response',
        );
      }

      final data = Map<String, dynamic>.from(body);
      final status = data['status'];
      final message = data['message']?.toString() ?? '';

      final success =
          status == true ||
          status == 1 ||
          status.toString().toLowerCase() == 'true' ||
          status.toString() == '1';

      if (!success) {
        if (message.toLowerCase().contains('no record')) {
          return [];
        }

        throw Exception(
          message.isEmpty
              ? 'Unable to load farmer plots'
              : message,
        );
      }

      final result = data['result'];

      if (result == null) return [];

      if (result is! List) {
        throw const FormatException(
          'Plot result must be a list',
        );
      }

      final plots = result.map((item) {
        if (item is! Map) {
          throw const FormatException(
            'Invalid plot item',
          );
        }

        return FarmerPlotModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).where((plot) {
        return plot.plotId.isNotEmpty &&
            plot.plotName.isNotEmpty &&
            plot.farmerId == farmerId;
      }).toList();

      debugPrint(
        'GET FARMER PLOTS COUNT: ${plots.length}',
      );

      return plots;
    } on DioException catch (error) {
      debugPrint(
        'GET FARMER PLOTS ERROR: '
        '${error.response?.statusCode} ${error.message}',
      );

      throw Exception(
        'Unable to load plots: ${error.message}',
      );
    }
  }
}
