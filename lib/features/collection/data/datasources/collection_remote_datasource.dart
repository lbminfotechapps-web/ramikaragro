import 'dart:convert';
import 'dart:io';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/error/exceptions.dart';
import 'package:demo/features/collection/data/models/bank_model.dart';
import 'package:demo/features/collection/data/models/dealer_model.dart';
import 'package:demo/features/collection/data/models/submit_payment_response_model.dart';
import 'package:dio/dio.dart';

abstract class CollectionRemoteDataSource {
  // ============================================================
  // SUBMIT PAYMENT
  // ============================================================

  Future<SubmitPaymentResponseModel>
      submitPaymentDetails({
    required String dealerId,
    required String paymentMode,
    required String amount,
    required String rtgsNo,
    required String neftNo,
    required String chequeDate,
    required String chequeNumber,
    required String bankName,
    required String depositBankName,
    required String depositBranchName,
    required String remark,
    required String transaction,
    required String userId,
    required List<File> images,
  });

  // ============================================================
  // SEARCH DEALERS
  // ============================================================

  Future<List<DealerModel>> searchDealers({
    required String userId,
    required String searchText,
  });

  // ============================================================
  // BANK DETAILS
  // ============================================================

  Future<List<BankModel>> getBankDetails({
    required String dealerId,
    required String userId,
  });
}

