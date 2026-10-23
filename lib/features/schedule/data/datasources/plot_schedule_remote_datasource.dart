import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';

import '../../domain/repositories/plot_schedule_repository.dart';
import '../models/plot_schedule_model.dart';

abstract class PlotScheduleRemoteDataSource {
  Future<List<PlotScheduleModel>> fetch(PlotScheduleQuery query);
}

class PlotScheduleRemoteDataSourceImpl implements PlotScheduleRemoteDataSource {
  final DioClient dioClient;

  const PlotScheduleRemoteDataSourceImpl(this.dioClient);

  String _apiDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  @override
  Future<List<PlotScheduleModel>> fetch(PlotScheduleQuery query) async {
    final params = <String, dynamic>{
      'farmerId': query.farmerId.trim(),
      'plotId': query.plotId.trim(),

      'fromDate': query.fromDate == null ? '' : _apiDate(query.fromDate!),
      'toDate': query.toDate == null ? '' : _apiDate(query.toDate!),
      'cropId': query.cropId?.trim() ?? '',
      'startLimit': query.startLimit,
      'status': query.status ?? '',
    };

    final response = await dioClient.client.post(
      ApiClient.getPlotwiseScheduleList,
      data: FormData.fromMap(params),
    );

    final dynamic raw = response.data is String
        ? jsonDecode(response.data as String)
        : response.data;

    if (raw is! Map) {
      throw const FormatException('Unexpected schedule response');
    }

    final json = Map<String, dynamic>.from(raw);

    final status = json['status'];

    if (!(status == true || status == 1 || status == 'true' || status == '1')) {
      final message = (json['message'] ?? 'Unable to load history').toString();

      final text = message.toLowerCase();

      if (text.contains('no record') ||
          text.contains('no data') ||
          text.contains('not found')) {
        return [];
      }

      throw Exception(message);
    }

    final result = json['result'];

    if (result == null) {
      return [];
    }

    if (result is! List) {
      throw const FormatException('Invalid schedule result');
    }

    return result
        .whereType<Map>()
        .map(
          (item) => PlotScheduleModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
