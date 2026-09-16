import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../models/category_model.dart';
import '../models/dealer_model.dart';
import '../models/godown_model.dart';
import '../models/product_model.dart';

class PlaceOrderRemoteDataSource {
  final DioClient dioClient;

  PlaceOrderRemoteDataSource({
    required this.dioClient,
  });

  // =========================================================
  // DEALER
  // =========================================================

  Future<List<DealerModel>> getDealers({
    required int userId,
    required String searchText,
  }) async {
    final response = await dioClient.client.post(
      ApiClient.getTalukaWiseOutletForOrderNew,
      data: FormData.fromMap({
        'userId': userId.toString(),
        'searchText': searchText,
      }),
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    final decoded = _decode(response.data);

    final list = _extractList(decoded);

    return list
        .map(
          (item) => DealerModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================================================
  // GODOWN
  // =========================================================

  Future<List<GodownModel>> getGodowns({
    required int userId,
  }) async {
    final response = await dioClient.client.post(
      ApiClient.getGodown,
      data: FormData.fromMap({
        'user_id': userId.toString(),
      }),
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    final decoded = _decode(response.data);

    final list = _extractList(decoded);

    return list
        .map(
          (item) => GodownModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================================================
  // CATEGORY
  // =========================================================

  Future<List<CategoryModel>> getCategories() async {
    final response = await dioClient.client.post(
      ApiClient.getCategory,
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    final decoded = _decode(response.data);

    final list = _extractList(decoded);

    return list
        .map(
          (item) => CategoryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================================================
  // PRODUCTS
  // =========================================================

  Future<List<ProductModel>> getProducts({
    required String categoryId,
    required String searchText,
  }) async {
    final response = await dioClient.client.post(
      ApiClient.getCatgoryProducts,
      data: FormData.fromMap({
        'categoryId': categoryId,
        'searchText': searchText,
      }),
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    final decoded = _decode(response.data);

    final list = _extractList(decoded);

    return list
        .map(
          (item) => ProductModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================================================
  // SUBMIT PLACE ORDER
  // =========================================================

  Future<void> submitOrder({
    required int userId,

    // Repository passes IDs instead of DealerModel/GodownModel.
    required String dealerId,
    required String godownId,

    required List<Map<String, dynamic>> products,
    required String remark,
    required List<String> imagePaths,

    // Digital signature bytes
    required Uint8List? signatureBytes,
  }) async {
    // =======================================================
    // TOTAL QUANTITY
    // =======================================================

    int totalQuantity = 0;

    for (final product in products) {
      final quantity =
          int.tryParse(
            product['quantity']?.toString() ?? '0',
          ) ??
          0;

      totalQuantity += quantity;
    }

    // =======================================================
    // GRAND TOTAL
    // =======================================================

    double grandTotal = 0;

    for (final product in products) {
      final quantity =
          double.tryParse(
            product['quantity']?.toString() ?? '0',
          ) ??
          0;

      final price =
          double.tryParse(
            product['price']?.toString() ?? '0',
          ) ??
          0;

      grandTotal += price * quantity;
    }

    // =======================================================
    // PRODUCT JSON
    // =======================================================

    final String productJsonString = jsonEncode(products);

    // =======================================================
    // FORM DATA
    // =======================================================

    final FormData formData = FormData();

    // -------------------------------------------------------
    // productJsonString
    // -------------------------------------------------------

    formData.fields.add(
      MapEntry(
        'productJsonString',
        productJsonString,
      ),
    );

    // -------------------------------------------------------
    // totalQuantity
    // -------------------------------------------------------

    formData.fields.add(
      MapEntry(
        'totalQuantity',
        totalQuantity.toString(),
      ),
    );

    // -------------------------------------------------------
    // empId
    // -------------------------------------------------------

    formData.fields.add(
      MapEntry(
        'empId',
        userId.toString(),
      ),
    );

    // -------------------------------------------------------
    // dealerId
    // -------------------------------------------------------

    formData.fields.add(
      MapEntry(
        'dealerId',
        dealerId,
      ),
    );

    // -------------------------------------------------------
    // SchemeId
    // -------------------------------------------------------

    formData.fields.add(
      const MapEntry(
        'SchemeId',
        '',
      ),
    );

    // -------------------------------------------------------
    // godownId
    // -------------------------------------------------------

    formData.fields.add(
      MapEntry(
        'godownId',
        godownId,
      ),
    );

    // -------------------------------------------------------
    // grandTotal
    // -------------------------------------------------------

    formData.fields.add(
      MapEntry(
        'grandTotal',
        grandTotal.toStringAsFixed(2),
      ),
    );

    // -------------------------------------------------------
    // orderTypeId
    // -------------------------------------------------------

    formData.fields.add(
      const MapEntry(
        'orderTypeId',
        '',
      ),
    );

    // -------------------------------------------------------
    // orderType
    // -------------------------------------------------------

    formData.fields.add(
      const MapEntry(
        'orderType',
        '',
      ),
    );

    // -------------------------------------------------------
    // remark
    // -------------------------------------------------------

    formData.fields.add(
      MapEntry(
        'remark',
        remark,
      ),
    );

    // -------------------------------------------------------
    // subdealerId
    // -------------------------------------------------------

    formData.fields.add(
      const MapEntry(
        'subdealerId',
        '',
      ),
    );

    // =======================================================
    // ORDER IMAGE
    // =======================================================

    if (imagePaths.isNotEmpty &&
        imagePaths.first.trim().isNotEmpty) {
      final String imagePath = imagePaths.first.trim();

      final File imageFile = File(imagePath);

      if (await imageFile.exists()) {
        final DateTime now = DateTime.now();

        final String currentTimestamp =
            (now.millisecondsSinceEpoch ~/ 1000).toString();

        final String formattedDate =
            DateFormat('ddMMyyyy').format(now);

        String extension = '.jpg';

        if (imagePath.contains('.')) {
          extension = imagePath
              .substring(imagePath.lastIndexOf('.'))
              .toLowerCase();
        }

        final String attachImage =
            'OrderImage'
            '${formattedDate}_'
            '${currentTimestamp}'
            '$extension';

        formData.files.add(
          MapEntry(
            'order_image',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: attachImage,
            ),
          ),
        );

        print(
          'Order Image: $attachImage',
        );
      } else {
        throw Exception(
          'Order image file does not exist.',
        );
      }
    } else {
      throw Exception(
        'Order image is required.',
      );
    }

    // =======================================================
    // DIGITAL SIGNATURE
    // =======================================================

    if (signatureBytes != null &&
        signatureBytes!.isNotEmpty) {
      final String timestamp =
          DateTime.now()
              .millisecondsSinceEpoch
              .toString();

      final String signatureFileName =
          'DigitalSignature_$timestamp.png';

      formData.files.add(
        MapEntry(
          'digitalSignature',
          MultipartFile.fromBytes(
            signatureBytes!,
            filename: signatureFileName,
          ),
        ),
      );

      print(
        'Digital Signature: $signatureFileName',
      );

      print(
        'Digital Signature Size: '
        '${signatureBytes!.length} bytes',
      );
    } else {
      throw Exception(
        'Digital signature is required.',
      );
    }

    // =======================================================
    // DEBUG REQUEST
    // =======================================================

    print('========================================');
    print('PLACE ORDER REQUEST');
    print('========================================');

    print(
      'URL: '
      '${ApiClient.baseUrl}'
      '${ApiClient.placeOrder}',
    );

    print(
      'productJsonString: '
      '$productJsonString',
    );

    print(
      'totalQuantity: '
      '$totalQuantity',
    );

    print(
      'empId: '
      '$userId',
    );

    print(
      'dealerId: '
      '$dealerId',
    );

    print(
      'SchemeId: ',
    );

    print(
      'godownId: '
      '$godownId',
    );

    print(
      'grandTotal: '
      '${grandTotal.toStringAsFixed(2)}',
    );

    print(
      'orderTypeId: ',
    );

    print(
      'orderType: ',
    );

    print(
      'remark: '
      '$remark',
    );

    print(
      'subdealerId: ',
    );

    print(
      'imagePaths: '
      '$imagePaths',
    );

    print(
      'signatureBytes: '
      '${signatureBytes?.length ?? 0} bytes',
    );

    print('========================================');

    // =======================================================
    // API CALL
    // =======================================================

    final response = await dioClient.client.post(
      ApiClient.placeOrder,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        responseType: ResponseType.plain,
      ),
    );

    // =======================================================
    // RESPONSE
    // =======================================================

    print('========================================');
    print('PLACE ORDER RESPONSE');
    print('========================================');
    print(response.data);
    print('========================================');

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Place order failed: ${response.statusCode}',
      );
    }
  }

  // =========================================================
  // DECODE
  // =========================================================

  dynamic _decode(dynamic data) {
    if (data is String) {
      final value = data.trim();

      if (value.isEmpty) {
        return [];
      }

      return jsonDecode(value);
    }

    return data;
  }

  // =========================================================
  // EXTRACT LIST
  // =========================================================

  List<dynamic> _extractList(dynamic json) {
    if (json is List) {
      return json;
    }

    if (json is Map<String, dynamic>) {
      if (json['data'] is List) {
        return json['data'];
      }

      if (json['result'] is List) {
        return json['result'];
      }

      if (json['response'] is List) {
        return json['response'];
      }
    }

    return [];
  }
}