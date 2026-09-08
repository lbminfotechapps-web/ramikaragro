import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/dealer/data/models/DealerListModel.dart';
import 'package:dio/dio.dart';



class DealerListDataSource {
  final DioClient dioClient;

  DealerListDataSource({
    required this.dioClient,
  });

  Future<List<DealerListModel>> fetchDealerList(
    String userId,
    String latitude,
    String longitude,
    String searchText,
    String type,
  ) async {
    try {
      print('');
      print('============================================');
      print('        DEALER API REQUEST START');
      print('============================================');

      print('URL: ${ApiClient.getNearByOutlets}');
      print('METHOD: POST');

      print('USER ID      : $userId');
      print('LATITUDE     : $latitude');
      print('LONGITUDE    : $longitude');
      print('SEARCH TEXT  : "$searchText"');
      print('TYPE         : "$type"');

      // --------------------------------------------------
      // REQUEST BODY
      // --------------------------------------------------

      final requestData = {
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'searchText': searchText,
        'type': type,
      };

      print('');
      print('REQUEST DATA:');
      print(jsonEncode(requestData));

      print('');
      print('============================================');
      print('        CALLING DEALER API');
      print('============================================');

      // --------------------------------------------------
      // API CALL
      // --------------------------------------------------

      final response = await dioClient.client.post(
        ApiClient.getNearByOutlets,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );

      // --------------------------------------------------
      // RESPONSE DEBUG
      // --------------------------------------------------

      print('');
      print('============================================');
      print('        DEALER API RESPONSE');
      print('============================================');

      print('STATUS CODE : ${response.statusCode}');
      print('STATUS MSG  : ${response.statusMessage}');
      print('DATA TYPE   : ${response.data.runtimeType}');
      print('DATA        : ${response.data}');

      print('============================================');

      // --------------------------------------------------
      // RESPONSE PARSING
      // --------------------------------------------------

      dynamic responseData = response.data;

      // Sometimes PHP APIs return JSON as String
      if (responseData is String) {
        print('Response is String. Decoding JSON...');

        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          print('JSON DECODE ERROR: $e');

          throw const FormatException(
            'Invalid JSON response from dealer API',
          );
        }
      }

      // Response must be Map
      if (responseData is! Map<String, dynamic>) {
        print(
          'INVALID RESPONSE TYPE: ${responseData.runtimeType}',
        );

        throw FormatException(
          'Dealer API response must be a JSON object. '
          'Received: ${responseData.runtimeType}',
        );
      }

      final Map<String, dynamic> data = responseData;

      // --------------------------------------------------
      // API STATUS
      // --------------------------------------------------

      final apiStatus = data['status'];
      final message = data['message'];

      print('');
      print('API STATUS  : $apiStatus');
      print('API MESSAGE : $message');

      // --------------------------------------------------
      // API FAILURE
      // --------------------------------------------------

      if (apiStatus != true) {
        throw Exception(
          message?.toString().isNotEmpty == true
              ? message.toString()
              : 'Failed to fetch dealer list',
        );
      }

      // --------------------------------------------------
      // RESULT
      // --------------------------------------------------

      final result = data['result'];

      print('');
      print('============================================');
      print('        DEALER RESULT');
      print('============================================');

      print('RESULT TYPE : ${result.runtimeType}');
      print('RESULT      : $result');

      if (result == null) {
        print('RESULT IS NULL');

        return [];
      }

      if (result is! List) {
        throw FormatException(
          'Dealer API result must be a List. '
          'Received: ${result.runtimeType}',
        );
      }

      print('TOTAL RECORDS: ${result.length}');

      // --------------------------------------------------
      // NO DEALERS
      // --------------------------------------------------

      if (result.isEmpty) {
        print('');
        print('NO DEALERS FOUND');
        print('============================================');

        return [];
      }

      // --------------------------------------------------
      // PARSE DEALERS
      // --------------------------------------------------

      final List<DealerListModel> dealers = [];

      for (int i = 0; i < result.length; i++) {
        try {
          final item = result[i];

          print('');
          print('--------------------------------------------');
          print('PARSING DEALER ${i + 1}');
          print('--------------------------------------------');

          print('RAW DATA: $item');

          if (item is Map<String, dynamic>) {
            final dealer = DealerListModel.fromJson(item);

            dealers.add(dealer);

            print('DEALER ID   : ${dealer.outletId}');
            print('DEALER NAME : ${dealer.outletName}');
            print('MOBILE      : ${dealer.outletPersonMobile}');
            print('ADDRESS     : ${dealer.outletAddress}');
            print('DISTANCE    : ${dealer.outletDistance}');
          } else if (item is Map) {
            // Handles Map<dynamic, dynamic>
            final Map<String, dynamic> dealerJson =
                Map<String, dynamic>.from(item);

            final dealer =
                DealerListModel.fromJson(dealerJson);

            dealers.add(dealer);

            print('DEALER ID   : ${dealer.outletId}');
            print('DEALER NAME : ${dealer.outletName}');
          } else {
            print(
              'SKIPPED INVALID DEALER TYPE: ${item.runtimeType}',
            );
          }
        } catch (e, stackTrace) {
          print('');
          print('DEALER PARSING ERROR');
          print('INDEX: $i');
          print('ERROR: $e');
          print('STACK: $stackTrace');

          // Continue parsing other dealers
        }
      }

      // --------------------------------------------------
      // COMPLETE
      // --------------------------------------------------

      print('');
      print('============================================');
      print('      DEALER DATASOURCE COMPLETE');
      print('============================================');

      print('TOTAL API RECORDS    : ${result.length}');
      print('TOTAL PARSED DEALERS : ${dealers.length}');

      print('============================================');

      return dealers;
    }

