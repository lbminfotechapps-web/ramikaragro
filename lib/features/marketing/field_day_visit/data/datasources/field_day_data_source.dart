import 'dart:convert';
import 'package:solufine/features/schedule/data/datasources/farmer_schedule_remote_data_source.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import '../../domain/entities/field_day_entry.dart';
import '../models/field_day_model.dart';

class FieldDayDataSource {
  final Dio dio;
  final FarmerScheduleRemoteDataSource farmerSearch;
  FieldDayDataSource(DioClient client, {required this.farmerSearch})
    : dio = client.client;

  Future<String> submit(FieldDayEntry e) async {
    final parts = FormData.fromMap(FieldDayModel.toFields(e));
    const partKeys = {
      'km': 'uploadImage1',
      'vehicle': 'uploadImage2',
      'snacks': 'uploadImage3',
      'tent': 'uploadImage4',
      'hotel': 'uploadImage5',
      'misc': 'uploadImage6',
    };
    const prefixes = {
      'km': 'kmReadingImage',
      'vehicle': 'vehicleHiredImage',
      'snacks': 'snacksImage',
      'tent': 'tentChargesImage',
      'hotel': 'hotelChargesImage',
      'misc': 'miscChargesImage',
    };
    final date = DateFormat('ddMMyyyy').format(DateTime.now());
    final stamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (final item in partKeys.entries) {
      final path = e.expenseImages[item.key];
      if (path == null || path.isEmpty) continue;
      final file = File(path);
      if (!await file.exists()) throw StateError('Missing ${item.key} image');
      final ext = path.contains('.')
          ? path.substring(path.lastIndexOf('.'))
          : '.jpg';
      parts.files.add(
        MapEntry(
          item.value,
          await MultipartFile.fromFile(
            path,
            filename: '${prefixes[item.key]}${date}_$stamp$ext',
          ),
        ),
      );
    }
    for (final path in e.pictures) {
      if (!await File(path).exists()) throw StateError('Missing gallery image');
      parts.files.add(
        MapEntry(
          'pictures[]',
          await MultipartFile.fromFile(
            path,
            filename: path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }
    final response = await dio.post('/submitFieldDayProgram', data: parts);
    return parseResponse(response.data);
  }

  /// Dio may leave JSON as text when the server sends a text content type.
  static String parseResponse(dynamic data) {
    dynamic body = data;
    if (body is String) {
      final text = body.trim().replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      if (text.isEmpty) {
        throw const FormatException('Server returned an empty response.');
      }
      try {
        body = jsonDecode(text);
      } on FormatException {
        throw const FormatException(
          'Server returned invalid JSON. Please check the API response.',
        );
      }
    }
    if (body is! Map) {
      throw const FormatException(
        'Invalid server response. Expected a JSON object.',
      );
    }
    final status = body['status']?.toString().trim().toLowerCase();
    final message = body['message']?.toString().trim() ?? '';
    if (status != 'true' && status != '1') {
      throw StateError(message.isNotEmpty ? message : 'Submission failed');
    }
    return message.isEmpty ? 'Field Day submitted successfully' : message;
  }

  Future<List<FarmerOption>> searchFarmers(String userId, String search) async {
    final farmers = await farmerSearch.searchFarmer(searchKey: search.trim());
    return farmers
        .where((farmer) => farmer.farmerId.isNotEmpty && farmer.farmerId != '0')
        .map(
          (farmer) => FarmerOption(
            farmer.farmerId,
            farmer.farmerName,
            mobileNo: farmer.mobileNo,
            talukaName: farmer.talukaName,
          ),
        )
        .toList();
  }
}
