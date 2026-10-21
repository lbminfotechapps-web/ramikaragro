
// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';

// import 'package:solufine/core/api_constant/api_client.dart';
// import 'package:solufine/core/api_constant/dio_client.dart';

// abstract class PlotRemoteDataSource {
//   Future<List<Map<String, dynamic>>> searchFarmers(
//     String farmerName,
//   );

//   Future<List<Map<String, dynamic>>> getCrops();

//   Future<Map<String, dynamic>> submit(
//     Map<String, dynamic> payload,
//   );
// }

// class PlotRemoteDataSourceImpl
//     implements PlotRemoteDataSource {
//   final DioClient dioClient;

//   const PlotRemoteDataSourceImpl({
//     required this.dioClient,
//   });

//   Map<String, dynamic> _parseObject(dynamic value) {
//     dynamic body = value;

//     if (body is String) {
//       body = jsonDecode(body.trim());
//     }

//     if (body is! Map) {
//       throw const FormatException(
//         'Invalid JSON response',
//       );
//     }

//     return Map<String, dynamic>.from(body);
//   }

//   bool _success(dynamic value) {
//     return value == true ||
//         value == 1 ||
//         value.toString().toLowerCase() == 'true' ||
//         value.toString() == '1';
//   }

//   List<Map<String, dynamic>> _parseList(
//     dynamic value,
//   ) {
//     final body = _parseObject(value);
//     final result = body['result'];

//     if (!_success(body['status'])) {
//       final message =
//           body['message']?.toString() ??
//           body['messages']?.toString() ??
//           'Unable to load data';

//       if (result is List && result.isEmpty) {
//         return [];
//       }

//       if (message.toLowerCase().contains('no record')) {
//         return [];
//       }

//       throw Exception(message);
//     }

//     if (result == null) return [];

//     if (result is! List) {
//       throw const FormatException(
//         'Expected a result array',
//       );
//     }

//     return result.map((item) {
//       if (item is! Map) {
//         throw const FormatException(
//           'Invalid array item',
//         );
//       }

//       return Map<String, dynamic>.from(item);
//     }).toList();
//   }

//   @override
//   Future<List<Map<String, dynamic>>> searchFarmers(
//     String farmerName,
//   ) async {
//     final response = await dioClient.client.post<dynamic>(
//       ApiClient.getPlotFarmers,
//       data: {'farmerName': farmerName.trim()},
//       options: Options(
//         contentType: Headers.formUrlEncodedContentType,
//         responseType: ResponseType.plain,
//       ),
//     );

//     return _parseList(response.data);
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getCrops() async {
//     // Uses the same GET method as your existing
//     // Farmer Schedule crop datasource.
//     final response = await dioClient.client.get<dynamic>(
//       ApiClient.getCropList,
//       options: Options(
//         responseType: ResponseType.plain,
//       ),
//     );

//     return _parseList(response.data);
//   }

//   @override
//   Future<Map<String, dynamic>> submit(
//     Map<String, dynamic> payload,
//   ) async {
//     const encoder = JsonEncoder.withIndent('  ');

//     debugPrint('========== ADD PLOT REQUEST ==========');
//     debugPrint('METHOD: POST');
//     debugPrint(
//       'URL: ${ApiClient.baseUrl}'
//       '${ApiClient.submitPlotRegistration}',
//     );
//     debugPrint('CONTENT TYPE: application/json');
//     debugPrint('POST BODY:');
//     debugPrint(encoder.convert(payload));
//     debugPrint(
//       'PLOTS COUNT: ${(payload['plots'] as List).length}',
//     );

//     try {
//       final response =
//           await dioClient.client.post<dynamic>(
//         ApiClient.submitPlotRegistration,
//         data: payload,
//         options: Options(
//           contentType: Headers.jsonContentType,
//           responseType: ResponseType.plain,
//           headers: {'Accept': 'application/json'},
//         ),
//       );

//       final data = _parseObject(response.data);

//       debugPrint('========== ADD PLOT RESPONSE ==========');
//       debugPrint(
//         'HTTP STATUS: ${response.statusCode}',
//       );
//       debugPrint('RESPONSE BODY:');
//       debugPrint(encoder.convert(data));

//       return data;
//     } on DioException catch (e) {
//       debugPrint('========== ADD PLOT ERROR ==========');
//       debugPrint('HTTP STATUS: ${e.response?.statusCode}');
//       debugPrint('MESSAGE: ${e.message}');
//       debugPrint('BODY: ${e.response?.data}');
//       rethrow;
//     }
//   }
// }


import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';

abstract class PlotRemoteDataSource {
  Future<List<Map<String, dynamic>>> searchFarmers(
    String farmerName,
  );

  Future<List<Map<String, dynamic>>> getCrops();

  Future<Map<String, dynamic>> submit(
    Map<String, dynamic> payload,
  );
}

class PlotRemoteDataSourceImpl
    implements PlotRemoteDataSource {
  final DioClient dioClient;

  const PlotRemoteDataSourceImpl({
    required this.dioClient,
  });

  Map<String, dynamic> _parseObject(dynamic value) {
    dynamic data = value;

    if (data is String) {
      data = jsonDecode(data.trim());
    }

    if (data is! Map) {
      throw const FormatException('Invalid API response');
    }

    return Map<String, dynamic>.from(data);
  }

  bool _success(dynamic value) {
    return value == true ||
        value == 1 ||
        value.toString().toLowerCase() == 'true';
  }

  List<Map<String, dynamic>> _parseList(dynamic value) {
    final data = _parseObject(value);
    final result = data['result'];

    if (!_success(data['status'])) {
      final message =
          data['message']?.toString() ?? 'Unable to load data';

      if (result is List && result.isEmpty) {
        return [];
      }

      if (message.toLowerCase().contains('no record')) {
        return [];
      }

      throw Exception(message);
    }

    if (result == null) return [];

    if (result is! List) {
      throw const FormatException(
        'Expected an array in result',
      );
    }

    return result.map((item) {
      if (item is! Map) {
        throw const FormatException('Invalid result item');
      }

      return Map<String, dynamic>.from(item);
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> searchFarmers(
    String farmerName,
  ) async {
    final response =
        await dioClient.client.post<dynamic>(
      ApiClient.getPlotFarmers,
      data: {'farmerName': farmerName.trim()},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );

    return _parseList(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getCrops() async {
    final response =
        await dioClient.client.get<dynamic>(
      ApiClient.getCropList,
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    return _parseList(response.data);
  }

  @override
  Future<Map<String, dynamic>> submit(
    Map<String, dynamic> payload,
  ) async {
    // Convert only plots to a JSON string.
    final String empId = payload['empId'].toString();
    final String plotsJson = jsonEncode(payload['plots']);

    // Final two parameters sent to the server.
    final Map<String, dynamic> postData = {
      'empId': empId,
      'plots': plotsJson,
    };

    debugPrint('========== ADD PLOT POST DATA ==========');
    debugPrint('empId: $empId');
    debugPrint('plots: $plotsJson');

    try {
      final response =
          await dioClient.client.post<dynamic>(
        ApiClient.submitPlotRegistration,
        data: postData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
        ),
      );

      final result = _parseObject(response.data);

      debugPrint('========== ADD PLOT RESPONSE ==========');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint(
        const JsonEncoder.withIndent('  ').convert(result),
      );

      return result;
    } on DioException catch (e) {
      debugPrint('ADD PLOT API ERROR: ${e.message}');
      debugPrint(
        'ERROR RESPONSE: ${e.response?.data}',
      );

      rethrow;
    }
  }
}