    // ==================================================
    // DIO ERROR
    // ==================================================

    on DioException catch (e, stackTrace) {
      print('');
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('          DEALER API DIO ERROR');
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

      print('');
      print('REQUEST URL:');
      print(e.requestOptions.uri);

      print('');
      print('REQUEST METHOD:');
      print(e.requestOptions.method);

      print('');
      print('REQUEST HEADERS:');
      print(e.requestOptions.headers);

      print('');
      print('REQUEST DATA:');
      print(e.requestOptions.data);

      print('');
      print('ERROR TYPE:');
      print(e.type);

      print('');
      print('STATUS CODE:');
      print(e.response?.statusCode);

      print('');
      print('STATUS MESSAGE:');
      print(e.response?.statusMessage);

      print('');
      print('SERVER RESPONSE TYPE:');
      print(e.response?.data.runtimeType);

      print('');
      print('SERVER RESPONSE DATA:');
      print(e.response?.data);

      print('');
      print('DIO MESSAGE:');
      print(e.message);

      print('');
      print('STACK TRACE:');
      print(stackTrace);

      print('');
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

      // --------------------------------------------------
      // Get useful backend message
      // --------------------------------------------------

      String errorMessage = 'Failed to fetch dealer list';

      final serverData = e.response?.data;

      if (serverData is Map) {
        if (serverData['message'] != null) {
          errorMessage =
              serverData['message'].toString();
        }

        if (serverData['error'] != null) {
          errorMessage =
              serverData['error'].toString();
        }

        if (serverData['msg'] != null) {
          errorMessage =
              serverData['msg'].toString();
        }
      } else if (serverData is String &&
          serverData.trim().isNotEmpty) {
        errorMessage = serverData;
      }

      throw Exception(errorMessage);
    }

    // ==================================================
    // FORMAT ERROR
    // ==================================================

    on FormatException catch (e, stackTrace) {
      print('');
      print('============================================');
      print('        DEALER FORMAT ERROR');
      print('============================================');

      print('ERROR: $e');
      print('STACK TRACE: $stackTrace');

      print('============================================');

      throw Exception(
        'Invalid dealer API response: ${e.message}',
      );
    }

    // ==================================================
    // OTHER ERROR
    // ==================================================

    catch (e, stackTrace) {
      print('');
      print('============================================');
      print('        DEALER DATASOURCE ERROR');
      print('============================================');

      print('ERROR TYPE: ${e.runtimeType}');
      print('ERROR     : $e');
      print('STACK     : $stackTrace');

      print('============================================');

      rethrow;
    }
  }
}