class CollectionRemoteDataSourceImpl
    implements CollectionRemoteDataSource {
  final DioClient dioClient;

  CollectionRemoteDataSourceImpl({
    required this.dioClient,
  });

  // ============================================================
  // SUBMIT PAYMENT
  // ============================================================

  @override
  Future<SubmitPaymentResponseModel>
      submitPaymentDetails({
    required String dealerId,
    required String paymentMode,
    required String amount,
    required String rtgsNo,
    required String neftNo,
    required String chequeDate,
    required String chequeNumber,
    required String bankName,
    required String depositBankName,
    required String depositBranchName,
    required String remark,
    required String transaction,
    required String userId,
    required List<File> images,
  }) async {
    try {
      final Map<String, dynamic> fields = {
        'dealerId': dealerId.trim(),
        'strPaymentMode': paymentMode.trim(),
        'strAmount': amount.trim(),
        'strRTGSNo': rtgsNo.trim(),
        'strNEFTNo': neftNo.trim(),
        'strChequeDate': chequeDate.trim(),
        'strChequeNumber': chequeNumber.trim(),
        'strBankName': bankName.trim(),
        'strDepositBankName':
            depositBankName.trim(),
        'strDepositBrachName':
            depositBranchName.trim(),
        'remark': remark.trim(),
        'transcation': transaction.trim(),
        'userId': userId.trim(),
      };

      final formData = FormData.fromMap(fields);

      for (final image in images) {
        if (!await image.exists()) {
          continue;
        }

        formData.files.add(
          MapEntry(
            'pictures[]',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path
                  .split(Platform.pathSeparator)
                  .last,
            ),
          ),
        );
      }

      final response =
          await dioClient.client.post(
        ApiClient.submitPaymentDetails,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain,
          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          'Server error: ${response.statusCode}',
        );
      }

      dynamic responseData = response.data;

      responseData =
          _decodeResponse(responseData);

      if (responseData is! Map) {
        throw ServerException(
          'Invalid response format',
        );
      }

      final json =
          Map<String, dynamic>.from(responseData);

      final success =
          json['status'] == true ||
          json['status']
                  ?.toString()
                  .toLowerCase() ==
              'true';

      if (!success) {
        throw ServerException(
          json['message']?.toString() ??
              'Payment submission failed',
        );
      }

      return SubmitPaymentResponseModel
          .fromJson(json);
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      throw NetworkException(
        e.message ??
            'Network error occurred',
      );
    } catch (e) {
      throw NetworkException(
        e.toString(),
      );
    }
  }

  // ============================================================
  // SEARCH DEALERS
  // ============================================================

  @override
  Future<List<DealerModel>> searchDealers({
    required String userId,
    required String searchText,
  }) async {
    try {
      print(
        '==========================================',
      );
      print('SEARCH DEALER API');
      print(
        'URL: ${ApiClient.getTalukaWiseOutletForOrderNew}',
      );
      print('userId: $userId');
      print('searchText: $searchText');
      print(
        '==========================================',
      );

      final response =
          await dioClient.client.post(
        ApiClient.getTalukaWiseOutletForOrderNew,
        data: {
          'userId': userId,
          'searchText': searchText,
        },
      );

      print('DEALER STATUS: ${response.statusCode}');
      print('DEALER RESPONSE: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          'Server error: ${response.statusCode}',
        );
      }

      dynamic responseData =
          _decodeResponse(response.data);

      if (responseData is! Map) {
        throw ServerException(
          'Invalid dealer response',
        );
      }

      final json =
          Map<String, dynamic>.from(responseData);

      final result = json['result'];

      if (result == null) {
        return [];
      }

      if (result is! List) {
        return [];
      }

      return result
          .whereType<Map>()
          .map(
            (item) => DealerModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where(
            (dealer) =>
                dealer.id.isNotEmpty ||
                dealer.name.isNotEmpty,
          )
          .toList();
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print(
        'DEALER SEARCH DIO ERROR: ${e.message}',
      );

      throw NetworkException(
        e.message ??
            'Unable to search dealers',
      );
    } catch (e) {
      print(
        'DEALER SEARCH ERROR: $e',
      );

      throw NetworkException(
        e.toString(),
      );
    }
  }

  // ============================================================
  // BANK DETAILS
  // ============================================================

  @override
  Future<List<BankModel>> getBankDetails({
    required String dealerId,
    required String userId,
  }) async {
    try {
      print(
        '==========================================',
      );
      print('GET BANK DETAILS');
      print(
        'URL: ${ApiClient.getBankDetails}',
      );
      print('dealerId: $dealerId');
      print('userId: $userId');
      print(
        '==========================================',
      );

      final response =
          await dioClient.client.post(
        ApiClient.getBankDetails,
        data: {
          'dealerId': dealerId,
          'userId': userId,
        },
      );

      print(
        'BANK STATUS: ${response.statusCode}',
      );

      print(
        'BANK RESPONSE: ${response.data}',
      );

      if (response.statusCode != 200) {
        throw ServerException(
          'Server error: ${response.statusCode}',
        );
      }

      dynamic responseData =
          _decodeResponse(response.data);

      if (responseData is! Map) {
        throw ServerException(
          'Invalid bank response',
        );
      }

      final json =
          Map<String, dynamic>.from(responseData);

      final result = json['result'];

      if (result == null) {
        return [];
      }

      if (result is List) {
        return result
            .whereType<Map>()
            .map(
              (item) => BankModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      if (result is Map) {
        return [
          BankModel.fromJson(
            Map<String, dynamic>.from(result),
          ),
        ];
      }

      return [];
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      throw NetworkException(
        e.message ??
            'Unable to load bank details',
      );
    } catch (e) {
      throw NetworkException(
        e.toString(),
      );
    }
  }

  // ============================================================
  // RESPONSE DECODER
  // ============================================================

  dynamic _decodeResponse(dynamic data) {
    if (data is! String) {
      return data;
    }

    final raw = data.trim();

    if (raw.isEmpty) {
      throw ServerException(
        'Empty server response',
      );
    }

    try {
      return jsonDecode(raw);
    } catch (_) {
      final jsonStart = raw.indexOf('{');

      if (jsonStart != -1) {
        return jsonDecode(
          raw.substring(jsonStart),
        );
      }

      final arrayStart = raw.indexOf('[');

      if (arrayStart != -1) {
        return jsonDecode(
          raw.substring(arrayStart),
        );
      }

      throw ServerException(
        'Invalid server response',
      );
    }
  }
}