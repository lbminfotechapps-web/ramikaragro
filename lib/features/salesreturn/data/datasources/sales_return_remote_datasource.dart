import 'dart:convert';
import 'dart:io';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../models/category_model.dart';
import '../models/dealer_model.dart';
import '../models/godown_model.dart';
import '../models/product_model.dart';

class SalesReturnRemoteDataSource {
  final DioClient dioClient;

  SalesReturnRemoteDataSource(this.dioClient);

  // ============================================================
  // DEALERS
  // ============================================================

  Future<List<DealerModel>> getDealers({
    required int userId,
    required String searchText,
  }) async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getTalukaWiseOutletForOrderNew,

        data: FormData.fromMap({
          'userId': userId.toString(),
          'searchText': searchText,
        }),
        options: Options(responseType: ResponseType.plain),
      );

      final dynamic data = _decodeResponse(response.data);

      if (data is List) {
        return data
            .map((e) => DealerModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final dynamic list =
            data['data'] ?? data['result'] ?? data['dealers'] ?? [];

        if (list is List) {
          return list
              .map((e) => DealerModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('GET DEALERS ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // GODOWN
  // ============================================================

  Future<List<GodownModel>> getGodowns({required int userId}) async {
    try {
      print('');
      print('========================================');
      print('GET GODOWN');
      print('========================================');

      print('userId: $userId');

      final response = await dioClient.client.post(
        ApiClient.getGodown,
        data: FormData.fromMap({'user_id': userId.toString()}),
        options: Options(responseType: ResponseType.plain),
      );

      print('GET GODOWN RESPONSE: ${response.data}');

      final dynamic data = _decodeResponse(response.data);

      if (data is List) {
        return data
            .map((e) => GodownModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final dynamic list =
            data['data'] ??
            data['result'] ??
            data['godown'] ??
            data['godowns'] ??
            [];

        if (list is List) {
          return list
              .map((e) => GodownModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('GET GODOWN ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getCategory,
        data: FormData(),
        options: Options(responseType: ResponseType.plain),
      );

      final dynamic data = _decodeResponse(response.data);

      if (data is List) {
        return data
            .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final dynamic list =
            data['data'] ??
            data['result'] ??
            data['category'] ??
            data['categories'] ??
            [];

        if (list is List) {
          return list
              .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('GET CATEGORY ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  Future<List<ProductModel>> getProducts({
    required String categoryId,
    String searchText = '',
  }) async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getCatgoryProducts,

        data: FormData.fromMap({
          'categoryId': categoryId,
          'searchText': searchText,
        }),
        options: Options(responseType: ResponseType.plain),
      );

      final dynamic data = _decodeResponse(response.data);

      if (data is List) {
        return data
            .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final dynamic list =
            data['data'] ?? data['result'] ?? data['products'] ?? [];

        if (list is List) {
          return list
              .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('GET PRODUCTS ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // UPLOAD SIGNATURE
  // ============================================================
  //
  // Android:
  //
  // POST upload_sign
  // multipart field = file
  //
  // This API uploads the signature separately.
  // It returns the server filename.
  //
  // ============================================================

  Future<String> uploadSignature({required String signaturePath}) async {
    try {
      print('');
      print('========================================');
      print('UPLOAD SIGNATURE');
      print('========================================');

      // ============================================================
      // VALIDATE PATH
      // ============================================================

      final String cleanPath = signaturePath.trim();

      if (cleanPath.isEmpty) {
        throw Exception('Signature path is empty');
      }

      // ============================================================
      // CHECK FILE
      // ============================================================

      final File signatureFile = File(cleanPath);

      if (!await signatureFile.exists()) {
        throw Exception('Signature file does not exist: $cleanPath');
      }

      final int signatureSize = await signatureFile.length();

      if (signatureSize <= 0) {
        throw Exception('Signature file is empty');
      }

      // ============================================================
      // CREATE SERVER FILENAME
      // ============================================================

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      final String fileName = 'Signature_$timestamp.png';

      // ============================================================
      // CREATE MULTIPART FILE
      // ============================================================

      final MultipartFile multipartFile = await MultipartFile.fromFile(
        signatureFile.path,
        filename: fileName,
      );

      // ============================================================
      // FORM DATA
      // ============================================================

      final FormData formData = FormData();

      // Android:
      // addFormDataPart("file", ...)
      //
      // Therefore field name MUST be "file"

      formData.files.add(MapEntry('file', multipartFile));

      // ============================================================
      // DEBUG
      // ============================================================

      print('API: upload_sign');
      print('Multipart field: file');
      print('Local path: ${signatureFile.path}');
      print('Filename: $fileName');
      print('File size: $signatureSize bytes');

      // ============================================================
      // API CALL
      // ============================================================

      final response = await dioClient.client.post(
        ApiClient.upload_sign,
        data: formData,
        options: Options(responseType: ResponseType.plain),
      );

      // ============================================================
      // RESPONSE
      // ============================================================

      print('');
      print('========================================');
      print('UPLOAD SIGNATURE RESPONSE');
      print('========================================');

      print(response.data);

      final dynamic decoded = _decodeResponse(response.data);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid upload_sign response');
      }

      // ============================================================
      // CHECK STATUS
      // ============================================================

      final String status = '${decoded['status'] ?? ''}'.toLowerCase();

      print('Upload status: $status');

      if (status != 'success') {
        throw Exception(
          decoded['message']?.toString() ?? 'Signature upload failed',
        );
      }

      // ============================================================
      // TRY TO GET FILENAME FROM SERVER RESPONSE
      // ============================================================

      String uploadedFileName = '';

      uploadedFileName = decoded['fileName']?.toString() ?? '';

      if (uploadedFileName.isEmpty) {
        uploadedFileName = decoded['filename']?.toString() ?? '';
      }

      if (uploadedFileName.isEmpty) {
        uploadedFileName = decoded['file']?.toString() ?? '';
      }

      if (uploadedFileName.isEmpty) {
        uploadedFileName = decoded['signature']?.toString() ?? '';
      }

      // ============================================================
      // IMPORTANT
      //
      // Your API currently returns:
      //
      // {"status":"success"}
      //
      // Therefore there is no filename in response.
      //
      // We already know the filename that was uploaded:
      //
      // Signature_xxxxxxxxx.png
      //
      // So use that filename.
      // ============================================================

      if (uploadedFileName.isEmpty) {
        uploadedFileName = fileName;
      }

      // ============================================================
      // FINAL VALIDATION
      // ============================================================

      if (uploadedFileName.trim().isEmpty) {
        throw Exception(
          'Signature uploaded successfully, '
          'but filename could not be determined',
        );
      }

      print('');
      print('========================================');
      print('SIGNATURE UPLOAD SUCCESS');
      print('========================================');

      print('Server filename: $uploadedFileName');

      return uploadedFileName;
    } on DioException catch (e) {
      print('');
      print('========================================');
      print('UPLOAD SIGNATURE DIO ERROR');
      print('========================================');

      print('Message: ${e.message}');

      print('Status: ${e.response?.statusCode}');

      print('Response: ${e.response?.data}');

      throw Exception(
        e.response?.data?.toString() ?? e.message ?? 'Signature upload failed',
      );
    } catch (e) {
      print('');
      print('========================================');
      print('UPLOAD SIGNATURE ERROR');
      print('========================================');

      print(e);

      rethrow;
    }
  }

  // ============================================================
  // ORDER
  // ============================================================

  Future<void> submitOrder({
    required int userId,
    required String dealerId,
    required String godownId,
    required List<Map<String, dynamic>> products,
    required String remark,
    required List<String> imagePaths,
    required String signatureFileName,
  }) async {
    try {
      print('');
      print('========================================');
      print('SALES RETURN REQUEST');
      print('========================================');

      if (products.isEmpty) {
        throw Exception('Please select at least one product');
      }

      // --------------------------------------------------------
      // CALCULATE TOTALS
      // --------------------------------------------------------

      int totalQuantity = 0;
      double grandTotal = 0.0;

      final List<Map<String, dynamic>> apiProducts = [];

      for (final product in products) {
        final int quantity = int.tryParse('${product['quantity'] ?? 0}') ?? 0;

        final double price = double.tryParse('${product['price'] ?? 0}') ?? 0.0;

        final double totalAmount = quantity * price;

        totalQuantity += quantity;
        grandTotal += totalAmount;

        final Map<String, dynamic> apiProduct = {
          'case_wise_qty': quantity,

          'current_date': product['currentDate'] ?? '',

          'dealer_id': dealerId,

          'fld_basic_rate': product['basicRate'] ?? '0.00',

          'fld_from_date': product['fromDate'] ?? '',

          'fld_gst_per': product['gstPercentage'] ?? 0,

          'fld_mrp': product['mrp'] ?? '0.00',

          'fld_order_qty_flag': product['orderQtyFlag'] ?? '',

          'fld_packing': product['packing'] ?? 0,

          'fld_product_details_id': product['productDetailsId'] ?? 0,

          'fld_product_id': product['productId'] ?? 0,

          'fld_product_name': product['productName'] ?? '',

          'fld_qty': quantity,

          'fld_rate_with_gst': product['rateWithGst'] ?? price,

          'fld_statewise_det_id': product['statewiseDetId'] ?? 0,

          'fld_to_date': product['toDate'] ?? '',

          'fld_unit': product['unit'] ?? '',

          'fld_unit_id': product['unitId'] ?? 0,

          'fld_units_per_case': product['unitsPerCase'] ?? 0,

          'id': product['id'] ?? 0,

          'isProductSelected': product['isProductSelected'] ?? true,

          'totalAmount': totalAmount.toStringAsFixed(2),
        };

        apiProducts.add(apiProduct);

        print('SUBMIT DATA: $apiProduct');
      }

      final String productJsonString = jsonEncode(apiProducts);

      // --------------------------------------------------------
      // FORM DATA
      // --------------------------------------------------------

      final FormData formData = FormData();

      formData.fields.add(MapEntry('productJsonString', productJsonString));

      formData.fields.add(MapEntry('totalQuantity', totalQuantity.toString()));

      formData.fields.add(MapEntry('empId', userId.toString()));

      formData.fields.add(MapEntry('dealerId', dealerId));

      formData.fields.add(const MapEntry('SchemeId', ''));

      formData.fields.add(MapEntry('godownId', godownId));

      formData.fields.add(
        MapEntry('grandTotal', grandTotal.toStringAsFixed(2)),
      );

      formData.fields.add(const MapEntry('orderTypeId', ''));

      formData.fields.add(const MapEntry('orderType', ''));

      formData.fields.add(MapEntry('remark', remark));

      formData.fields.add(const MapEntry('subdealerId', ''));

      // --------------------------------------------------------
      // SIGNATURE FILENAME
      // --------------------------------------------------------

      final String cleanSignatureFileName = signatureFileName.trim();

      if (cleanSignatureFileName.isEmpty) {
        throw Exception('Uploaded signature filename is empty');
      }

      // IMPORTANT:
      // upload_sign already uploaded the actual file.
      //
      // Here we only send the returned filename.
      formData.fields.add(MapEntry('digitalSignature', cleanSignatureFileName));

      print('');
      print('SIGNATURE FOR SALES RETURN');
      print(
        'Signature filename: '
        '$cleanSignatureFileName',
      );

      // --------------------------------------------------------
      // ORDER IMAGE
      // --------------------------------------------------------

      if (imagePaths.isEmpty || imagePaths.first.trim().isEmpty) {
        throw Exception('Please select order image');
      }

      final String imagePath = imagePaths.first.trim();

      final File imageFile = File(imagePath);

      if (!await imageFile.exists()) {
        throw Exception('Order image does not exist: $imagePath');
      }

      final int imageSize = await imageFile.length();

      if (imageSize <= 0) {
        throw Exception('Order image file is empty');
      }

      final DateTime now = DateTime.now();

      final String formattedDate = DateFormat('ddMMyyyy').format(now);

      final String timestamp = (now.millisecondsSinceEpoch ~/ 1000).toString();

      String extension = '.jpg';

      if (imagePath.contains('.')) {
        extension = imagePath
            .substring(imagePath.lastIndexOf('.'))
            .toLowerCase();
      }

      final String orderImageFileName =
          'OrderImage'
          '${formattedDate}_'
          '$timestamp'
          '$extension';

      final MultipartFile orderImage = await MultipartFile.fromFile(
        imageFile.path,
        filename: orderImageFileName,
      );

      formData.files.add(MapEntry('order_image', orderImage));

      print('');
      print('ORDER IMAGE');
      print('Path: ${imageFile.path}');
      print('Filename: $orderImageFileName');
      print('Size: $imageSize bytes');

      // --------------------------------------------------------
      // DEBUG FORM FIELDS
      // --------------------------------------------------------

      print('');
      print('========================================');
      print('SALES RETURN  FORM FIELDS');
      print('========================================');

      for (final field in formData.fields) {
        print('${field.key}: ${field.value}');
      }

      // --------------------------------------------------------
      // DEBUG FILES
      // --------------------------------------------------------

      print('');
      print('========================================');
      print('SALES RETURN  FILES');
      print('========================================');

      for (final file in formData.files) {
        print('FIELD: ${file.key}');

        print('FILE: ${file.value.filename}');

        print('TYPE: ${file.value.contentType}');
      }

      // --------------------------------------------------------
      // API
      // --------------------------------------------------------

      print('');
      print('========================================');
      print('CALLING SALES RETURN  API');
      print('========================================');

      print(
        'URL: '
        '${ApiClient.baseUrl}${ApiClient.submitSalesReturnRequest}',
      );

      final response = await dioClient.client.post(
        ApiClient.submitSalesReturnRequest,
        data: formData,
        options: Options(responseType: ResponseType.plain),
      );

      // --------------------------------------------------------
      // RESPONSE
      // --------------------------------------------------------

      print('');
      print('========================================');
      print('Sales Return RESPONSE');
      print('========================================');

      print('Status Code: ${response.statusCode}');

      print('Response: ${response.data}');

      if (response.statusCode == 200) {
        print('SALES RETURN SUCCESS');
        return;
      }

      throw Exception(
        'Sales Return failed. '
        'Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print('');
      print('========================================');
      print('SALES RETURN DIO ERROR');
      print('========================================');

      print('Message: ${e.message}');

      print(
        'Status Code: '
        '${e.response?.statusCode}',
      );

      print(
        'Response: '
        '${e.response?.data}',
      );

      throw Exception(
        e.response?.data?.toString() ?? e.message ?? 'Sales return API failed',
      );
    } catch (e) {
      print('');
      print('========================================');
      print('SALES RETURN  ERROR');
      print('========================================');

      print(e);

      rethrow;
    }
  }

  // ============================================================
  // RESPONSE DECODER
  // ============================================================

  dynamic _decodeResponse(dynamic responseData) {
    if (responseData == null) {
      return null;
    }

    if (responseData is Map || responseData is List) {
      return responseData;
    }

    if (responseData is String) {
      final String value = responseData.trim();

      if (value.isEmpty) {
        return null;
      }

      try {
        return jsonDecode(value);
      } catch (_) {
        return value;
      }
    }

    return responseData;
  }
}
